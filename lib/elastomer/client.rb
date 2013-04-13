require 'addressable/template'
require 'faraday'
require 'faraday_middleware'

module Elastomer

  #
  #
  class Client

    #
    #
    # host - The host as a String
    # port - The port number (default is 9200)
    #
    def initialize( host, port = 9200 )
      @host = host
      @port = port
      @url = "http://#@host:#@port"
    end

    attr_reader :host, :port, :url

    def connection
      @connection ||= Faraday.new(url) do |conn|
        conn.request  :json
        conn.response :json, :content_type => /\bjson$/i
        conn.adapter  :net_http_persistent
      end
    end

    #
    # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-health/
    def cluster_health( params = {} )
      response = connection.get('/_cluster/health', params)
      response.body
    end

    #
    # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-state/
    def cluster_state( params = {} )
      response = connection.get('/_cluster/state', params)
      response.body
    end

    #
    #
    def get( path, params = {} )
      body = params.delete(:body)
      path = expand_path(path, params)

      response = connection.get(path, body)
      return response if response.success?

      raise Elastomer::Error, response
    end

    #
    #
    def expand_path( path, params = {} )
      template = Addressable::Template.new path

      expansions = {}
      template.keys.map(&:to_sym).each do |key|
        expansions[key] = params.delete(key) if params.key? key
      end

      uri = template.expand(expansions)
      uri.query_values = params unless params.empty?
      uri
    end

  end  # Client
end  # Elastomer
