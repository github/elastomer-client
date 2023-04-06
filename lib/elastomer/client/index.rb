# frozen_string_literal: true

module Elastomer
  class Client

    # Provides access to index-level API commands. An index name is required for
    # these API calls. If you want to operate on all indices - flushing all
    # indices, for example - then you will need to use the "_all" index name.
    #
    # You can override the index name for one-off calls by passing in the
    # desired index name via the `:index` option.
    #
    # name - The name of the index as a String or an Array of names
    #
    # Returns an Index instance.
    def index(name = nil)
      Index.new self, name
    end

    class Index
      # Create a new index client for making API requests that pertain to
      # the health and management of individual indexes.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # name   - The name of the index as a String or an Array of names
      #
      def initialize(client, name)
        @client = client
        @name   = @client.assert_param_presence(name, "index name") unless name.nil?
      end

      attr_reader :client, :name

      # Check for the existence of the index. If a `:type` option is given, then
      # we will check for the existence of the document type in the index.
      #
      # params - Parameters Hash
      #   :type - optional type mapping as a String
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-exists.html
      # and https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-types-exists.html
      #
      # Returns true if the index (or type) exists
      def exists?(params = {})
        response = client.head "/{index}{/type}", update_params(params, action: "index.exists", rest_api: "indices.exists")
        response.success?
      end
      alias_method :exist?, :exists?

      # Create the index.
      #
      # body   - The index settings and mappings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html
      #
      # Returns the response body as a Hash
      def create(body, params = {})
        response = client.put "/{index}", update_params(params, body: body, action: "index.create", rest_api: "indices.create")
        response.body
      end

      # Delete the index.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-delete-index.html
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete "/{index}", update_params(params, action: "index.delete", rest_api: "indices.delete")
        response.body
      end

      # Open the index.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html
      #
      # Returns the response body as a Hash
      def open(params = {})
        response = client.post "/{index}/_open", update_params(params, action: "index.open", rest_api: "indices.open")
        response.body
      end

      # Close the index.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html
      #
      # Returns the response body as a Hash
      def close(params = {})
        response = client.post "/{index}/_close", update_params(params, action: "index.close", rest_api: "indices.close")
        response.body
      end

      # Retrieve the settings for the index.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-settings.html
      #
      # Returns the response body as a Hash
      def get_settings(params = {})
        response = client.get "{/index}/_settings", update_params(params, action: "index.get_settings", rest_api: "indices.get_settings")
        response.body
      end
      alias_method :settings, :get_settings

      # Change specific index level settings in real time.
      #
      # body   - The index settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
      #
      # Returns the response body as a Hash
      def update_settings(body, params = {})
        response = client.put "{/index}/_settings", update_params(params, body: body, action: "index.update_settings", rest_api: "indices.put_settings")
        response.body
      end

      # Retrieve one or more mappings from the index. To retrieve a specific
      # mapping provide the name as the `:type` parameter.
      #
      # params - Parameters Hash
      #   :type - specific document type as a String or Array of Strings
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-mapping.html
      #
      # Returns the response body as a Hash
      def get_mapping(params = {})
        response = client.get "/{index}/_mapping{/type}", update_params(params, action: "index.get_mapping", rest_api: "indices.get_mapping")
        response.body
      end
      alias_method :mapping, :get_mapping

      # Register specific mapping definition for a specific type.
      #
      # type   - Name of the mapping to update as a String
      # body   - The mapping values to update as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
      #
      # Returns the response body as a Hash
      def update_mapping(type, body, params = {})
        response = client.put "/{index}/_mapping{/type}", update_params(params, body: body, type: type, action: "index.update_mapping", rest_api: "indices.put_mapping")
        response.body
      end
      alias_method :put_mapping, :update_mapping

      # Return the aliases associated with this index.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def get_aliases(params = {})
        response = client.get "/{index}/_alias", update_params(action: "index.get_aliases", rest_api: "indices.get_alias")
        response.body
      end
      alias_method :aliases, :get_aliases

      # Return the named aliases associated with this index.
      #
      # name   - Name of the alias to look up
      # params - Parameters Hash
      #   :ignore_unavailable - What to do if a specified index name doesn’t
      #                         exist. If set to `true` then those indices are ignored.
      #
      # Examples
      #
      #   index.get_alias("*")       # returns all aliases for the current index
      #   index.get_alias("issue*")  # returns all aliases starting with "issue"
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def get_alias(name, params = {})
        response = client.get "/{index}/_alias/{name}", update_params(params, name: name, action: "index.get_alias", rest_api: "indices.get_alias")
        response.body
      end

      # Add a single alias to this index.
      #
      # name   - Name of the alias to add to the index
      # params - Parameters Hash
      #   :routing - optional routing that can be associated with an alias
      #   :filter  - optional filter that can be associated with an alias
      #
      # Examples
      #
      #   index.add_alias("foo", routing: "foo")
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def add_alias(name, params = {})
        response = client.put "/{index}/_alias/{name}", update_params(params, name: name, action: "index.add_alias", rest_api: "indices.put_alias")
        response.body
      end

      # Delete an alias from this index.
      #
      # name   - Name of the alias to delete from the index
      # params - Parameters Hash
      #
      # Examples
      #
      #   index.delete_alias("foo")
      #   index.delete_alias(["foo", "bar"])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def delete_alias(name, params = {})
        response = client.delete "/{index}/_alias/{name}", update_params(params, name: name, action: "index.delete_alias", rest_api: "indices.delete_alias")
        response.body
      end

      # Perform the analysis process on some text and return the tokens
      # breakdown of the text.
      #
      # text   - The text to analyze as a String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html
      #
      # Returns the response body as a Hash
      def analyze(text, params = {})
        body = text.is_a?(Hash) ? text : {text: text.to_s}
        response = client.get "{/index}/_analyze", update_params(params, body: body, action: "index.analyze", rest_api: "indices.analyze")
        response.body
      end

      # Explicitly refresh one or more index, making all operations performed
      # since the last refresh available for search.
      #
      # params - Parameters Hash
      #   :index - set to "_all" to refresh all indices
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html
      #
      # Returns the response body as a Hash
      def refresh(params = {})
        response = client.post "{/index}/_refresh", update_params(params, action: "index.refresh", rest_api: "indices.refresh")
        response.body
      end

      # Flush one or more indices to the index storage.
      #
      # params - Parameters Hash
      #   :index - set to "_all" to flush all indices
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-flush.html
      #
      # Returns the response body as a Hash
      def flush(params = {})
        response = client.post "{/index}/_flush", update_params(params, action: "index.flush", rest_api: "indices.flush")
        response.body
      end

      # Force merge one or more indices. Force merging an index allows to
      # reduce the number of segments but can be resource intensive.
      #
      # params - Parameters Hash
      #   :index - set to "_all" to force merge all indices
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html
      #
      # Returns the response body as a Hash
      def forcemerge(params = {})
        response = client.post "{/index}/_forcemerge", update_params(params, action: "index.forcemerge", rest_api: "indices.forcemerge")
        response.body
      end
      # DEPRECATED:  ES 5.X has removed the `/_optimize` endpoint.
      alias_method :optimize, :forcemerge

      # Provides insight into ongoing index shard recoveries. Recovery status
      # may be reported for specific indices, or cluster-wide.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-recovery.html
      #
      # Returns the response body as a Hash
      def recovery(params = {})
        response = client.get "{/index}/_recovery", update_params(params, action: "index.recovery", rest_api: "indices.recovery")
        response.body
      end

      # Clear caches for one or more indices. Individual caches can be
      # specified with parameters.
      #
      # params - Parameters Hash
      #   :index - set to "_all" to clear all index caches
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-clearcache.html
      #
      # Returns the response body as a Hash
      def clear_cache(params = {})
        response = client.post "{/index}/_cache/clear", update_params(params, action: "index.clear_cache", rest_api: "indices.clear_cache")
        response.body
      end

      # Retrieve statistics about one or more indices. Specific statistics
      # can be retrieved with parameters.
      #
      # params - Parameters Hash
      #   :stats - a single stats value or an Array of stats values
      #
      # Examples
      #
      #   stats(stats: "docs")
      #   stats(stats: %w[flush merge])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-stats.html
      #
      # Returns the response body as a Hash
      def stats(params = {})
        response = client.get "{/index}/_stats{/stats}", update_params(params, action: "index.stats", rest_api: "indices.stats")
        response.body
      end

      # Retrieve low level Lucene segments information for shards of one
      # or more indices.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-segments.html
      #
      # Returns the response body as a Hash
      def segments(params = {})
        response = client.get "{/index}/_segments", update_params(params, action: "index.segments", rest_api: "indices.segments")
        response.body
      end

      # Provides access to document-level API commands. These commands will be
      # scoped to this index and the give `type`, if any.
      #
      # type - The document type as a String
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html
      #
      # Returns a Docs instance.
      def docs(type = nil)
        type = "_doc" if client.version_support.es_version_7_plus?
        client.docs name, type
      end

      # Exposes the `/_suggest` endpoint of the Elasticsearch API.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters.html
      #
      # Returns the response body as a Hash
      def suggest(query, params = {})
        response = client.post "{/index}/_suggest", update_params(params, body: query, action: "index.suggest", rest_api: "suggest")
        response.body
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
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html
      #
      # Returns the response body as a Hash
      def bulk(params = {}, &block)
        raise "a block is required" if block.nil?

        params = {index: self.name}.merge params
        client.bulk params, &block
      end

      # Create a new Scroller instance for scrolling all results from a `query`.
      # The Scroller will be scoped to the current index.
      #
      # query  - The query to scroll as a Hash or a JSON encoded String
      # opts   - Options Hash
      #   :index  - the name of the index to search
      #   :type   - the document type to search
      #   :scroll - the keep alive time of the scrolling request (5 minutes by default)
      #   :size   - the number of documents per shard to fetch per scroll
      #
      # Examples
      #
      #   scroll = index.scroll('{"query":{"match_all":{}},"sort":{"date":"desc"}}')
      #   scroll.each_document do |document|
      #     document['_id']
      #     document['_source']
      #   end
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
      #
      # Returns a new Scroller instance
      def scroll(query, opts = {})
        opts = {index: name}.merge opts
        client.scroll query, opts
      end

      # Create a new Scroller instance for scanning all results from a `query`.
      # The Scroller will be scoped to the current index. The Scroller is
      # configured to use `scan` semantics which are more efficient than a
      # standard scroll query; the caveat is that the returned documents cannot
      # be sorted.
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
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
      #
      # Returns a new Scroller instance
      def scan(query, opts = {})
        opts = {index: name}.merge opts
        client.scan query, opts
      end

      # Execute an array of searches in bulk. Results are returned in an
      # array in the order the queries were sent. The current index name
      # will be passed to the multi_search API call as part of the request
      # parameters.
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html
      #
      # params - Parameters Hash that will be passed to the API call.
      # block  - Required block that is used to accumulate searches.
      #          All the operations will be passed to the search cluster
      #          via a single API request.
      #
      # Yields a MultiSearch instance for building multi_search API call
      # bodies.
      #
      # Examples
      #
      #   index.multi_search do |m|
      #     m.search({query: {match_all: {}}, size: 0)
      #     m.search({query: {field: {"author" => "grantr"}}}, type: 'tweet')
      #     ...
      #   end
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html
      #
      # Returns the response body as a Hash
      def multi_search(params = {}, &block)
        raise "a block is required" if block.nil?

        params = {index: self.name}.merge params
        client.multi_search params, &block
      end

      # Execute an array of percolate actions in bulk. Results are returned in
      # an array in the order the actions were sent. The current index name will
      # be passed to the API call as part of the request parameters.
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html#_multi_percolate_api
      #
      # params - Optional request parameters as a Hash
      # block  - Passed to a MultiPercolate instance which assembles the
      #          percolate actions into a single request.
      #
      # Examples
      #
      #   # block form
      #   multi_percolate do |m|
      #     m.percolate({ author: "pea53" }, { type: 'default-type' })
      #     m.count({ author: "pea53" }, { type: 'type2' })
      #     ...
      #   end
      #
      # Returns the response body as a Hash
      def multi_percolate(params = {}, &block)
        params = defaults.merge params
        client.multi_percolate(params, &block)
      end

      # Delete documents by query
      def delete_by_query(query, params = nil)
        docs.send(:native_delete_by_query, query, params)
      end

      # Delete documents from one or more indices and one or more types based
      # on a query using Elasticsearch's _delete_by_query API.
      #
      # See Client#native_delete_by_query for more information.
      #
      # Returns a Hash of statistics about the delete operations as returned by
      # _delete_by_query.
      #
      # Raises Elastomer::Client::IncompatibleVersionException if this version
      # of Elasticsearch does not support _delete_by_query.
      def native_delete_by_query(query, params = nil)
        docs.native_delete_by_query(query, params)
      end

      # Update documents by query using Elasticsearch's _update_by_query API.
      #
      # See Client#update_by_query for more information.
      #
      # Returns a Hash of statistics about the update operations as returned by
      # _update_by_query.
      def update_by_query(query, params = nil)
        docs.update_by_query(query, params)
      end

      # Constructs a Percolator with the given id on this index.
      #
      # Examples
      #
      #   index.percolator "1"
      #
      # Returns a Percolator
      def percolator(id)
        Percolator.new(client, name, id)
      end

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params(params, overrides = nil)
        h = defaults.update params
        h.update overrides unless overrides.nil?
        h.delete(:type) if client.version_support.es_version_7_plus?
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { index: name }
      end

    end
  end
end
