module Elastomer
  class Client

    # Provides access to snapshot API commands.
    #
    # repository - The name of the repository as a String
    # name       - The name of the snapshot as a String
    #
    # Returns a Snapshot instance.
    def snapshot(repository = nil, name = nil)
      Snapshot.new self, repository, name
    end

    class Snapshot
      # Create a new snapshot object for making API requests that pertain to
      # creating, restoring, deleting, and retrieving snapshots.
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      # repository - The name of the repository as a String. Cannot be nil if
      #              snapshot name is not nil.
      # name       - The name of the snapshot as a String
      def initialize(client, repository = nil, name = nil)
        @client     = client
        # don't allow nil repository if snapshot name is not nil
        @repository = @client.assert_param_presence(repository, "repository name") unless repository.nil? && name.nil?
        @name       = @client.assert_param_presence(name, "snapshot name") unless name.nil?
      end

      attr_reader :client, :repository, :name

      # Check for the existence of the snapshot.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # params - Parameters Hash
      #
      # Returns true if the snapshot exists
      def exists?(params = {})
        response = client.get "/_snapshot/{repository}/{snapshot}", update_params(params, :action => "snapshot.exists")
        response.success?
      rescue Elastomer::Client::Error => err
        if err.error && err.error.dig("root_cause", 0, "type") == "snapshot_missing_exception"
          false
        else
          raise err
        end
      end
      alias_method :exist?, :exists?

      # Create the snapshot.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # body   - The snapshot options as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def create(body = {}, params = {})
        response = client.put "/_snapshot/{repository}/{snapshot}", update_params(params, :body => body, :action => "snapshot.create")
        response.body
      end

      # Get snapshot progress information.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def get(params = {})
        # Set snapshot name or we'll get the repository instead
        snapshot = name || "_all"
        response = client.get "/_snapshot/{repository}/{snapshot}", update_params(params, :snapshot => snapshot, :action => "snapshot.get")
        response.body
      end

      # Get detailed snapshot status.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def status(params = {})
        response = client.get "/_snapshot{/repository}{/snapshot}/_status", update_params(params, :action => "snapshot.status")
        response.body
      end

      # Restore the snapshot.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # body   - The restore options as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def restore(body = {}, params = {})
        response = client.post "/_snapshot/{repository}/{snapshot}/_restore", update_params(params, :body => body, :action => "snapshot.restore")
        response.body
      end

      # Delete the snapshot.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_snapshot
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete "/_snapshot/{repository}/{snapshot}", update_params(params, :action => "snapshot.delete")
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
        h = defaults.update params
        h.update overrides unless overrides.nil?
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :repository => repository, :snapshot => name }
      end
    end
  end
end
