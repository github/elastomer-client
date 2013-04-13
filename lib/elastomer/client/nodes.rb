
module Elastomer
  class Client

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
        response = client.get '/_nodes{/node_id}', defaults(params)
        response.body
      end

      # Retrieve one or more (or all) of the cluster nodes statistics.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-stats/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def stats( params = {} )
        response = client.get '/_nodes{/node_id}/stats', defaults(params)
        response.body
      end

      # Get the current hot threads on each node in the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-hot-threads/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def hot_threads( params = {} )
        response = client.get '/_nodes{/node_id}/hot_threads', defaults(params)
        response.body
      end

      # Shutdown one or more nodes in the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-shutdown/
      #
      # params - Parameters Hash
      #
      # Returns the response as a Hash
      def shutdown( params = {} )
        response = client.post '/_cluster/nodes{/node_id}/_shutdown', defaults(params)
        response.body
      end

      # Internal: Append default parameters to the given `params` Hash.
      #
      # params - Parameters Hash
      #
      # Returns a new params Hash.
      def defaults( params )
        { :node_id => node_id }.merge! params
      end
    end

    # Provides access to node-level API commands.
    #
    # node_id - The node ID as a String or an Array of node IDs
    #
    # Returns a Nodes instance.
    def nodes( node_id = '_all' )
      Nodes.new self, node_id
    end

  end  # Client
end  # Elastomer
