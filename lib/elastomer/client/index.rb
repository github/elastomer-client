
module Elastomer
  class Client

    # Provides access to index-level API commands.
    #
    # index - The name of the index as a String or an Array of names
    #
    # Returns an Index instance.
    def index( name )
      Index.new self, name
    end


    class Index
      # Create a new index client for making API requests that pertain to
      # the health and management individual indexes.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # name   - The name of the index as a String or an Array of names
      #
      def initialize( client, name )
        raise ArgumentError, 'index name cannot be nil' if name.nil?

        @client = client
        @name   = name.to_s
      end

      attr_reader :client, :name

      # Check for the existence of the index. If a :type option is given, then
      # we will check for the existence of the document type in the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-indices-exists/
      # and http://www.elasticsearch.org/guide/reference/api/admin-indices-types-exists/
      #
      # params - Parameters Hash
      #
      # Returns true if the index (or type) exists
      def exists?( params = {} )
        response = client.head '/{index}{/type}', update(params)
        response.success?
      end
      alias :exist? :exists?

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/
      #
      # body   - The index settings and mappings as a Hash
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def create( body, params = {} )
        response = client.post '/{index}', update(params, :body => body)
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-delete-index/
      #
      # Returns the response body as a Hash
      def delete
        response = client.delete '/{index}', defaults
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/
      #
      # Returns the response body as a Hash
      def open
        response = client.post '/{index}/_open', defaults
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/
      #
      # Returns the response body as a Hash
      def close
        response = client.post '/{index}/_close', defaults
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-get-settings/
      #
      # Returns the response body as a Hash
      def settings
        response = client.get '/{index}/_settings', defaults
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-update-settings/
      #
      # body   - The index settings as a Hash
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update_settings( body, params = {} )
        response = client.put '/{index}/_settings', update(params, :body => body)
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-get-mapping/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def mapping( params = {} )
        response = client.get '/{index}{/type}/_mapping', update(params)
        response.body
      end

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-put-mapping/
      #
      # type   - Name of the mapping to update as a String
      # body   - The mapping values to update
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update_mapping( type, body, params = {} )
        response = client.put '/{index}/{type}/_mapping', update(params, :body => body, :type => type)
        response.body
      end
      alias :put_mapping :update_mapping

      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-delete-mapping/
      #
      # type   - Name of the mapping to update as a String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete_mapping( type, params = {} )
        response = client.delete '/{index}/{type}', update(params, :type => type)
        response.body
      end

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update( params, overrides = nil )
        h = defaults.update params
        h.update overrides unless overrides.nil?
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :index => name }
      end
    end  # Index
  end  # Client
end  # Elastomer
