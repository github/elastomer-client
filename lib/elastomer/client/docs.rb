
module Elastomer
  class Client

    # Provides access to document-level API commands.
    #
    # name - The name of the index as a String
    # type - The document type as a String
    #
    # Returns a Docs instance.
    def docs( name, type = nil )
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
        @name   = @client.assert_param_presence(name, 'index name')
        @type   = @client.assert_param_presence(type, 'document type') unless type.nil?
      end

      attr_reader :client, :name, :type

      # Adds or updates a document in the index, making it searchable.
      # See http://www.elasticsearch.org/guide/reference/api/index_/
      #
      # document - The document (as a Hash or JSON encoded String) to add to the index
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def index( document, params = {} )
        overrides = from_document(document)
        params = update_params(params, overrides)
        params[:action] = 'document.index'

        params.delete(:id) if params[:id].nil? || params[:id].to_s =~ /\A\s*\z/

        response =
            if params[:id]
              client.put '/{index}/{type}/{id}', params
            else
              client.post '/{index}/{type}', params
            end

        response.body
      end
      alias :add :index

      # Delete a document from the index based on the document ID. The :id is
      # provided as part of the params hash.
      #
      # See http://www.elasticsearch.org/guide/reference/api/delete/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete( params = {} )
        response = client.delete '/{index}/{type}/{id}', update_params(params, :action => 'document.delete')
        response.body
      end

      # Retrieve a document from the index based on its ID. The :id is
      # provided as part of the params hash.
      #
      # See http://www.elasticsearch.org/guide/reference/api/get/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def get( params = {} )
        response = client.get '/{index}/{type}/{id}', update_params(params, :action => 'document.get')
        response.body
      end

      # Retrieve the document source from the index based on the ID and type.
      # The :id is provided as part of the params hash.
      #
      # See http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html#_source
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def source( params = {} )
        response = client.get '/{index}/{type}/{id}/_source', update_params(params, :action => 'document.source')
        response.body
      end

      # Allows to get multiple documents based on an index, type, and id (and possibly routing).
      # See http://www.elasticsearch.org/guide/reference/api/multi-get/
      #
      # docs   - The Hash describing the documents to get
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def multi_get( docs, params = {} )
        overrides = from_document(docs)
        overrides[:action] = 'mget'

        response = client.get '{/index}{/type}{/id}/_mget', update_params(params, overrides)
        response.body
      end

      # Update a document based on a script provided.
      # See http://www.elasticsearch.org/guide/reference/api/update/
      #
      # script - The script (as a Hash) used to update the document in place
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update( script, params = {} )
        overrides = from_document(script)
        overrides[:action] = 'document.update'

        response = client.post '/{index}/{type}/{id}/_update', update_params(params, overrides)
        response.body
      end

      # Allows you to execute a search query and get back search hits that
      # match the query. This method supports both the "request body" query
      # and the "URI request" query. When using the request body semantics,
      # the query hash must contain the :query key. Otherwise we assume a URI
      # request is being made.
      #
      # See http://www.elasticsearch.org/guide/reference/api/search/
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
      # Returns the response body as a hash
      def search( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.get '/{index}{/type}/_search', update_params(params, :body => query, :action => 'search')
        response.body
      end

      # Executes a search query, but instead of returning results, returns
      # the number of documents matched. This method supports both the
      # "request body" query and the "URI request" query. When using the
      # request body semantics, the query hash must contain the :query key.
      # Otherwise we assume a URI request is being made.
      #
      # See http://www.elasticsearch.org/guide/reference/api/count/
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
      # Returns the response body as a Hash
      def count(query, params = nil)
        query, params = extract_params(query) if params.nil?

        response = client.get '/{index}{/type}/_count', update_params(params, :body => query)
        response.body
      end

      # Delete documents from one or more indices and one or more types based
      # on a query. This method supports both the "request body" query and the
      # "URI request" query. When using the request body semantics, the query
      # hash must contain the :query key. Otherwise we assume a URI request is
      # being made.
      #
      # See http://www.elasticsearch.org/guide/reference/api/delete-by-query/
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   # request body query
      #   delete_by_query({:query => {:match_all => {}}}, :type => 'tweet')
      #
      #   # same thing but using the URI request method
      #   delete_by_query(:q => '*:*', :type => 'tweet')
      #
      # Returns the response body as a hash
      def delete_by_query( query, params = nil )
        query, params = extract_params(query) if params.nil?

        response = client.delete '/{index}{/type}/_query', update_params(params, :body => query, :action => 'delete_by_query')
        response.body
      end

=begin
Percolate
=end

      # Search for documents similar to a specific document. The document
      # :id is provided as part of the params hash. If the _all field is
      # not enabled, :mlt_fields must be passed. A query cannot be present
      # in the query body, but other fields like :size and :facets are
      # allowed.
      #
      # See http://www.elasticsearch.org/guide/reference/api/more-like-this/
      #
      # params - Parameters Hash
      #
      # Examples
      #
      #   more_like_this(:mlt_fields => "title", :min_term_freq => 1, :type => "doc1", :id => 1)
      #
      #   # with query hash
      #   more_like_this({:from => 5, :size => 10}, :mlt_fields => "title",
      #                   :min_term_freq => 1, :type => "doc1", :id => 1)
      #
      # Returns the response body as a hash
      def more_like_this(query, params = nil)
        query, params = extract_params(query) if params.nil?

        response = client.get '/{index}/{type}/{id}/_mlt', update_params(params, :body => query)
        response.body
      end

      # Compute a score explanation for a query and a specific document. This
      # can give useful feedback about why a document matched or didn't match
      # a query. The document :id is provided as part of the params hash.
      #
      # See http://www.elasticsearch.org/guide/reference/api/explain/
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   explain({:query => {:term => {"message" => "search"}}}, :id => 1)
      #
      #   explain(:q => "message:search", :id => 1)
      #
      # Returns the response body as a hash
      def explain(query, params = nil)
        query, params = extract_params(query) if params.nil?

        response = client.get '/{index}/{type}/{id}/_explain', update_params(params, :body => query)
        response.body
      end

      # Validate a potentially expensive query before running it. The
      # :explain parameter can be used to get detailed information about
      # why a query failed.
      #
      # See http://www.elasticsearch.org/guide/reference/api/validate/
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      # 
      #   # request body query
      #   validate(:query_string => {:query => "*:*"})
      #
      #   # same thing but using the URI query parameter
      #   validate({:q => "post_date:foo"}, :explain => true)
      #
      # Returns the response body as a hash
      def validate(query, params = nil)
        query, params = extract_params(query) if params.nil?
        
        response = client.get '/{index}{/type}/_validate/query', update_params(params, :body => query)
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
        raise 'a block is required' if block.nil?

        params = {:index => self.name, :type => self.type}.merge params
        client.bulk params, &block
      end

      # Create a new Scan instance for scrolling all results from a `query`.
      # The Scan will be scoped to the current index and document type.
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
      # Returns a new Scan instance
      def scan( query, opts = {} )
        opts = {:index => name, :type => type}.merge opts
        client.scan query, opts
      end

      # Execute an array of searches in bulk. Results are returned in an
      # array in the order the queries were sent. The current index name
      # and document type will be passed to the multi_search API call as
      # part of the request parameters.
      #
      # See http://www.elasticsearch.org/guide/reference/api/multi-search/
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
      #     m.search({:query => {:match_all => {}}, :search_type => :count)
      #     m.search({:query => {:field => {"foo" => "bar"}}})
      #     ...
      #   end
      #
      # Returns the response body as a Hash
      def multi_search(params = {}, &block)
        raise 'a block is required' if block.nil?

        params = {:index => self.name, :type => self.type}.merge params
        client.multi_search params, &block
      end

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

        unless String === document
          %w[_id _type _routing _parent _ttl _timestamp _retry_on_conflict].each do |field|
            key = field.sub(/^_/, '').to_sym

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
        h[:routing] = h[:routing].join(',') if Array === h[:routing]
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
      def extract_params(query, params=nil)
        if params.nil?
          if query.key? :query
            params = {}
          else
            params, query = query, nil
          end
        end
        [query, params]
      end

    end  # Docs
  end  # Client
end  # Elastomer
