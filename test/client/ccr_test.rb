# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Ccr do
  before do
    skip "Cannot test Ccr API without a replica cluster" unless $replica_client.available?

    @leader_index = $client.index("leader_index")
    @follower_index = $replica_client.index("follower_index")
    @auto_followed_index = $client.index("followed_index")
    @auto_follower_index = $replica_client.index("followed_index-follower")

    if @leader_index.exists?
      @leader_index.delete
    end
    if @auto_followed_index.exists?
      @auto_followed_index.delete
    end
    if @follower_index.exists?
      @follower_index.delete
    end
    if @auto_follower_index.exists?
      @auto_follower_index.delete
    end

    @leader_index.create(default_index_settings)
    wait_for_index(@leader_index.name, "green")

    @leader_index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
    @leader_index.refresh

    begin
      ccr.delete_auto_follow("follower_pattern")
    rescue StandardError
      puts "No auto-follow pattern to delete"
    end
  end

  after do
    @leader_index.delete if @leader_index.exists?
    @follower_index.delete if @follower_index.exists?
    @auto_followed_index.delete if @auto_followed_index.exists?
    @auto_follower_index.delete if @auto_follower_index.exists?

    begin
      ccr.delete_auto_follow("follower_pattern")
    rescue StandardError
      puts "No auto-follow pattern to delete"
    end
  end

  it "successfully follows a leader index" do
    ccr = $replica_client.ccr

    ccr.follow(@follower_index.name, { leader_index: @leader_index.name, remote_cluster: "leader" })
    wait_for_index(@follower_index.name, "green")
    doc = @follower_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  it "successfully implements an auto-follow policy" do
    ccr = $replica_client.ccr

    ccr.auto_follow("follower_pattern", { remote_cluster: "leader", leader_index_patterns: ["*"], follow_index_pattern: "{{leader_index}}-follower" })

    @auto_followed_index.create(default_index_settings)
    wait_for_index(@auto_followed_index.name, "green")

    @auto_follower_index = $replica_client.index("followed_index-follower")
    wait_for_index(@auto_follower_index.name, "green")

    resp = ccr.get_auto_follow(pattern_name: "follower_pattern")

    assert_equal "follower_pattern", resp["patterns"].first["name"]

    assert_predicate @auto_follower_index, :exists?
  end

end
