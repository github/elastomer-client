
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

    class Index
      # Provides access to document-level API commands.
      #
      # type - The document type as a String
      #
      # Returns a Docs instance.
      def docs( type = nil )
        Docs.new client, name, type
      end
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
        raise ArgumentError, 'index name cannot be nil' if name.nil?

        @client = client
        @name   = name
        @type   = type
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

        response =
            if params.key? :id
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
        response = client.delete '/{index}/{type}/{id}', update_params(params)
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
        response = client.get '/{index}/{type}/{id}', update_params(params, :accept => 404)
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
        response = client.put '/{index}/{type}/{id}/_update', update_params(params, overrides)
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
      #   search({:query => {:match_all => {}}}, :type => 'tweet', :search_type => 'count')
      #
      #   # same thing but using the URI request method
      #   search(:q => '*:*', :type => 'tweet', :search_type => 'count')
      #
      # Returns the response body as a hash
      def search( query, params = nil )
        if params.nil?
          if query.key? :query
            params = {}
          else
            params, query = query, nil
          end
        end

        response = client.get '/{index}{/type}/_search', update_params(params, :body => query)
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
        if params.nil?
          if query.key? :query
            params = {}
          else
            params, query = query, nil
          end
        end

        response = client.delete '/{index}{/type}/_query', update_params(params, :body => query)
        response.body
      end


=begin
Multi Search
Percolate
Bulk UDP
Count
More Like This
Validate
Explain
=end

      #
      #
      def from_document( document )
        opts = {:body => document}

        unless String === document
          %w[_id _type _routing _parent].each do |field|
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
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :index => name, :type => type }
      end
    end  # Docs
  end  # Client
end  # Elastomer
