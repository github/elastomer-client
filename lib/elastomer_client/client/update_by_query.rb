# frozen_string_literal: true

module ElastomerClient
  class Client
    # Update documents based on a query using the Elasticsearch _update_by_query API.
    #
    # query  - The query body as a Hash
    # params - Parameters Hash
    #
    # Examples
    #
    #   # request body query
    #   update_by_query({
    #     "script": {
    #       "source": "ctx._source.count++",
    #       "lang": "painless"
    #     },
    #     "query": {
    #       "term": {
    #         "user.id": "kimchy"
    #       }
    #     }
    #   })
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/8.7/docs-update-by-query.html
    #
    # Returns a Hash containing the _update_by_query response body.
    def update_by_query(query, parameters = {})
      UpdateByQuery.new(self, query, parameters).execute
    end

    class UpdateByQuery
      attr_reader :client, :query, :parameters

      def initialize(client, query, parameters)
        @client = client
        @query = query
        @parameters = parameters
      end

      def execute
        # TODO: Require index parameter. type is optional.
        updated_params = parameters.merge(body: query, action: "update_by_query", rest_api: "update_by_query")
        updated_params.delete(:type) if client.version_support.es_version_7_plus?
        response = client.post("/{index}{/type}/_update_by_query", updated_params)
        response.body
      end
    end
  end
end
