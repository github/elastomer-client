module Elastomer
  class Client

    # Returns a Cluster instance.
    def cluster
      @cluster ||= Cluster.new self
    end

    class Cluster

      # Create a new cluster client for making API requests that pertain to
      # the cluster health and management.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      #
      def initialize( client )
        @client = client
      end

      attr_reader :client

      # Simple status on the health of the cluster. The API can also be executed
      # against one or more indices to get just the specified indices health.
      #
      # params - Parameters Hash
      #   :index - a single index name or an Array of index names
      #   :level - one of "cluster", "indices", or "shards"
      #   :wait_for_status - one of "green", "yellow", or "red"
      #   :wait_for_relocating_shards - a number controlling to how many relocating shards to wait for
      #   :wait_for_nodes - the request waits until the specified number N of nodes is available
      #   :timeout - how long to wait [default is "30s"]
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html
      #
      # Returns the response as a Hash
      def health( params = {} )
        response = client.get "/_cluster/health{/index}", params.merge(action: "cluster.health")
        response.body
      end

      # Comprehensive state information of the whole cluster. For 1.x metric
      # and index filtering, use the :metrics and :indices parameter keys.
      #
      # The list of available metrics are:
      #   version, master_node, nodes, routing_table, metadata, blocks
      #
      # params - Parameters Hash
      #   :metrics - list of metrics to select as an Array
      #   :indices - a single index name or an Array of index names
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-state.html
      #
      # Returns the response as a Hash
      def state( params = {} )
        response = client.get "/_cluster/state{/metrics}{/indices}", params.merge(action: "cluster.state")
        response.body
      end

      # Retrieve statistics from a cluster wide perspective. The API returns
      # basic index metrics (shard numbers, store size, memory usage) and
      # information about the current nodes that form the cluster (number,
      # roles, os, jvm versions, memory usage, cpu and installed plugins).
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-stats.html
      #
      # Returns the response as a Hash
      def stats( params = {} )
        response = client.get "/_cluster/stats", params.merge(action: "cluster.stats")
        response.body
      end

      # Returns a list of any cluster-level changes (e.g. create index, update
      # mapping, allocate or fail shard) which have not yet been executed.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-pending.html
      #
      # Returns the response as a Hash
      def pending_tasks( params = {} )
        response = client.get "/_cluster/pending_tasks", params.merge(action: "cluster.pending_tasks")
        response.body
      end

      # Returns `true` if there items in the pending task list. Returns `false`
      # if the pending task list is empty. Returns `nil` if the response body
      # does not contain the "tasks" field.
      def pending_tasks?
        hash = pending_tasks
        return nil unless hash.key? "tasks"
        hash["tasks"].length > 0
      end

      # Cluster wide settings that have been modified via the update API.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html
      #
      # Returns the response as a Hash
      def get_settings( params = {} )
        response = client.get "/_cluster/settings", params.merge(action: "cluster.get_settings")
        response.body
      end
      alias_method :settings, :get_settings

      # Update cluster wide specific settings. Settings updated can either be
      # persistent (applied cross restarts) or transient (will not survive a
      # full cluster restart).
      #
      # body   - The new settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html
      #
      # Returns the response as a Hash
      def update_settings( body, params = {} )
        response = client.put "/_cluster/settings", params.merge(body: body, action: "cluster.update_settings")
        response.body
      end

      # Explicitly execute a cluster reroute allocation command. For example,
      # a shard can be moved from one node to another explicitly, an
      # allocation can be canceled, or an unassigned shard can be explicitly
      # allocated on a specific node.
      #
      # commands - A command Hash or an Array of command Hashes
      # params   - Parameters Hash
      #
      # Examples
      #
      #   reroute(move: { index: 'test', shard: 0, from_node: 'node1', to_node: 'node2' })
      #
      #   reroute([
      #     { move:     { index: 'test', shard: 0, from_node: 'node1', to_node: 'node2' }},
      #     { allocate: { index: 'test', shard: 1, node: 'node3' }}
      #   ])
      #
      #   reroute(commands: [
      #     { move:     { index: 'test', shard: 0, from_node: 'node1', to_node: 'node2' }},
      #     { allocate: { index: 'test', shard: 1, node: 'node3' }}
      #   ])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-reroute.html
      #
      # Returns the response as a Hash
      def reroute( commands, params = {} )
        if commands.is_a?(Hash) && commands.key?(:commands)
          body = commands
        elsif commands.is_a?(Hash)
          # Array() on a Hash does not do what you think it does - that is why
          # we are explicitly wrapping the Hash via [commands] here.
          body = {commands: [commands]}
        else
          body = {commands: Array(commands)}
        end

        response = client.post "/_cluster/reroute", params.merge(body: body, action: "cluster.reroute")
        response.body
      end

      # Shutdown the entire cluster. There is also a Nodes#shutdown method for
      # shutting down individual nodes.
      #
      # params - Parameters Hash
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-shutdown.html
      #
      # Returns the response as a Hash
      def shutdown( params = {} )
        response = client.post "/_shutdown", params.merge(action: "cluster.shutdown")
        response.body
      end

      # Retrieve the current aliases. An :index name can be given (or an
      # array of index names) to get just the aliases for those indexes. You
      # can also use the alias name here since it is acting the part of an
      # index.
      #
      # params - Parameters Hash
      #   :index - an index name or Array of index names
      #
      # Examples
      #
      #   get_aliases
      #   get_aliases( index: 'users' )
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def get_aliases( params = {} )
        response = client.get "{/index}/_aliases", params.merge(action: "cluster.get_aliases")
        response.body
      end
      alias_method :aliases, :get_aliases

      # Perform an aliases action on the cluster. We are just a teensy bit
      # clever here in that a single action can be given or an array of
      # actions. This API method will wrap the request in the appropriate
      # {actions: [...]} body construct.
      #
      # actions - An action Hash or an Array of action Hashes
      # params  - Parameters Hash
      #
      # Examples
      #
      #   update_aliases(add: { index: 'users-1', alias: 'users' })
      #
      #   update_aliases([
      #     { remove: { index: 'users-1', alias: 'users' }},
      #     { add:    { index: 'users-2', alias: 'users' }}
      #   ])
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html
      #
      # Returns the response body as a Hash
      def update_aliases( actions, params = {} )
        if actions.is_a?(Hash) && actions.key?(:actions)
          body = actions
        elsif actions.is_a?(Hash)
          # Array() on a Hash does not do what you think it does - that is why
          # we are explicitly wrapping the Hash via [actions] here.
          body = {actions: [actions]}
        else
          body = {actions: Array(actions)}
        end

        response = client.post "/_aliases", params.merge(body: body, action: "cluster.update_aliases")
        response.body
      end

      # List all templates currently defined. This is just a convenience method
      # around the `state` call that extracts and returns the templates section.
      #
      # Returns the template definitions as a Hash
      def templates
        state(metrics: "metadata").dig("metadata", "templates")
      end

      # List all indices currently defined. This is just a convenience method
      # around the `state` call that extracts and returns the indices section.
      #
      # Returns the indices definitions as a Hash
      def indices
        state(metrics: "metadata").dig("metadata", "indices")
      end

      # List all nodes currently part of the cluster. This is just a convenience
      # method around the `state` call that extracts and returns the nodes
      # section.
      #
      # Returns the nodes definitions as a Hash
      def nodes
        state(metrics: "nodes").dig("nodes")
      end

    end
  end
end
