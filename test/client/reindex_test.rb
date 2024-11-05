# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Reindex do
  before do
    @source_index = $client.index("source_index")
    @dest_index = $client.index("dest_index")
    if @source_index.exists?
      @source_index.delete
    end
    if @dest_index.exists?
      @dest_index.delete
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
  end

  it "reindexes documents from one index to another" do
    reindex = $client.reindex
    body = {
      source: { index: @source_index.name },
      dest: { index: @dest_index.name }
    }
    response = reindex.reindex(body)

    # Refresh the destination index to make sure the document is searchable
    @dest_index.refresh

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
    response = reindex.reindex(body)
    puts response
    new_index = $client.index("non_existent_index")
    assert new_index.exists?
  end

  it "fails when the source index does not exist" do
    reindex = $client.reindex
    body = {
      source: { index: "non_existent_index" },
      dest: { index: @dest_index.name }
    }
    
    exception = assert_raises(ElastomerClient::Client::RequestError) do
      response = reindex.reindex(body)
    end
  end
end
