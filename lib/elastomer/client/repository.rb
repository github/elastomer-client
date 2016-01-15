module Elastomer
  class Client

    # Returns a Repository instance.
    def repository(name = nil)
      Repository.new(self, name)
    end

    class Repository
      # Create a new index client for making API requests that pertain to
      # the health and management individual indexes.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # name   - The name of the index as a String or an Array of names
      def initialize(client, name = nil)
        @client = client
        @name   = @client.assert_param_presence(name, "repository name") unless name.nil?
      end

      attr_reader :client, :name

      # Check for the existence of the repository.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # params - Parameters Hash
      #
      # Returns true if the repository exists
      def exists?(params = {})
        response = client.get "/_snapshot{/repository}", update_params(params, :action => "repository.exists")
        response.success?
      rescue Elastomer::Client::Error => exception
        if exception.message =~ /RepositoryMissingException/
          false
        else
          raise exception
        end
      end
      alias_method :exist?, :exists?

      # Create the repository.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # body   - The repository type and settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def create(body, params = {})
        response = client.put "/_snapshot/{repository}", update_params(params, :body => body, :action => "repository.create")
        response.body
      end

      # Get repository type and settings.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get "/_snapshot{/repository}", update_params(params, :action => "repository.get")
        response.body
      end

      # Get status information on snapshots in progress.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def status(params = {})
        response = client.get "/_snapshot{/repository}/_status", update_params(params, :action => "repository.status")
        response.body
      end

      # Update the repository.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # body   - The repository type and settings as a Hash or a JSON encoded String
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def update(body, params = {})
        response = client.put "/_snapshot/{repository}", update_params(params, :body => body, :action => "repository.update")
        response.body
      end

      # Delete the repository.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html#_repositories
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete "/_snapshot/{repository}", update_params(params, :action => "repository.delete")
        response.body
      end

      # Provides access to snapshot API commands. These commands will be
      # scoped to this repository and the given snapshot name.
      #
      # snapshot - The snapshot name as a String, or nil for all snapshots.
      #
      # Returns a Snapshot instance.
      def snapshot(snapshot = nil)
        client.snapshot(name, snapshot)
      end
      alias_method :snapshots, :snapshot

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params(params, overrides = nil)
        h = defaults.update params
        h.update overrides unless overrides.nil?
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :repository => name }
      end
    end
  end
end
