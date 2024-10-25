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
    wait_for_index(@source_index.name)
    wait_for_index(@dest_index.name)

    # Index a document in the source index
    @source_index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
    wait_for_index(@source_index.name)
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
    puts "Reindex Response: #{response}"

    # Refresh the destination index to make sure the document is searchable
    @dest_index.refresh

    # Verify that the document has been reindexed
    doc = @dest_index.docs.get(id: 1, type: "title")
    puts "Document in Destination Index: #{doc}"

    assert_equal "Book 1", doc["_source"]["title"]
  end
end
