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

      # Simple status on the health of the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-health/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def health( params = {} )
        response = client.get '/_cluster/health{/index}', params.merge(:action => 'cluster.health')
        response.body
      end

      # Comprehensive state information of the whole cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-state/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def state( params = {} )
        response = client.get '/_cluster/state{/metrics}{/indices}', params.merge(:action => 'cluster.state')
        response.body
      end

      # Cluster wide settings that have been modified via the update API.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-update-settings/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def get_settings( params = {} )
        response = client.get '/_cluster/settings', params.merge(:action => 'cluster.get_settings')
        response.body
      end
      alias :settings :get_settings

      # Update cluster wide specific settings. Settings updated can either be
      # persistent (applied cross restarts) or transient (will not survive a
      # full cluster restart).
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-update-settings/
      #
      # body   - The new settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def update_settings( body, params = {} )
        response = client.put '/_cluster/settings', params.merge(:body => body, :action => 'cluster.update_settings')
        response.body
      end

      # Explicitly execute a cluster reroute allocation command. For example,
      # a shard can be moved from one node to another explicitly, an
      # allocation can be canceled, or an unassigned shard can be explicitly
      # allocated on a specific node.
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-reroute/
      #
      # commands - A command Hash or an Array of command Hashes
      # params   - Parameters Hash
      #
      # Examples
      #
      #   reroute(:move => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' })
      #
      #   reroute([
      #     { :move     => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' }},
      #     { :allocate => { :index => 'test', :shard => 1, :node => 'node3' }}
      #   ])
      #
      # Returns the response as a Hash
      def reroute( commands, params = {} )
        commands = [commands] unless Array === commands
        body = {:commands => commands}

        response = client.post '/_cluster/reroute', params.merge(:body => body, :action => 'cluster.reroute')
        response.body
      end

      # Shutdown the entire cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-shutdown/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def shutdown( params = {} )
        response = client.post '/_shutdown', params.merge(:action => 'cluster.shutdown')
        response.body
      end

      # Retrieve the current aliases. An :index name can be given (or an
      # array of index names) to get just the aliases for those indexes. You
      # can also use the alias name here since it is acting the part of an
      # index.
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/
      #
      # params - Parameters Hash
      #
      # Examples
      #
      #   get_aliases
      #   get_aliases( :index => 'users' )
      #
      # Returns the response body as a Hash
      def get_aliases( params = {} )
        response = client.get '{/index}/_aliases', params.merge(:action => 'cluster.get_aliases')
        response.body
      end
      alias :aliases :get_aliases

      # Perform an aliases action on the cluster. We are just a teensy bit
      # clever here in that a single action can be given or an array of
      # actions. This API method will wrap the request in the appropriate
      # {:actions => [...]} body construct.
      #
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/
      #
      # actions - An action Hash or an Array of action Hashes
      # params  - Parameters Hash
      #
      # Examples
      #
      #   update_aliases(:add => { :index => 'users-1', :alias => 'users' })
      #
      #   update_aliases([
      #     { :remove => { :index => 'users-1', :alias => 'users' }},
      #     { :add    => { :index => 'users-2', :alias => 'users' }}
      #   ])
      #
      # Returns the response body as a Hash
      def update_aliases( actions, params = {} )
        if actions.is_a?(Hash) && actions.key?(:actions)
          body = actions
        elsif actions.is_a?(Hash)
          # Array() on a Hash does not do what you think it does - that is why
          # we are explicitly wrapping the Hash via [actions] here.
          body = {:actions => [actions]}
        else
          body = {:actions => Array(actions)}
        end

        response = client.post '/_aliases', params.merge(:body => body, :action => 'cluster.update_aliases')
        response.body
      end

      # List all templates currently defined. This is just a convenience method
      # around the `state` call that extracts and returns the templates section.
      #
      # Returns the template definitions as a Hash
      def templates
        # ES 1.x supports state filtering via a path segment called metrics.
        # ES 0.90 uses query parameters instead.
        if client.semantic_version >= '1.0.0'
          h = state(:metrics => 'metadata')
        else
          h = state(
            :filter_blocks        => true,
            :filter_nodes         => true,
            :filter_routing_table => true,
          )
        end
        h['metadata']['templates']
      end

      # List all indices currently defined. This is just a convenience method
      # around the `state` call that extracts and returns the indices section.
      #
      # Returns the indices definitions as a Hash
      def indices
        # ES 1.x supports state filtering via a path segment called metrics.
        # ES 0.90 uses query parameters instead.
        if client.semantic_version >= '1.0.0'
          h = state(:metrics => 'metadata')
        else
          h = state(
            :filter_blocks        => true,
            :filter_nodes         => true,
            :filter_routing_table => true,
          )
        end
        h['metadata']['indices']
      end

      # List all nodes currently part of the cluster. This is just a convenience
      # method around the `state` call that extracts and returns the nodes
      # section.
      #
      # Returns the nodes definitions as a Hash
      def nodes
        # ES 1.x supports state filtering via a path segment called metrics.
        # ES 0.90 uses query parameters instead.
        if client.semantic_version >= '1.0.0'
          h = state(:metrics => 'nodes')
        else
          h = state(
            :filter_blocks        => true,
            :filter_metadata      => true,
            :filter_routing_table => true,
          )
        end
        h['nodes']
      end

    end
  end
end
