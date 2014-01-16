module Elastomer
  class Index
    extend Forwardable

    attr_accessor :index

    def_delegators :@index,
      :name, :client, :exists?, :delete, :mapping, :settings, :refresh,
      :open, :close, :analyze, :bulk, :scan, :docs

    def initialize(index = nil)
      @index = index
    end

    #TODO aliases (forward to client when aliases block is implemented)

    # Create the index on the ElasticSearch cluster. If the class method
    # `mappings` exists it will be called and the returned value will be used
    # as the document type mappings for the index. Likewise, if the class
    # method `settings` exists it will be called and the returned value will
    # be used for the index settings during creation.
    #
    # opts - The options Hash
    #        :mappings - the Hash containing the document type mappings
    #        :settings - the Hash containing the index settings
    #
    # Returns the create operation result Hash from the ElasticSearch cluster.
    def create(options = {})
      options = { :mappings => mappings, :settings => settings}.merge(options)
      @index.create(options)
    end

    # Returns the mapping for this index as a Hash.
    def mappings
      {}
    end

    # Returns the settings for this index as a Hash.
    def settings
      {}
    end

    # Perform a search request using the `query` document and the `params` hash.
    #
    # query  - The query Hash or JSON String
    # params - The request params Hash
    #          :type    - A single type String or an Array of type Strings
    #          :routing - A single routing String or an Array of routing Strings
    #          :search_type - The type of search to perform
    #
    # See the ElasticSearch documentation
    # (http://www.elasticsearch.org/guide/reference/api/search/search-type.html)
    # for an explanation of the search type.
    #
    # Returns a Hash containing the search results.
    # Raises an Elastomer::Client::Error upon failure.
    def search(query, params = {})
      @index.docs.search(query, params)
    end

    # Count the number of documents in the search index that match the given
    # query. Note this actually calls the search api with search_type = count
    # instead of using the count api.
    #
    # query  - The query Hash or JSON String.
    # params - The request params Hash.
    #          :type    - A single type String or an Array of type Strings
    #          :routing - A single routing String or an Array of routing Strings
    #
    # Returns the number of matching documents.
    # Raises a Elastomer::Client::Error upon failure.
    def count(query, params = {})
      params[:search_type] = :count
      result = search(query, params)
      result['hits']['total'].to_i
    end

    #TODO store/remove
    def store(document)
      docs.index(document)
    end

    # Delete all documents from the index.
    #
    # type - an optional type to restrict the truncation
    #
    # Returns the response body as a Hash.
    def truncate(type = nil)
      #ES1.0 change the query body to use :query
      docs(type).delete_by_query(:match_all => {})
    end

    module Naming
      # logical name should, by default, be the demodulized class name.
      # physical name should, by default, be the logical name.
      # TODO can avoid activesupport here with simpler defaults, or an easier way
      # to specify the logical name at the class level.
      require 'active_support/inflector'
      def logical_name
        name.demodulize.downcase
      end

      def physical_name
        logical_name
      end
    end
    extend Naming

    module Routing
      def register_as(name=logical_name)
        Elastomer.router.register_index_class(name, self)
      end
    end
    extend Routing
  end
end
