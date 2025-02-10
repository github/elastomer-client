# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Ccr do
  before do
    skip "Cannot test Ccr API without a replica cluster" unless $replica_client.available?

    @leader_index = $client.index("leader_index")
    @follower_index = $replica_client.index("follower_index")
    if @leader_index.exists?
      @leader_index.delete
    end
    if @follower_index.exists?
      @follower_index.delete
    end
    @leader_index.create(default_index_settings)
    wait_for_index(@leader_index.name, "green")

    @leader_index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
    @leader_index.refresh
  end

  after do
    @leader_index.delete if @leader_index.exists?
    @follower_index.delete if @follower_index.exists?
  end

  it "successfully follows a leader index" do
    ccr = $replica_client.ccr

    ccr.follow(@follower_index.name, { leader_index: @leader_index.name, remote_cluster: "leader" })
    wait_for_index(@follower_index.name, "green")
    doc = @follower_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  # it "successfully implements an auto-follow policy" do
  #   ccr = $replica_client.ccr

  #   ccr.auto_follow("follower_pattern", { remote_cluster: "leader", leader_index_patterns: ["*"], follow_index_pattern: "{{leader_index}}-follower" })

  #   index = $client.index("followed_index")
  #   index.create(default_index_settings)
  #   wait_for_index(index.name, "green")
  #   follower_index = $replica_client.index("followed_index-follower")
  #   wait_for_index(follower_index.name, "green")
  #   assert follower_index.exists?

  #   index.delete
  #   follower_index.delete
  # end
end
