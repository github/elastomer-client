# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Reindex do
  before do
    @source_index = $client.index("source_index")
    @dest_index = $client.index("dest_index")
    @non_existent_index = $client.index("non_existent_index")
    if @source_index.exists?
      @source_index.delete
    end
    if @dest_index.exists?
      @dest_index.delete
    end
    if @non_existent_index.exists?
      @non_existent_index.delete
    end
    @source_index.create(default_index_settings)
    @dest_index.create(default_index_settings)
    wait_for_index(@source_index.name, "green")
    wait_for_index(@dest_index.name, "green")

    # Index a document in the source index
    @source_index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
    @source_index.refresh
  end

  after do
    @source_index.delete if @source_index.exists?
    @dest_index.delete if @dest_index.exists?
    @non_existent_index.delete if @non_existent_index.exists?
  end

  it "reindexes documents from one index to another" do
    reindex = $client.reindex
    body = {
      source: { index: @source_index.name },
      dest: { index: @dest_index.name }
    }
    reindex.reindex(body)

    # Refresh the destination index to make sure the document is searchable
    @dest_index.refresh

    # Verify that the document has been reindexed
    doc = @dest_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  it "successfully rethrottles a reindex task" do
    reindex = $client.reindex
    body = {
      source: { index: @source_index.name },
      dest: { index: @dest_index.name }
    }
    response = reindex.reindex(body, requests_per_second: 0.01, wait_for_completion: false)
    task_id = response["task"]
    node_id = task_id.split(":").first
    task_number = task_id.split(":").last.to_i

    response = reindex.rethrottle(task_id, requests_per_second: 1)

    assert_equal 1, response["nodes"][node_id]["tasks"][task_id]["status"]["requests_per_second"]

    # wait for the task to complete
    tasks = $client.tasks
    tasks.wait_by_id(node_id, task_number, "30s")

    # Verify that the document has been reindexed
    doc = @dest_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  it "creates a new index when the destination index does not exist" do
    reindex = $client.reindex
    body = {
      source: { index: @source_index.name },
      dest: { index: "non_existent_index" }
    }
    reindex.reindex(body)
    new_index = $client.index("non_existent_index")

    assert_predicate(new_index, :exists?)
  end

  it "fails when the source index does not exist" do
    reindex = $client.reindex
    body = {
      source: { index: "non_existent_index" },
      dest: { index: @dest_index.name }
    }

    exception = assert_raises(ElastomerClient::Client::RequestError) do
      reindex.reindex(body)
    end
    assert_equal(404, exception.status)
  end
end
