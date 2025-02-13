# frozen_string_literal: true

module ElastomerClient
  class Client

    # Returns a CCR instance
    def ccr
      Ccr.new(self)
    end

    class Ccr
      # Create a new Ccr for initiating requests for cross cluster replication.
      # More context: https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-apis.html
      #
      # client     - ElastomerClient::Client used for HTTP requests to the server
      def initialize(client)
        @client = client
      end

      attr_reader :client

      # Creates a new follower index for the provided leader index on the remote cluster.
      #
      # follower_index - String name of the follower index to create
      # body           - Hash of the request body
      #   :remote_cluster - String name of the remote cluster. Required.
      #   :leader_index   - String name of the leader index. Required.
      # params         - Hash of query parameters
      #
      # Examples
      #
      #   ccr.follow("follower_index", { leader_index: "leader_index", remote_cluster: "leader" })
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-follow.html
      def follow(follower_index, body, params = {})
        response = client.put "/#{follower_index}/_ccr/follow", params.merge(body:, action: "follow", rest_api: "ccr")
        response.body
      end

      # Creates a new auto-follow pattern for the provided remote cluster.
      #
      # pattern_name - String name of the auto-follow pattern to create
      # body         - Hash of the request body
      #   :remote_cluster - String name of the remote cluster. Required.
      #   :leader_index_patterns - An array of simple index patterns to match against indices in the remote cluster
      #   :leader_index_exclusion_patterns - An array of simple index patterns that can be used to exclude indices from being auto-followed.
      #   :follow_index_pattern - The name of follower index. The template {{leader_index}} can be used to derive
      #                           the name of the follower index from the name of the leader index.
      # params       - Hash of query parameters

      # Examples

      #   ccr.auto_follow("follower_pattern", { remote_cluster: "leader", leader_index_patterns: ["leader_index*"],
      #                                         follow_index_pattern: "{{leader_index}}-follower" })

      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-auto-follow-pattern.html

      def auto_follow(pattern_name, body, params = {})
        response = client.put "/_ccr/auto_follow/#{pattern_name}", params.merge(body: body, action: "create_auto_follow_pattern", rest_api: "ccr")
        response.body
      end

      # Deletes the auto-follow pattern for the provided remote cluster.
      #
      # pattern_name - String name of the auto-follow pattern to delete
      # params       - Hash of query parameters
      #
      # Examples
      #
      #   ccr.delete_auto_follow("follower_pattern")
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-delete-auto-follow-pattern.html

      def delete_auto_follow(pattern_name, params = {})
        response = client.delete "/_ccr/auto_follow/#{pattern_name}", params.merge(action: "delete_auto_follow_pattern", rest_api: "ccr")
        response.body
      end

      # Gets cross-cluster replication auto-follow patterns
      #
      # params - Hash of query parameters
      #   :pattern_name - (Optional) String name of the auto-follow pattern. Returns all patterns if not specified
      # Examples
      #
      #   ccr.get_auto_follow
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-auto-follow-pattern.html

      def get_auto_follow(params = {})
        response = client.get "/_ccr/auto_follow{/pattern_name}", params.merge(action: "get_auto_follow_pattern", rest_api: "ccr")
        response.body
      end
    end
  end
end
