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

      # Pauses a follower index.
      #
      # follower_index - String name of the follower index to create
      # body           - Hash of the request body
      #   :master_timeout - String in the time units. Optional.
      #     see https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#time-units
      #
      # Examples
      #   ccr.pause_follow("follower_index")
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-pause-follow.html
      def pause_follow(follower_index, body = {}, params = {})
        response = client.post "/#{follower_index}/_ccr/pause_follow", params.merge(body:, action: "pause_follow", rest_api: "ccr")
        response.body
      end
    end
  end
end
