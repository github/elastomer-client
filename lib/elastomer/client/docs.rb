
module Elastomer
  class Client

    # Provides access to document-level API commands.
    #
    # index_name - The name of the index as a String
    # type       - The document type as a String
    #
    # Returns a Docs instance.
    def docs( index_name, type = nil )
      Docs.new self, index_name, type
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
      # client     - Elastomer::Client used for HTTP requests to the server
      # index_name - The name of the index as a String
      # type       - The document type as a String
      #
      def initialize( client, index_name, type = nil )
        raise ArgumentError, 'index name cannot be nil' if index_name.nil?

        @client     = client
        @index_name = index_name
        @type       = type
      end

      attr_reader :client, :index_name, :type

      # Adds or updates a document in the index, making it searchable.
      # See http://www.elasticsearch.org/guide/reference/api/index_/
      #
      # document - The document (as a Hash) to add to the index
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def index( document, params = {} )
        overrides = from_document(document)
        overrides[:body] = document

        response = client.put '/{index}/{type}/{id}', update_params(params, overrides)
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
        response = client.get '/{index}/{type}/{id}', update_params(params)
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
        overrides[:body] = script

        response = client.put '/{index}/{type}/{id}/_update', update_params(params, overrides)
        response.body
      end


      #
      #
      def from_document( document )
        opts = {}

        %w[_id _type _routing _parent].each do |field|
          key = field.sub(/^_/, '').to_sym

          opts[key] = document.delete field if document.key? field
          opts[key] = document.delete field.to_sym if document.key? field.to_sym
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
        { :index => index_name, :type => type }
      end
    end  # Docs
  end  # Client
end  # Elastomer
