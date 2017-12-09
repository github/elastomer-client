module Elastomer
  class Client

    # Returns a Tasks instance for querying the cluster bound to this client for
    # metadata about internal tasks in flight, and to submit administrative
    # requests (like cancellation) concerning those tasks.
    #
    # Returns a new Tasks object associated with this client
    def tasks
      Tasks.new(self)
    end

    class Tasks

      # TODO - validate params from this whitelist
      PARAMETERS = %i[
        nodes
        actions
        parent_task_id
        wait_for_completion
        pretty
        detailed
        timeout
        group_by
      ].to_set.freeze

      # Create a new Tasks for introspecting on internal cluster activity.
      # More context: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/tasks.html
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      #
      # Raises IncompatibleVersionException if caller attempts to access Tasks API on ES version < 5.0.0
      def initialize(client)
        unless client.version_support.supports_tasks?
          raise IncompatibleVersionException, "ES #{client.version} does not support tasks"
        end
        @client = client
      end

      attr_reader :client

      # Fetch results from the generic _tasks endpoint.
      #
      # params       - Hash of request parameters, including:
      #
      # Examples
      #
      #   tasks.get
      #   tasks.get :group_by => "parents"
      #   tasks.get :nodes => "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB", :actions => "cluster:*", :detailed => true
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get "/_tasks", params
        response.body
      end

      # Fetch results from the _tasks endpoint for a particular cluster node and task ID.
      # NOTE: the API docs note the behavior wrong for this call; "task_id:<task_id>" is really "<node_id>:<task_id>"
      # where "node_id" is a value from the "nodes" hash returned from the /_tasks endpoint, and "task_id" is
      # from the "tasks" child hash of any of the "nodes" entries of the /_tasks endpoint
      #
      # node_id         - the name of the ES cluster node hosting the target task
      # task_id         - the numerical ID of the task to return data about in the response
      # params          - Hash of request parameters to include
      #
      # Examples
      #
      #  tasks.get_by_id "DmteLdw1QmSgW3GZmjmoKA", 123
      #  tasks.get_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, :pretty => true
      #
      # Returns the response body as a Hash
      def get_by_id(node_id, task_id, params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        # in this API, the task ID is included in the path, not as a request parameter.
        response = client.get "/_tasks/#{node_id}:#{task_id}", params
        response.body
      end

      # Fetch results from the _tasks endpoint for a particular parent task's children.
      #
      # parent_task_id  - ID of a parent task who's child tasks' data will be returned in the response
      # params          - Hash of request parameters to include
      #
      # Examples
      #
      #   tasks.get_by_parent_id 1
      #   tasks.get_by_parent_id 2, :nodes => "DmteLdw1QmSgW3GZmjmoKA"
      #
      # Returns the response body as a Hash
      def get_by_parent_id(parent_task_id, params = {})
        raise ArgumentError, "invalid parent task ID provided: #{task_id.inspect}" unless parent_task_id.is_a?(Integer)

        # in this API, we pass the parent task ID as a formatted parameter in a request to the _tasks endpoint
        formatted_parent = { :parent_task_id => "parentTaskId:#{parent_task_id}" }
        response = client.get "/_tasks", params.merge(formatted_parent)
        response.body
      end

      # Wait for the specified amount of time (10 seconds by default) for some task(s) to complete.
      # Filters for task(s) to wait upon using same filter params as Tasks#get(params)
      #
      # params          - Hash of request params to include (mostly task filters in this context)
      #
      # Examples
      #
      # tasks.wait_for("30s", {:actions => "*reindex", :nodes => "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB"})
      #
      # Returns the response body as a Hash when timeout expires or target tasks complete
      def wait_for(timeout = "10s", params = {})
        params_with_wait = params.merge({ :wait_for_completion => true, :timeout => timeout })
        self.get(params_with_wait)
      end

      # Wait for the specified amount of time (10 seconds by default) for some task(s) to complete.
      # Filters for task(s) to wait upon using same IDs and filter params as Tasks#get_by_id(params)
      #
      # node_id                 - the ID of the node on which the target task is hosted
      # task_id                 - the ID of the task to wait on
      # params                  - Hash of request params to include (mostly task filters in this context)
      #
      # Examples
      #
      # tasks.wait_by_id "DmteLdw1QmSgW3GZmjmoKA", 123, "15s"
      # tasks.wait_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, "30s", :actions => "*search"
      #
      # Returns the response body as a Hash when timeout expires or target tasks complete
      def wait_by_id(node_id, task_id, timeout = "10s", params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        params_with_wait = params.merge({ :wait_for_completion => true, :timeout => timeout })
        self.get_by_id(node_id, task_id, params_with_wait)
      end

      # Cancels a task running on a particular node.
      # NOTE: the API docs note the behavior wrong for this call; "task_id:<task_id>" is really "<node_id>:<task_id>"
      # where "node_id" is a value from the "nodes" hash returned from the /_tasks endpoint, and "task_id" is
      # from the "tasks" child hash of any of the "nodes" entries of the /_tasks endpoint
      #
      # node_id         - the ES node hosting the task to be cancelled
      # task_id         - ID of the task to be cancelled
      # params          - Hash of request parameters to include
      #
      # Examples
      #
      #   tasks.cancel_by_id "DmteLdw1QmSgW3GZmjmoKA", 123
      #   tasks.cancel_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, :pretty => true
      #
      # Returns the response body as a Hash
      def cancel_by_id(node_id, task_id, params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        response = client.post "/_tasks/#{node_id}:#{task_id}/_cancel", params
        response.body
      end

      # Cancels a task or group of tasks using various filtering parameters.
      #
      # params          - Hash of request parameters to include
      #
      # Examples
      #
      #   tasks.cancel :actions => "*reindex"
      #   tasks.cancel :actions => "*search", :nodes => "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB,DmteLdw1QmSgW3GZmjmoKC"
      #
      # Returns the response body as a Hash
      def cancel(params = {})
        response = client.post "/_tasks/_cancel", params
        response.body
      end

    end # end class Tasks
  end # end class Client
end # end module Elastomer
