require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Client::Tasks do
  before do
    unless $client.version_support.es_version_5_x?
      skip "Tasks API is not supported in ES version #{$client.version}"
    end

    @tasks = $client.tasks
  end

  after do
    pass # nothing to do here yet...
  end

  it "list all in-flight tasks" do
    h = @tasks.get
    assert h["nodes"].keys.size > 0

    total_tasks = h["nodes"].map { |k, v| v["tasks"].keys.count }.sum
    assert total_tasks > 0
  end

  it "groups by parent->child relationships when get-all tasks API is grouped by 'parents'" do
    h = @tasks.get :group_by => "parents"
    parent_id = h["tasks"].keys.first
    childs_parent_ref = h["tasks"][parent_id]["children"].first["parent_task_id"]
    assert_equal parent_id, childs_parent_ref
  end

  it "raises exception when get_by_id is called without required task & node IDs" do
    assert_raises(ArgumentError) do
      @tasks.get_by_id
    end
  end

  it "raises exception when get_by_id is called w/invalid task ID is supplied" do
    node_id = @tasks.get["nodes"].map { |k, v| k }.first
    assert_raises(Elastomer::Client::IllegalArgument) do
      @tasks.get_by_id node_id, "task_id_should_be_integer"
    end
  end

  it "raises exception when get_by_id is called w/invalid node ID is supplied" do
    assert_raises(Elastomer::Client::IllegalArgument) do
      @tasks.get_by_id nil, 42
    end
  end

  it "raises exception when get_by_id is called w/valid node and task IDs that don't match any tasks/nodes are supplied" do
    exception = assert_raises(Elastomer::Client::IndexNotFoundError) do
      @tasks.get_by_id "mongodb01", 42
    end
    assert_match(/which isn't part of the cluster and there is no record of the task/, exception.message)
    assert_equal(404, exception.status)
  end

  it "raises exception when get_by_id is called with valid task & node params that's no longer registered" do
    # acquire node and task IDs guaranteed to be "real" even if they are expired by the time the test call goes out
    h = @tasks.get
    first_node = h["nodes"].keys.first
    node_id, task_id = h["nodes"][first_node]["tasks"].keys.first.split(":")

    exception = assert_raises(Elastomer::Client::RequestError) do
      @tasks.get_by_id node_id, task_id, {}
    end
    assert_match(/isn't running and hasn't stored its results/, exception.message)
    assert_equal(404, exception.status)
  end

  it "raises exception when cancel_by_id is called without required task & node IDs" do
    assert_raises(ArgumentError) do
      @tasks.cancel_by_id
    end
  end

  it "raises exception when cancel_by_id is called w/invalid task ID is supplied" do
    node_id = @tasks.get["nodes"].map { |k, v| k }.first
    assert_raises(Elastomer::Client::IllegalArgument) do
      @tasks.cancel_by_id node_id, "not_an_integer_id"
    end
  end

  it "raises exception when cancel_by_id is called w/invalid node IDs is supplied" do
    assert_raises(Elastomer::Client::IllegalArgument) do
      @tasks.cancel_by_id nil, 42
    end
  end

  # TODO: test this behavior MORE!
  it "raises exception when cancel_by_id is called w/invalid node and task IDs are supplied" do
    exception = assert_raises(Elastomer::Client::IllegalArgument) do
      @tasks.cancel_by_id "", "also_should_be_integer_id"
    end
  end

  # NOTE: unlike get_by_id, cancellation API doesn't return 404 when valid node_id and task_id
  # params don't match known nodes/running tasks, so there's no matching test for that here.

end
