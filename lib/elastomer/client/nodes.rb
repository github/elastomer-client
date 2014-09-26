
module Elastomer
  class Client

    # Provides access to node-level API commands.
    #
    # node_id - The node ID as a String or an Array of node IDs
    #
    # Returns a Nodes instance.
    def nodes( node_id = '_all' )
      Nodes.new self, node_id
    end


    class Nodes
      # Create a new nodes client for making API requests that pertain to
      # the health and management individual nodes.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # node_id - The node ID as a String or an Array of node IDs
      #
      def initialize( client, node_id )
        @client  = client
        @node_id = node_id
      end

      attr_reader :client, :node_id

      # Retrieve one or more (or all) of the cluster nodes information.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-info/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def info( params = {} )
        response = client.get '/_nodes{/node_id}', update_params(params, :action => 'nodes.info')
        response.body
      end

      # Retrieve one or more (or all) of the cluster nodes statistics. For 1.x
      # stats filtering, use the :stats parameter key.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-stats/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def stats( params = {} )
        response = client.get '/_nodes{/node_id}/stats{/stats}', update_params(params, :action => 'nodes.stats')
        response.body
      end

      # Get the current hot threads on each node in the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-hot-threads/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def hot_threads( params = {} )
        response = client.get '/_nodes{/node_id}/hot_threads', update_params(params, :action => 'nodes.hot_threads')
        response.body
      end

      # Shutdown one or more nodes in the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-shutdown/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def shutdown( params = {} )
        response = client.post '/_cluster/nodes{/node_id}/_shutdown', update_params(params, :action => 'nodes.shutdown')
        response.body
      end

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params( params, overrides = nil )
        h = { :node_id => node_id }.update params
        h.update overrides unless overrides.nil?
        h
      end
    end  # Nodes
  end  # Client
end  # Elastomer
