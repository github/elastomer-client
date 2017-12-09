require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Client::Tasks do
  before do
    unless $client.version_support.es_version_5_x?
      skip "Tasks API is not supported in ES version #{$client.version}"
    end

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

  it "raises exception when get_by_id is called w/valid node and task IDs that don't match any tasks/nodes are supplied" do
    exception = assert_raises(Elastomer::Client::IndexNotFoundError) do
      @tasks.get_by_id "mongodb01", 42
    end
    assert_match(/which isn't part of the cluster and there is no record of the task/, exception.message)
    assert_equal(404, exception.status)
  end

  it "locates the task properly by ID when valid node and task IDs are supplied" do
    Thread.new do
      begin
        name = "elastomer-tasks-tests".freeze
        index = $client.index(name)
        wait_for_index(name)

        index.docs("person").bulk do |d|
          (1..100).each do |i|
            d.index \
              :foo => "foo",
              :bar => "bar",
              :baz => "baz"
          end
        end
        index.refresh
        Kernel.sleep(0.01)
      ensure
        index.delete if index.exists?
      end
    end

    target_tasks = []
    3.times.each do
      target_tasks = @tasks.get["nodes"]
        .map { |k, v| v["tasks"] }
        .flatten.map { |ts| ts.select { |k, v| /health/ =~ v["action"] } }
        .flatten.reject { |t| t == {} }
      break if target_tasks.size > 0
    end
    assert !target_tasks.empty?

    found_by_id = false
    target_tasks.each do |t|
      t = t.values.first
      resp = @tasks.get_by_id t["node"], t["id"]
      found_by_id = resp["task"]["node"] == t["node"] && resp["task"]["id"] == t["id"]
      break if found_by_id
    end

    assert found_by_id
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
