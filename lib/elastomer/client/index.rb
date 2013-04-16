
module Elastomer
  class Client

    # Provides access to index-level API commands.
    #
    # name - The name of the index as a String or an Array of names
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
      #
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

      # Create the index.
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

      # Delete the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-delete-index/
      #
      # Returns the response body as a Hash
      def delete
        response = client.delete '/{index}', defaults
        response.body
      end

      # Open the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/
      #
      # Returns the response body as a Hash
      def open
        response = client.post '/{index}/_open', defaults
        response.body
      end

      # Close the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/
      #
      # Returns the response body as a Hash
      def close
        response = client.post '/{index}/_close', defaults
        response.body
      end

      # Retrieve the settings for the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-get-settings/
      #
      # Returns the response body as a Hash
      def settings
        response = client.get '/{index}/_settings', defaults
        response.body
      end

      # Change specific index level settings in real time.
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

      # Retrive one or more mappings from the index. To retrieve a specific
      # mapping provide the name as the :type parameter.
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-get-mapping/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def mapping( params = {} )
        response = client.get '/{index}{/type}/_mapping', update(params)
        response.body
      end

      # Register specific mapping definition for a specific type.
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

      # Delete the mapping identified by `type`. This deletes all documents of
      # that type from the index.
      #
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

      # Return the aliases associated with this index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/
      #
      # Returns the response body as a Hash
      def get_aliases
        response = client.get '/{index}/_aliases', defaults
        response.body
      end

      # Performs the analysis process on a text and return the tokens breakdown of the text.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-analyze/
      #
      # text   - The text to analyze as a String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def analyze( text, params = {} )
        response = client.get '{/index}/_analyze', update(params, :body => text.to_s)
        response.body
      end

      # Explicitly refresh one or more index, making all operations performed
      # since the last refresh available for search.
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-refresh/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def refresh( params = {} )
        response = client.post '{/index}/_refresh', update(params)
        response.body
      end

      # Flush one or more indices to the index storage.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-flush/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def flush( params = {} )
        response = client.post '{/index}/_flush', update(params)
        response.body
      end

=begin
  Optimize
  Snapshot
  Warmers
  Stats
  Status
  Segments
  Clear Cache
=end

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
