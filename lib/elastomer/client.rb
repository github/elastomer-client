require "addressable/template"
require "faraday"
require "faraday_middleware"
require "multi_json"
require "semantic"

require "elastomer/version"
require "elastomer/version_support"

module Elastomer

  class Client
    MAX_REQUEST_SIZE = 250 * 2**20  # 250 MB

    RETRYABLE_METHODS = %i[get head].freeze

    # Create a new client that can be used to make HTTP requests to the
    # Elasticsearch server. If you use `:max_retries`, then any GET or HEAD
    # request will be retried up to this many times with a 75ms delay between
    # the retry attempts. Only non-fatal exceptions will retried automatically.
    #
    # see lib/elastomer/client/errors.rb#L92-L94
    #
    # Method params:
    #   :host - the host as a String
    #   :port - the port number of the server
    #   :url  - the URL as a String (overrides :host and :port)
    #   :read_timeout - the timeout in seconds when reading from an HTTP connection
    #   :open_timeout - the timeout in seconds when opening an HTTP connection
    #   :adapter      - the Faraday adapter to use (defaults to :excon)
    #   :opaque_id    - set to `true` to use the 'X-Opaque-Id' request header
    #   :max_request_size - the maximum allowed request size in bytes (defaults to 250 MB)
    #   :max_retries      - the maximum number of request retires (defaults to 0)
    #   :retry_delay      - delay in seconds between retries (defaults to 0.075)
    #   :strict_params    - set to `true` to raise exceptions when invalid request params are used
    #   :es_version       - set to the Elasticsearch version (example: "5.6.6") to avoid an HTTP request to get the version.
    #   :compress_body    - set to true to enable request body compression (default: false)
    #   :compression      - The compression level (0-9) when request body compression is enabled (default: Zlib::DEFAULT_COMPRESSION)
    #
    def initialize(host: "localhost", port: 9200, url: nil,
                   read_timeout: 5, open_timeout: 2, max_retries: 0, retry_delay: 0.075,
                   opaque_id: false, adapter: Faraday.default_adapter, max_request_size: MAX_REQUEST_SIZE,
                   strict_params: false, es_version: nil, compress_body: false, compression: Zlib::DEFAULT_COMPRESSION)

      @url = url || "http://#{host}:#{port}"

      uri = Addressable::URI.parse @url
      @host = uri.host
      @port = uri.port

      @read_timeout     = read_timeout
      @open_timeout     = open_timeout
      @max_retries      = max_retries
      @retry_delay      = retry_delay
      @adapter          = adapter
      @opaque_id        = opaque_id
      @max_request_size = max_request_size
      @strict_params    = strict_params
      @es_version       = es_version
      @compress_body    = compress_body
      @compression      = compression
    end

    attr_reader :host, :port, :url
    attr_reader :read_timeout, :open_timeout
    attr_reader :max_retries, :retry_delay, :max_request_size
    attr_reader :strict_params
    attr_reader :es_version
    attr_reader :compress_body
    attr_reader :compression
    alias :strict_params? :strict_params

    # Returns a duplicate of this Client connection configured in the exact same
    # fashion.
    def dup
      self.class.new \
          url:              url,
          read_timeout:     read_timeout,
          open_timeout:     open_timeout,
          adapter:          @adapter,
          opaque_id:        @opaque_id,
          max_request_size: max_request_size
    end

    # Returns true if the server is available; returns false otherwise.
    def ping
      response = head "/", action: "cluster.ping"
      response.success?
    rescue StandardError
      false
    end
    alias_method :available?, :ping

    # Returns the version String of the attached Elasticsearch instance.
    def version
      return es_version unless es_version.nil?

      @version ||= begin
        response = get "/"
        response.body.dig("version", "number")
      end
    end

    # Returns a Semantic::Version for the attached Elasticsearch instance.
    # See https://rubygems.org/gems/semantic
    def semantic_version
      Semantic::Version.new(version)
    end

    # Returns the information Hash from the attached Elasticsearch instance.
    def info
      response = get "/", action: "cluster.info"
      response.body
    end

    # Returns the ApiSpec for the specific version of Elasticsearch that this
    # Client is connected to.
    def api_spec
      @api_spec ||= RestApiSpec.api_spec(version)
    end

    # Internal: Provides access to the Faraday::Connection used by this client
    # for all requests to the server.
    #
    # Returns a Faraday::Connection
    def connection
      @connection ||= Faraday.new(url) do |conn|
        conn.response(:parse_json)
        # Request compressed responses from ES and decompress them
        conn.use(:gzip)
        conn.request(:encode_json)
        conn.request(:opaque_id) if @opaque_id
        conn.request(:limit_size, max_request_size: max_request_size) if max_request_size
        conn.request(:elastomer_compress, compression: compression) if compress_body

        if @adapter.is_a?(Array)
          conn.adapter(*@adapter)
        else
          conn.adapter(@adapter)
        end

        conn.options[:timeout]      = read_timeout
        conn.options[:open_timeout] = open_timeout
      end
    end

    # Internal: Reset the client by removing the current Faraday::Connection. A
    # new connection will be established on the next request.
    #
    # Returns this Client instance.
    def reset!
      @connection = nil
      self
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
    #   :body         - Will be used as the request body
    #   :read_timeout - Optional read timeout (in seconds) for the request
    #   :max_retires  - Optional retry number for the request
    #
    # Returns a Faraday::Response
    # Raises an Elastomer::Client::Error on 4XX and 5XX responses
    # rubocop:disable Metrics/MethodLength
    def request( method, path, params )
      read_timeout = params.delete(:read_timeout)
      request_max_retries = params.delete(:max_retries) || max_retries
      body = extract_body(params)
      path = expand_path(path, params)

      params[:retries] = retries = 0
      instrument(path, body, params) do
        begin
          response =
            case method
            when :head
              connection.head(path) { |req| req.options[:timeout] = read_timeout if read_timeout }

            when :get
              connection.get(path) { |req|
                req.body = body if body
                req.options[:timeout] = read_timeout if read_timeout
              }

            when :put
              connection.put(path, body) { |req| req.options[:timeout] = read_timeout if read_timeout }

            when :post
              connection.post(path, body) { |req| req.options[:timeout] = read_timeout if read_timeout }

            when :delete
              connection.delete(path) { |req|
                req.body = body if body
                req.options[:timeout] = read_timeout if read_timeout
              }

            else
              raise ArgumentError, "unknown HTTP request method: #{method.inspect}"
            end

          handle_errors response

        # wrap Faraday errors with appropriate Elastomer::Client error classes
        rescue Faraday::Error::ClientError => boom
          error = wrap_faraday_error(boom, method, path)
          if error.retry? && RETRYABLE_METHODS.include?(method) && (retries += 1) <= request_max_retries
            params[:retries] = retries
            sleep retry_delay
            retry
          end
          raise error
        rescue OpaqueIdError => boom
          reset!
          raise boom
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Internal: Returns a new Elastomer::Client error that wraps the given
    # Faraday error. A generic Error is returned if we cannot wrap the given
    # Faraday error.
    #
    #   error  - The Faraday error
    #   method - The request method
    #   path   - The request path
    #
    def wrap_faraday_error(error, method, path)
      error_name  = error.class.name.split("::").last
      error_class = Elastomer::Client.const_get(error_name) rescue Elastomer::Client::Error
      error_class.new(error, method.upcase, path)
    end

    # Internal: Extract the :body from the params Hash and convert it to a
    # JSON String format. If the params Hash does not contain a :body then no
    # action is taken and `nil` is returned.
    #
    # If a :body is present and is a String then it is assumed to a JSON String
    # and returned "as is".
    #
    # If a :body is present and is an Array then we join the values together
    # with newlines and append a trailing newline. This is a special case for
    # dealing with ES `bulk` imports and `multi_search` methods.
    #
    # Otherwise we convert the :body to a JSON string and return.
    #
    # params - Parameters Hash
    #
    # Returns the request body as a String or `nil` if no :body is present
    def extract_body( params )
      body = params.delete :body
      return if body.nil?

      body =
        case body
        when String
          body
        when Array
          body << nil unless body.last.nil?
          body.join "\n"
        else
          MultiJson.dump body
        end

      # Prevent excon from changing the encoding (see https://github.com/github/elastomer-client/issues/138)
      body.freeze
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
    #   expand_path('/foo{/bar}', {bar: 'hello', q: 'what', p: 2})
    #   #=> '/foo/hello?q=what&p=2'
    #
    #   expand_path('/foo{/bar}{/baz}', {baz: 'no bar'}
    #   #=> '/foo/no%20bar'
    #
    # Returns an Addressable::Uri
    def expand_path( path, params )
      template = Addressable::Template.new path

      expansions = {}
      query_values = params.dup
      query_values.delete :action
      query_values.delete :context
      query_values.delete :retries

      rest_api = query_values.delete :rest_api

      template.keys.map(&:to_sym).each do |key|
        value = query_values.delete key
        value = assert_param_presence(value, key) unless path =~ /{\/#{key}}/ && value.nil?
        expansions[key] = value
      end

      if rest_api
        query_values = if strict_params?
          api_spec.validate_params!(api: rest_api, params: query_values)
        else
          api_spec.select_params(api: rest_api, from: query_values)
        end
      end

      uri = template.expand(expansions)
      uri.query_values = query_values unless query_values.empty?
      uri.to_s
    end

    # Internal: A noop method that simply yields to the block. This method
    # will be replaced when the 'elastomer/notifications' module is included.
    #
    # path   - The full request path as a String
    # body   - The request body as a String or `nil`
    # params - The request params Hash
    # block  - The block that will be instrumented
    #
    # Returns the response from the block
    def instrument( path, body, params )
      yield
    end

    # Internal: Inspect the Faraday::Response and raise an error if the status
    # is in the 5XX range or if the response body contains an 'error' field.
    # In the latter case, the value of the 'error' field becomes our exception
    # message. In the absence of an 'error' field the response body is used
    # as the exception message.
    #
    # The raised exception will contain the response object.
    #
    # response - The Faraday::Response object.
    #
    # Returns the response.
    # Raises an Elastomer::Client::Error on 500 responses or responses
    # containing and 'error' field.
    def handle_errors( response )
      raise ServerError, response if response.status >= 500

      if response.body.is_a?(Hash) && (error = response.body["error"])
        root_cause = Array(error["root_cause"]).first || error
        case root_cause["type"]
        when "index_not_found_exception"; raise IndexNotFoundError, response
        when "illegal_argument_exception"; raise IllegalArgument, response
        when "es_rejected_execution_exception"; raise RejectedExecutionError, response
        when *version_support.query_parse_exception; raise QueryParsingError, response
        end

        raise RequestError, response
      end

      response
    end

    # Internal: Ensure that the parameter has a valid value. Strings, Symbols,
    # Numerics, and Arrays of those things are valid. Things like `nil`
    # and empty strings are right out. This method also performs a little
    # formating on the parameter:
    #
    # * leading and trailing whitespace is removed
    # * arrays are flattend
    # * and then joined into a String
    # * numerics are converted to their string equivalents
    #
    # param - The param Object to validate
    # name  - Optional param name as a String (used in exception messages)
    #
    # Returns the validated param as a String.
    # Raises an ArgumentError if the param is not valid.
    def assert_param_presence( param, name = "input value" )
      case param
      when String, Symbol, Numeric
        param = param.to_s.strip
        raise ArgumentError, "#{name} cannot be blank: #{param.inspect}" if param =~ /\A\s*\z/
        param

      when Array
        param.flatten.map { |item| assert_param_presence(item, name) }.join(",")

      when nil
        raise ArgumentError, "#{name} cannot be nil"

      else
        raise ArgumentError, "#{name} is invalid: #{param.inspect}"
      end
    end

    def version_support
      @version_support ||= VersionSupport.new(version)
    end

  end  # Client
end  # Elastomer

# require all files in the `client` sub-directory
Dir.glob(File.expand_path("../client/*.rb", __FILE__)).each { |fn| require fn }

# require all files in the `middleware` sub-directory
Dir.glob(File.expand_path("../middleware/*.rb", __FILE__)).each { |fn| require fn }
