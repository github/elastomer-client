require_relative "../test_helper"

describe Elastomer::Client::Tasks do
  before do
    @tasks = $client.tasks
  end

  after do
  end

  it "list all in-flight tasks" do
    h = @tasks.get
    assert h["nodes"].keys.size > 0

    total_tasks = h["nodes"].map { |k, v| v["tasks"].keys.count }.sum
    assert total_tasks > 0
  end

  it "groups by parent->child relationships when get-all tasks API is grouped by 'parents'" do
    unless $client.version_support.es_version_5_x?
      skip "Tasks API is not supported in ES version #{$client.version}"
    end

    h = @tasks.get :group_by => "parents"
    parent_id = h["tasks"].select { |k, v| v.key?("children") }.keys.first
    childs_parent_ref = h.dig("tasks", parent_id, "children").first["parent_task_id"]
    assert_equal parent_id, childs_parent_ref
  end

  it "raises exception when get_by_id is called without required task & node IDs" do
    assert_raises(ArgumentError) do
      @tasks.get_by_id
    end
  end

  it "raises exception when get_by_id is called w/invalid task ID is supplied" do
    node_id = @tasks.get["nodes"].map { |k, v| k }.first
    assert_raises(ArgumentError) do
      @tasks.get_by_id node_id, "task_id_should_be_integer"
    end
  end

  it "raises exception when get_by_id is called w/invalid node ID is supplied" do
    assert_raises(ArgumentError) do
      @tasks.get_by_id nil, 42
    end
  end

  it "successfully waits for task to complete when wait_for_completion and timeout flags are set" do
    test_index = nil
    begin
      # poulate the index in a background thread to generate long-running tasks we can query
      test_index = populate_background_index!("elastomer-tasks-test-1")

      # ensure we can wait on completion of a task
      success = false
      query_long_running_tasks.each do |ts|
        t = ts.values.first
        begin
          resp = @tasks.wait_by_id t["node"], t["id"], "3s"
          success = !resp.key?("node_failures")
        rescue Elastomer::Client::ServerError => e
          # this means the timeout expired before the task finished, but it's a good thing!
          success = /Timed out waiting for completion/ =~ e.message
        end
        break if success
      end

      assert success
    ensure
      test_index.delete if test_index.exists?
    end
  end

  it "locates the task properly by ID when valid node and task IDs are supplied" do
    test_index = nil
    begin
      # make an index with a new client (in this thread, to avoid query check race after)
      # poulate the index in a background thread to generate long-running tasks we can query
      test_index = populate_background_index!("elastomer-tasks-test-2")

      # look up and verify found task
      found_by_id = false
      query_long_running_tasks.each do |ts|
        t = ts.values.first
        resp = @tasks.get_by_id t["node"], t["id"]

        # ES 5.x and 2.x responses are structured differently
        if $client.version_support.tasks_new_response_format?
          found_by_id = resp["task"]["node"] == t["node"] && resp["task"]["id"] == t["id"]
        else
          nid, tid = resp["nodes"][t["node"]]["tasks"].keys.first.split(":")
          found_by_id = nid == t["node"] && tid.to_i == t["id"]
        end

        break if found_by_id
      end

      assert found_by_id
    ensure
      test_index.delete if test_index.exists?
    end
  end

  it "raises exception when cancel_by_id is called without required task & node IDs" do
    assert_raises(ArgumentError) do
      @tasks.cancel_by_id
    end
  end

  it "raises exception when cancel_by_id is called w/invalid task ID is supplied" do
    node_id = @tasks.get["nodes"].map { |k, v| k }.first
    assert_raises(ArgumentError) do
      @tasks.cancel_by_id node_id, "not_an_integer_id"
    end
  end

  it "raises exception when cancel_by_id is called w/invalid node IDs is supplied" do
    assert_raises(ArgumentError) do
      @tasks.cancel_by_id nil, 42
    end
  end

  # TODO: test this behavior MORE!
  it "raises exception when cancel_by_id is called w/invalid node and task IDs are supplied" do
    assert_raises(ArgumentError) do
      @tasks.cancel_by_id "", "also_should_be_integer_id"
    end
  end

  # NOTE: unlike get_by_id, cancellation API doesn't return 404 when valid node_id and task_id
  # params don't match known nodes/running tasks, so there's no matching test for that here.

end
