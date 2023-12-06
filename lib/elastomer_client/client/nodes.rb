# frozen_string_literal: true

module ElastomerClient
  class Client

    # Provides access to node-level API commands. The default node is set to
    # nil which target all nodes. You can pass in "_all" (to get the
    # same effect) or "_local" to target only the current node the client is
    # connected to. And you can specify an individual node or multiple nodes.
    #
    # node_id - The node ID as a String or an Array of node IDs
    #
    # Returns a Nodes instance.
    def nodes(node_id = nil)
      Nodes.new self, node_id
    end


    class Nodes
      # Create a new nodes client for making API requests that pertain to
      # the health and management individual nodes.
      #
      # client - ElastomerClient::Client used for HTTP requests to the server
      # node_id - The node ID as a String or an Array of node IDs
      #
      def initialize(client, node_id)
        @client  = client
        @node_id = node_id
      end

      attr_reader :client, :node_id

      # Retrieve one or more (or all) of the cluster nodes information. By
      # default all information is returned from all ndoes. You can select the
      # information to be returned by passing in the `:info` from the list of
      # "settings", "os", "process", "jvm", "thread_pool", "network",
      # "transport", "http" and "plugins".
      #
      # params - Parameters Hash
      #   :node_id - a single node ID or Array of node IDs
      #   :info    - a single information attribute or an Array
      #
      # Examples
      #
      #   info(info: "_all")
      #   info(info: "os")
      #   info(info: %w[os jvm process])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-info.html
      #
      # Returns the response as a Hash
      def info(params = {})
        response = client.get "/_nodes{/node_id}{/info}", update_params(params, action: "nodes.info", rest_api: "nodes.info")
        response.body
      end

      # Retrieve one or more (or all) of the cluster nodes statistics. For 1.x
      # stats filtering, use the :stats parameter key.
      #
      # params - Parameters Hash
      #   :node_id - a single node ID or Array of node IDs
      #   :stats   - a single stats value or an Array of stats values
      #
      # Examples
      #
      #   stats(stats: "thread_pool")
      #   stats(stats: %w[os process])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html
      #
      # Returns the response as a Hash
      def stats(params = {})
        response = client.get "/_nodes{/node_id}/stats{/stats}", update_params(params, action: "nodes.stats", rest_api: "nodes.stats")
        response.body
      end

      # Get the current hot threads on each node in the cluster. The return
      # value is a human formatted String - i.e. a String with newlines and
      # other formatting characters suitable for display in a terminal window.
      #
      # params - Parameters Hash
      #   :node_id  - a single node ID or Array of node IDs
      #   :threads  - number of hot threads to provide
      #   :interval - sampling interval [default is 500ms]
      #   :type     - the type to sample: "cpu", "wait", or "block"
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-hot-threads.html
      #
      # Returns the response as a String
      def hot_threads(params = {})
        response = client.get "/_nodes{/node_id}/hot_threads", update_params(params, action: "nodes.hot_threads", rest_api: "nodes.hot_threads")
        response.body
      end

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params(params, overrides = nil)
        h = { node_id: }.update params
        h.update overrides unless overrides.nil?
        h
      end

    end
  end
end
