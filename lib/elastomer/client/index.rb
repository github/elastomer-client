
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
        response = client.head '/{index}{/type}', update_params(params)
        response.success?
      end
      alias :exist? :exists?

      # Create the index.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/
      #
      # body   - The index settings and mappings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def create( body, params = {} )
        response = client.post '/{index}', update_params(params, :body => body)
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
      # body   - The index settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update_settings( body, params = {} )
        response = client.put '/{index}/_settings', update_params(params, :body => body)
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
        response = client.get '/{index}{/type}/_mapping', update_params(params)
        response.body
      end

      # Register specific mapping definition for a specific type.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-put-mapping/
      #
      # type   - Name of the mapping to update as a String
      # body   - The mapping values to update as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update_mapping( type, body, params = {} )
        response = client.put '/{index}/{type}/_mapping', update_params(params, :body => body, :type => type)
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
        response = client.delete '/{index}/{type}', update_params(params, :type => type)
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
        response = client.get '{/index}/_analyze', update_params(params, :body => text.to_s)
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
        response = client.post '{/index}/_refresh', update_params(params)
        response.body
      end

      # Flush one or more indices to the index storage.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-flush/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def flush( params = {} )
        response = client.post '{/index}/_flush', update_params(params)
        response.body
      end

      def optimize(params = {})
        response = client.post '{/index}/_optimize', update_params(params)
        response.body
      end

      def snapshot(params = {})
        response = client.post '{/index}/_gateway/snapshot', update_params(params)
        response.body
      end

      def clear_cache(params = {})
        response = client.post '{/index}/_cache/clear', update_params(params)
        response.body
      end

      def stats(params = {})
        response = client.get '{/index}/_stats', update_params(params)
        response.body
      end

      def status(params = {})
        response = client.get '{/index}/_status', update_params(params)
        response.body
      end

      def segments(params = {})
        response = client.get '{/index}/_segments', update_params(params)
        response.body
      end

=begin
  Warmers
=end

      # Provides access to document-level API commands. These commands will be
      # scoped to this index and the give `type`, if any.
      #
      # type - The document type as a String
      #
      # Returns a Docs instance.
      def docs( type = nil )
        client.docs name, type
      end

      # Perform bulk indexing and/or delete operations. The current index name
      # will be passed to the bulk API call as part of the request parameters.
      #
      # params - Parameters Hash that will be passed to the bulk API call.
      # block  - Required block that is used to accumulate bulk API operations.
      #          All the operations will be passed to the search cluster via a
      #          single API request.
      #
      # Yields a Bulk instance for building bulk API call bodies.
      #
      # Examples
      #
      #   index.bulk do |b|
      #     b.index( document1 )
      #     b.index( document2 )
      #     b.delete( document3 )
      #     ...
      #   end
      #
      # Returns the response body as a Hash
      def bulk( params = {}, &block )
        raise 'a block is required' if block.nil?

        params = {:index => self.name}.merge params
        client.bulk params, &block
      end

      # Create a new Scan instance for scrolling all results from a `query`.
      # The Scan will be scoped to the current index.
      #
      # query  - The query to scan as a Hash or a JSON encoded String
      # opts   - Options Hash
      #   :index  - the name of the index to search
      #   :type   - the document type to search
      #   :scroll - the keep alive time of the scrolling request (5 minutes by default)
      #   :size   - the number of documents per shard to fetch per scroll
      #
      # Examples
      #
      #   scan = index.scan('{"query":{"match_all":{}}}')
      #   scan.each_document do |document|
      #     document['_id']
      #     document['_source']
      #   end
      #
      # Returns a new Scan instance
      def scan( query, opts = {} )
        opts = {:index => name}.merge opts
        client.scan query, opts
      end


      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params( params, overrides = nil )
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
