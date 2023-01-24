# frozen_string_literal: true

module Elastomer
  class Client
    # Delete documents based on a query using the Elasticsearch _delete_by_query API.
    #
    # query  - The query body as a Hash
    # params - Parameters Hash
    #
    # Examples
    #
    #   # request body query
    #   native_delete_by_query({query: {match_all: {}}}, type: 'tweet')
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/5.6/docs-delete-by-query.html
    #
    # Returns a Hash containing the _delete_by_query response body.
    def native_delete_by_query(query, parameters = {})
      NativeDeleteByQuery.new(self, query, parameters).execute
    end

    class NativeDeleteByQuery
      attr_reader :client, :query, :parameters

      def initialize(client, query, parameters)
        unless client.version_support.native_delete_by_query?
          raise IncompatibleVersionException, "Elasticsearch '#{client.version}' does not support _delete_by_query"
        end

        @client = client
        @query = query
        @parameters = parameters
      end

      def execute
        # TODO: Require index parameter. type is optional.
        updated_params = parameters.merge(body: query, action: "delete_by_query", rest_api: "delete_by_query")
        updated_params.delete(:type) if client.version_support.es_version_8_plus?
        response = client.post("/{index}{/type}/_delete_by_query", updated_params)
        response.body
      end
    end
  end
end
