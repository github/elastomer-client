require 'active_support/notifications'
require 'addressable/template'
require 'faraday'
require 'faraday_middleware'
require 'securerandom'

require File.expand_path('../../elastomer', __FILE__) unless defined? Elastomer::Error

module Elastomer

  class Client
    # General error response from client requests.
    #
    class Error < ::Elastomer::Error
      # Construct a new Error from the given response object or a message
      # String. If a response object is given, the error message will be
      # extracted from the response body.
      #
      # response - Either a message String or a Faraday::Response
      #
      def initialize( response )
        message =
          if response.respond_to? :body
            @response = response
            response.body['error'] || response.body
          else
            response
          end

        super(message)
      end

      attr_reader :response

      # Returns the status code from the `response` or nil if the Error was not
      # created with a response.
      def status
        response ? response.status : nil
      end
    end  # Error


    # Create a new client that can be used to make HTTP requests to the
    # ElasticSearch server.
    #
    # opts - The options Hash
    #   :host - the host as a String
    #   :port - the port number of the server
    #   :url  - the URL as a String (overrides :host and :port)
    #   :read_timeout - the timeout in seconds when reading from an HTTP connection
    #   :open_timeout - the timeout in seconds when opening an HTTP connection
    #
    def initialize( opts = {} )
      @host = opts.fetch :host, 'localhost'
      @port = opts.fetch :port, 9200
      @url  = opts.fetch :url,  "http://#@host:#@port"

      @read_timeout = opts.fetch :read_timeout, 4
      @open_timeout = opts.fetch :open_timeout, 2
      @adapter      = opts.fetch :adapter, :excon
    end

    attr_reader :host, :port, :url
    attr_reader :read_timeout, :open_timeout

    # Returns true if the server is available; returns false otherwise.
    def available?
      response = head '/', :action => 'cluster.available'
      response.success?
    rescue StandardError
      false
    end

    # Internal: Provides access to the Faraday::Connection used by this client
    # for all requests to the server.
    #
    # Returns a Faraday::Connection
    def connection
      @connection ||= Faraday.new(url) do |conn|
        conn.request  :json
        conn.response :json, :content_type => /\bjson$/i

        Array === @adapter ?
          conn.adapter(*@adapter) :
          conn.adapter(@adapter)

        conn.options[:read_timeout] = read_timeout
        conn.options[:open_timeout] = open_timeout
      end
    end

    # Internal: Sends an HTTP HEAD request to the server.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Returns a Faraday::Response
    def head( path, params = {} )
      request :head, path, params
    end

    # Internal: Sends an HTTP GET request to the server.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    def get( path, params = {} )
      request :get, path, params
    end

    # Internal: Sends an HTTP PUT request to the server.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    def put( path, params = {} )
      request :put, path, params
    end

    # Internal: Sends an HTTP POST request to the server.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    def post( path, params = {} )
      request :post, path, params
    end

    # Internal: Sends an HTTP DELETE request to the server.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    def delete( path, params = {} )
      request :delete, path, params
    end

    # Internal: Sends an HTTP request to the server. If the `params` Hash
    # contains a :body key, it will be deleted from the Hash and the value
    # will be used as the body of the request.
    #
    # method - The HTTP method to send [:head, :get, :put, :post, :delete]
    # path   - The path as a String
    # params - Parameters Hash
    #   :body   - Will be used as the request body
    #   :accpet - One or more acceptable HTTP status codes [402, 404]
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    def request( method, path, params )
      accept = params.delete :accept
      accept = Array(accept) unless accept.nil?

      body = params.delete :body
      path = expand_path path, params

      response = instrument(path, params) do
        case method
        when :head;   connection.head(path)
        when :get;    connection.get(path) { |req| req.body = body if body }
        when :put;    connection.put(path, body)
        when :post;   connection.post(path, body)
        when :delete; connection.delete(path) { |req| req.body = body if body }
        else
          raise ArgumentError, "unknown HTTP request method: #{method.inspect}"
        end
      end

      return response if response.success?                            ||
                         (accept && accept.include?(response.status)) ||
                         (:head == method && response.status < 500)

      raise ::Elastomer::Client::Error, response
    # ensure
    #   # FIXME: this is here until we get a real logger in place
    #   STDERR.puts "[#{response.status.inspect}] curl -X#{method.to_s.upcase} '#{url}#{path}'" unless response.nil?
    end

    # Internal: Apply path expansions to the `path` and append query
    # parameters to the `path`. We are using an Addressable::Template to
    # replace '{expansion}' fields found in the path with the values extracted
    # from the `params` Hash. Any remaining elements in the `params` hash are
    # treated as query parameters and appended to the end of the path.
    #
    # path   - The path as a String
    # params - Parameters Hash
    #
    # Examples
    #
    #   expand_path('/foo{/bar}', {:bar => 'hello', :q => 'what', :p => 2})
    #   #=> '/foo/hello?q=what&p=2'
    #
    #   expand_path('/foo{/bar}{/baz}', {:baz => 'no bar'}
    #   #=> '/foo/no%20bar'
    #
    # Returns an Addressable::Uri
    def expand_path( path, params )
      template = Addressable::Template.new path

      expansions = {}
      query_values = params.dup
      query_values.delete :action

      template.keys.map(&:to_sym).each do |key|
        expansions[key] = query_values.delete(key) if query_values.key? key
      end

      uri = template.expand(expansions)
      uri.query_values = query_values unless query_values.empty?
      uri.to_s
    end

    # Internal:
    #
    # path   - The full request path as a String
    # params - The request params Hash
    # block  - The block that will be instrumented
    #
    # Returns the response from the block
    def instrument( path, params )
      action = params[:action]

      if action.nil?
        ary = []
        m = /^([^?]*)/.match path
        m[1].split('?').first.split('/').each do |str|
          if str =~ /^_(.*)$/
            ary.clear
            ary << $1
          else
            ary << str
          end
        end
        action = ary.join '.' unless ary.empty?
      end

      payload = {
        :index  => params[:index],
        :type   => params[:type],
        :url    => "#{@url}#{path}",
        :action => action
      }

      ActiveSupport::Notifications.instrument('request.client.elastomer', payload) do
        response = yield
        payload[:method] = response.env[:method]
        payload[:status] = response.status
        response
      end
    end

  end  # Client
end  # Elastomer

# require all files in the `client` sub-directory
Dir.glob(File.expand_path('../client/*.rb', __FILE__)).each { |fn| require fn }

