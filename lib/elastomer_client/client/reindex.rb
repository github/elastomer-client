# frozen_string_literal: true

module ElastomerClient
  class Client

    # Returns a Reindex instance
    def reindex
      Reindex.new(self)
    end

    class Reindex
      # Create a new Reindex for initiating reindex tasks.
      # More context: https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html
      #
      # client     - ElastomerClient::Client used for HTTP requests to the server
      def initialize(client)
        @client = client
      end

      attr_reader :client

      def reindex(body, params = {})
        response = client.post "/_reindex", params.merge(body:, action: "reindex", rest_api: "reindex")
        response.body
      end

      def rethrottle(task_id, params = {})
        response = client.post "/_reindex/#{task_id}/_rethrottle", params.merge(action: "rethrottle", rest_api: "reindex")
        response.body
      end

    end
  end
end
