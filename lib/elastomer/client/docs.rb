
module Elastomer
  class Client

    # Provides access to document-level API commands. Indexing documents and
    # searching documents are both handled by this module.
    #
    # name - The name of the index as a String (optional)
    # type - The document type as a String (optional)
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html
    #
    # Returns a Docs instance.
    def docs( name = nil, type = nil )
      Docs.new self, name, type
    end


    class Docs
      # Create a new document client for making API requests that pertain to
      # the indexing and searching of documents in a search index.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # name   - The name of the index as a String
      # type   - The document type as a String
      #
      def initialize( client, name, type = nil )
        @client = client
        @name   = @client.assert_param_presence(name, "index name") unless name.nil?
        @type   = @client.assert_param_presence(type, "document type") unless type.nil?
      end

      attr_reader :client, :name, :type

      # Adds or updates a document in the index, making it searchable. If the
      # document contains an `:_id` attribute then PUT semantics will be used to
      # create (or update) a document with that ID. If no ID is provided then a
      # new document will be created using POST semantics.
      #
      # There are several other document attributes that control how
      # Elasticsearch will index the document. They are listed below. Please
      # refer to the Elasticsearch documentation for a full explanation of each
      # and how it affects the indexing process.
      #
      #   :_id
      #   :_type
      #   :_version
      #   :_version_type
      #   :_op_type
      #   :_routing
      #   :_parent
      #   :_timestamp
      #   :_ttl
      #   :_consistency
      #   :_replication
      #   :_refresh
      #
      # If any of these attributes are present in the document they will be
      # removed from the document before it is indexed. This means that the
      # document will be modified by this method.
      #
      # document - The document (as a Hash or JSON encoded String) to add to the index
      # params   - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html
      #
      # Returns the response body as a Hash
      def index( document, params = {} )
        overrides = from_document document
        params = update_params(params, overrides)
        params[:action] = "docs.index"

        params.delete(:id) if params[:id].nil? || params[:id].to_s =~ /\A\s*\z/

        response =
            if params[:id]
              client.put "/{index}/{type}/{id}", params
            else
              client.post "/{index}/{type}", params
            end

        response.body
      end

      # Delete a document from the index based on the document ID. The :id is
      # provided as part of the params hash.
      #
      # params - Parameters Hash
      #   :id - the ID of the document to delete
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html
      #
      # Returns the response body as a Hash
      def delete( params = {} )
        response = client.delete "/{index}/{type}/{id}", update_params(params, :action => "docs.delete")
        response.body
      end

      # Retrieve a document from the index based on its ID. The :id is
      # provided as part of the params hash.
      #
      # params - Parameters Hash
      #   :id - the ID of the document to get
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get
      #
      # Returns the response body as a Hash
      def get( params = {} )
        response = client.get "/{index}/{type}/{id}", update_params(params, :action => "docs.get")
        response.body
      end

      # Check to see if a document exists. The :id is provided as part of the
      # params hash.
      #
      # params - Parameters Hash
      #   :id - the ID of the document to check
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get
      #
      # Returns true if the document exists
      def exists?( params = {} )
        response = client.head "/{index}/{type}/{id}", update_params(params, :action => "docs.exists")
        response.success?
      end
      alias_method :exist?, :exists?

      # Retrieve the document source from the index based on the ID and type.
      # The :id is provided as part of the params hash.
      #
      # params - Parameters Hash
      #   :id - the ID of the document
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#_source
      #
      # Returns the response body as a Hash
      def source( params = {} )
        response = client.get "/{index}/{type}/{id}/_source", update_params(params, :action => "docs.source")
        response.body
      end

      # Allows you to get multiple documents based on an index, type, and id (and possibly routing).
      #
      # body   - The request body as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html
      #
      # Returns the response body as a Hash
      def multi_get( body, params = {} )
        overrides = from_document body
        overrides[:action] = "docs.multi_get"

        response = client.get "{/index}{/type}/_mget", update_params(params, overrides)
        response.body
      end
      alias_method :mget, :multi_get

      # Update a document based on a script provided.
      #
      # script - The script (as a Hash) used to update the document in place
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html
      #
      # Returns the response body as a Hash
      def update( script, params = {} )
        overrides = from_document script
        overrides[:action] = "docs.update"

        response = client.post "/{index}/{type}/{id}/_update", update_params(params, overrides)
        response.body
      end

      # Allows you to execute a search query and get back search hits that
      # match the query. This method supports both the "request body" query
      # and the "URI request" query. When using the request body semantics,
      # the query hash must contain the :query key. Otherwise we assume a URI
      # request is being made.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   # request body query
      #   search({:query => {:match_all => {}}}, :type => 'tweet')
      #
      #   # same thing but using the URI request method
      #   search(:q => '*:*', :type => 'tweet')
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-uri-request.html
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html
      #
      # Returns the response body as a hash
      def search( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.get "/{index}{/type}/_search", update_params(params, :body => query, :action => "docs.search")
        response.body
      end

      # The search shards API returns the indices and shards that a search
      # request would be executed against. This can give useful feedback for
      # working out issues or planning optimizations with routing and shard
      # preferences.
      #
      # params - Parameters Hash
      #   :routing    - routing values
      #   :preference - which shard replicas to execute the search request on
      #   :local      - boolean value to use local cluster state
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html
      #
      # Returns the response body as a hash
      def search_shards( params = {} )
        response = client.get "/{index}{/type}/_search_shards", update_params(params, :action => "docs.search_shards")
        response.body
      end

      # Executes a search query, but instead of returning results, returns
      # the number of documents matched. This method supports both the
      # "request body" query and the "URI request" query. When using the
      # request body semantics, the query hash must contain the :query key.
      # Otherwise we assume a URI request is being made.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   # request body query
      #   count({:match_all => {}}, :type => 'tweet')
      #
      #   # same thing but using the URI request method
      #   count(:q => '*:*', :type => 'tweet')
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-count.html
      #
      # Returns the response body as a Hash
      def count( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.get "/{index}{/type}/_count", update_params(params, :body => query, :action => "docs.count")
        response.body
      end

      # Delete documents from one or more indices and one or more types based
      # on a query. This method supports both the "request body" query and the
      # "URI request" query. When using the request body semantics, the query
      # hash must contain the :query key. Otherwise we assume a URI request is
      # being made.
      #
      # See Client#delete_by_query for more information.
      #
      # Returns a Hash of statistics about the delete operations
      def delete_by_query(query, params = nil)
        query, params = extract_params(query) if params.nil?

        @client.delete_by_query(query, update_params(params))
      end

      # Matches a provided or existing document to the stored percolator
      # queries. To match an existing document, pass `nil` as the body and
      # include `:id` in the params.
      #
      # Examples
      #
      #   index.percolator(1).create :query => { :match => { :author => "pea53" } }
      #   docs.percolate :doc => { :author => "pea53" }
      #   docs.percolate nil, :id => 3
      #
      # Returns the response body as a Hash
      def percolate(body, params = {})
        response = client.get "/{index}/{type}{/id}/_percolate", update_params(params, :body => body, :action => "percolator.percolate")
        response.body
      end

      # Counts the queries that match a provided or existing document. To count
      # matches for an existing document, pass `nil` as the body and include
      # `:id` in the params.
      #
      # Examples
      #
      #   index.register_percolator_query 1, :query => { :match => { :author => "pea53" } }
      #   docs.percolate_count :doc => { :author => "pea53" }
      #   docs.percolate_count nil, :id => 3
      #
      # Returns the count
      def percolate_count(body, params = {})
        response = client.get "/{index}/{type}{/id}/_percolate/count", update_params(params, :body => body, :action => "percolator.percolate_count")
        response.body["total"]
      end

      # Returns information and statistics on terms in the fields of a
      # particular document as stored in the index. The :id is provided as part
      # of the params hash.
      #
      # params - Parameters Hash
      #   :id - the ID of the document to get
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-termvectors.html
      #
      # Returns the response body as a hash
      def termvector( params = {} )
        response = client.get "/{index}/{type}/{id}/_termvector", update_params(params, :action => "docs.termvector")
        response.body
      end
      alias_method :termvectors, :termvector
      alias_method :term_vector, :termvector
      alias_method :term_vectors, :termvector

      # Multi termvectors API allows you to get multiple termvectors based on
      # an index, type and id. The response includes a docs array with all the
      # fetched termvectors, each element having the structure provided by the
      # `termvector` API.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-termvectors.html
      #
      # Returns the response body as a hash
      def multi_termvectors( body, params = {} )
        response = client.get "{/index}{/type}/_mtermvectors", update_params(params, :body => body, :action => "docs.multi_termvectors")
        response.body
      end
      alias_method :multi_term_vectors, :multi_termvectors

=begin
Percolate
=end

      # Compute a score explanation for a query and a specific document. This
      # can give useful feedback about why a document matched or didn't match
      # a query. The document :id is provided as part of the params hash.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #   :id - the ID of the document
      #
      # Examples
      #
      #   explain({:query => {:term => {"message" => "search"}}}, :id => 1)
      #
      #   explain(:q => "message:search", :id => 1)
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html
      #
      # Returns the response body as a hash
      def explain( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.get "/{index}/{type}/{id}/_explain", update_params(params, :body => query, :action => "docs.explain")
        response.body
      end

      # Validate a potentially expensive query before running it. The
      # :explain parameter can be used to get detailed information about
      # why a query failed.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   # request body query
      #   validate({:query => {:query_string => {:query => "*:*"}}}, :explain => true)
      #
      #   # same thing but using the URI query parameter
      #   validate(:q => "post_date:foo", :explain => true)
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-validate.html
      #
      # Returns the response body as a hash
      def validate( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.get "/{index}{/type}/_validate/query", update_params(params, :body => query, :action => "docs.validate")
        response.body
      end

      # Perform bulk indexing and/or delete operations. The current index name
      # and document type will be passed to the bulk API call as part of the
      # request parameters.
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
      #   docs.bulk do |b|
      #     b.index( document1 )
      #     b.index( document2 )
      #     b.delete( document3 )
      #     ...
      #   end
      #
      # Returns the response body as a Hash
      def bulk( params = {}, &block )
        raise "a block is required" if block.nil?

        params = {:index => self.name, :type => self.type}.merge params
        client.bulk params, &block
      end

      # Create a new Scroller instance for scrolling all results from a `query`.
      # The Scroller will be scoped to the current index and document type.
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
      def scroll( query, opts = {} )
        opts = {:index => name, :type => type}.merge opts
        client.scroll query, opts
      end

      # Create a new Scroller instance for scanning all results from a `query`.
      # The Scroller will be scoped to the current index and document type. The
      # Scroller is configured to use `scan` semantics which are more efficient
      # than a standard scroll query; the caveat is that the returned documents
      # cannot be sorted.
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
      #   scan = docs.scan('{"query":{"match_all":{}}}')
      #   scan.each_document do |document|
      #     document['_id']
      #     document['_source']
      #   end
      #
      # Returns a new Scroller instance
      def scan( query, opts = {} )
        opts = {:index => name, :type => type}.merge opts
        client.scan query, opts
      end

      # Execute an array of searches in bulk. Results are returned in an
      # array in the order the queries were sent. The current index name
      # and document type will be passed to the multi_search API call as
      # part of the request parameters.
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
      #   docs.multi_search do |m|
      #     m.search({:query => {:match_all => {}}, :size => 0)
      #     m.search({:query => {:field => {"foo" => "bar"}}})
      #     ...
      #   end
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html
      #
      # Returns the response body as a Hash
      def multi_search( params = {}, &block )
        raise "a block is required" if block.nil?

        params = {:index => self.name, :type => self.type}.merge params
        client.multi_search params, &block
      end

      # Execute an array of percolate actions in bulk. Results are returned in
      # an array in the order the actions were sent. The current index name and
      # type will be passed to the API call as part of the request parameters.
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
      #     m.percolate(:author => "pea53")
      #     m.count(:author => "grantr")
      #     ...
      #   end
      #
      # Returns the response body as a Hash
      def multi_percolate(params = {}, &block)
        params = defaults.merge params
        client.multi_percolate(params, &block)
      end

      SPECIAL_KEYS = %w[index type id version version_type op_type routing parent timestamp ttl consistency replication refresh].freeze
      SPECIAL_KEYS_HASH = SPECIAL_KEYS.inject({}) { |h, k| h[k.to_sym] = "_#{k}"; h }.freeze

      # Internal: Given a `document` generate an options hash that will
      # override parameters based on the content of the document. The document
      # will be returned as the value of the :body key.
      #
      # We only extract information from the document if it is given as a
      # Hash. We do not parse JSON encoded Strings.
      #
      # document - A document Hash or JSON encoded String.
      #
      # Returns an options Hash extracted from the document.
      def from_document( document )
        opts = {:body => document}

        if document.is_a? Hash
          SPECIAL_KEYS_HASH.each do |key, field|
            opts[key] = document.delete field if document.key? field
            opts[key] = document.delete field.to_sym if document.key? field.to_sym
          end
        end

        opts
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
        h[:routing] = h[:routing].join(",") if Array === h[:routing]
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :index => name, :type => type }
      end

      # Internal: Allow params to be passed as the first argument to
      # methods that take both an optional query hash and params.
      #
      # query  - query hash OR params hash
      # params - params hash OR nil if no query
      #
      # Returns an array of the query (possibly nil) and params Hash.
      def extract_params( query, params = nil )
        if params.nil?
          if query.key? :query
            params = {}
          else
            params, query = query, nil
          end
        end
        [query, params]
      end

    end
  end
end
