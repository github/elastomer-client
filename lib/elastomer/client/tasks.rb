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

      # Create a new Tasks for introspecting on internal cluster activity.
      # More context: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/tasks.html
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      #
      # Raises IncompatibleVersionException if caller attempts to access Tasks API on ES version < 5.0.0
      def initialize(client)
        @client = client
      end

      attr_reader :client

      # Fetch results from the generic _tasks endpoint.
      #
      # params - Hash of request parameters, including:
      #
      # Examples
      #
      #   tasks.get
      #   tasks.get nodes: "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB", actions: "cluster:*", detailed: true
      #
      # Examples (ES 5+ only)
      #
      #   tasks.get group_by: "parents"
      #   tasks.get group_by: "parents", actions: "*reindex", ...
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get "/_tasks", params.merge(action: "tasks.list", rest_api: "tasks.list")
        response.body
      end

      # Fetch results from the _tasks endpoint for a particular cluster node and task ID.
      # NOTE: the API docs note the behavior wrong for this call; "task_id:<task_id>" is really "<node_id>:<task_id>"
      # where "node_id" is a value from the "nodes" hash returned from the /_tasks endpoint, and "task_id" is
      # from the "tasks" child hash of any of the "nodes" entries of the /_tasks endpoint
      #
      # node_id - the name of the ES cluster node hosting the target task
      # task_id - the numerical ID of the task to return data about in the response
      # params  - Hash of request parameters to include
      #
      # Examples
      #
      #  tasks.get_by_id "DmteLdw1QmSgW3GZmjmoKA", 123
      #  tasks.get_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, pretty: true
      #
      # Returns the response body as a Hash
      def get_by_id(node_id, task_id, params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        rest_api = client.version_support.supports_tasks_get? ? "tasks.get" : "tasks.list"

        # in this API, the task ID is included in the path, not as a request parameter.
        response = client.get "/_tasks/{task_id}", params.merge(task_id: "#{node_id}:#{task_id}", action: "tasks.get", rest_api: rest_api)
        response.body
      end

      # Fetch task details for all child tasks of the specified parent task.
      # NOTE: the API docs note the behavior wrong for this call: "parentTaskId:<task_id>"
      # is not the correct syntax for the parent_task_id param value. The correct
      # value syntax is "<parent_node_id>:<parent_task_id>"
      #
      # parent_node_id - ID of the node the parent task is hosted by
      # parent_task_id - ID of a parent task who's child tasks' data will be returned in the response
      # params         - Hash of request parameters to include
      #
      # Examples
      #
      #   tasks.get_by_parent_id "DmteLdw1QmSgW3GZmjmoKA", 123
      #   tasks.get_by_parent_id "DmteLdw1QmSgW3GZmjmoKB", 456, :detailed => true
      #
      # Returns the response body as a Hash
      def get_by_parent_id(parent_node_id, parent_task_id, params = {})
        raise ArgumentError, "invalid parent node ID provided: #{parent_node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid parent task ID provided: #{parent_task_id.inspect}" unless parent_task_id.is_a?(Integer)

        parent_task_id = "#{parent_node_id}:#{parent_task_id}"
        params = params.merge(action: "tasks.parent", rest_api: "tasks.list")

        if client.version_support.supports_parent_task_id?
          params[:parent_task_id] = parent_task_id
        else
          params[:parent_task] = parent_task_id
        end

        response = client.get "/_tasks", params
        response.body
      end

      # Wait for the specified amount of time (10 seconds by default) for some task(s) to complete.
      # Filters for task(s) to wait upon using same filter params as Tasks#get(params)
      #
      # timeout - maximum time to wait for target task to complete before returning, example: "5s"
      # params  - Hash of request params to include (mostly task filters in this context)
      #
      # Examples
      #
      # tasks.wait_for "5s", actions: "*health"
      # tasks.wait_for("30s", actions: "*reindex", nodes: "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB")
      #
      # Returns the response body as a Hash when timeout expires or target tasks complete
      # COMPATIBILITY WARNING: the response body differs between ES versions for this API
      def wait_for(timeout = "10s", params = {})
        self.get params.merge(wait_for_completion: true, timeout: timeout)
      end

      # Wait for the specified amount of time (10 seconds by default) for some task(s) to complete.
      # Filters for task(s) to wait upon using same IDs and filter params as Tasks#get_by_id(params)
      #
      # node_id - the ID of the node on which the target task is hosted
      # task_id - the ID of the task to wait on
      # timeout - time for call to await target tasks completion before returning
      # params  - Hash of request params to include (mostly task filters in this context)
      #
      # Examples
      #
      # tasks.wait_by_id "DmteLdw1QmSgW3GZmjmoKA", 123, "15s"
      # tasks.wait_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, "30s", actions: "*search"
      #
      # Returns the response body as a Hash when timeout expires or target tasks complete
      def wait_by_id(node_id, task_id, timeout = "10s", params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        self.get_by_id(node_id, task_id, params.merge(wait_for_completion: true, timeout: timeout))
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
      #   tasks.cancel_by_id "DmteLdw1QmSgW3GZmjmoKA", 456, pretty: true
      #
      # Returns the response body as a Hash
      def cancel_by_id(node_id, task_id, params = {})
        raise ArgumentError, "invalid node ID provided: #{node_id.inspect}" if node_id.to_s.empty?
        raise ArgumentError, "invalid task ID provided: #{task_id.inspect}" unless task_id.is_a?(Integer)

        self.cancel(params.merge(task_id: "#{node_id}:#{task_id}"))
      end

      # Cancels a task or group of tasks using various filtering parameters.
      #
      # params - Hash of request parameters to include
      #
      # Examples
      #
      #   tasks.cancel actions: "*reindex"
      #   tasks.cancel actions: "*search", nodes: "DmteLdw1QmSgW3GZmjmoKA,DmteLdw1QmSgW3GZmjmoKB,DmteLdw1QmSgW3GZmjmoKC"
      #
      # Returns the response body as a Hash
      def cancel(params = {})
        response = client.post "/_tasks{/task_id}/_cancel", params.merge(action: "tasks.cancel", rest_api: "tasks.cancel")
        response.body
      end

    end
  end
end
