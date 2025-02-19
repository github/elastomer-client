# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Ccr do
  before do
    skip "Cannot test Ccr API without a replica cluster" unless $replica_client.available?

    begin
      ccr.delete_auto_follow("follower_pattern")
    rescue StandardError
      puts "No auto-follow pattern to delete"
    end

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

  def follow_index(follower_index_name, leader_index_name)
    ccr = $replica_client.ccr
    response = ccr.follow(follower_index_name, { leader_index: leader_index_name, remote_cluster: "leader" })
    wait_for_index(follower_index_name, "green")
    response
  end

  def pause_follow(follower_index_name)
    ccr = $replica_client.ccr
    response = ccr.pause_follow(follower_index_name)
    wait_for_index(follower_index_name, "green")
    response
  end

  def unfollow_index(follower_index_name)
    ccr = $replica_client.ccr
    response = ccr.unfollow(follower_index_name)
    wait_for_index(follower_index_name, "green")
    response
  end

  def create_document(index, type, document)
    response = index.docs.index(document_wrapper(type, document))
    index.refresh
    response
  end

  it "successfully follows a leader index" do
    create_document(@leader_index, "book", { _id: 1, title: "Book 1" })
    follow_index(@follower_index.name, @leader_index.name)

    doc = @follower_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  it "successfully gets info for all follower indices" do
    follow_index(@follower_index.name, @leader_index.name)

    response = $replica_client.ccr.get_follower_info("*")

    assert_equal response["follower_indices"][0]["follower_index"], @follower_index.name
    assert_equal response["follower_indices"][0]["leader_index"], @leader_index.name
  end

  it "successfully pauses a follower index" do
    follow_index(@follower_index.name, @leader_index.name)

    response = pause_follow(@follower_index.name)

    assert response["acknowledged"]

    create_document(@leader_index, "book", { _id: 2, title: "Book 2" })

    doc = @follower_index.docs.get(id: 2, type: "book")

    refute doc["found"]
  end

  it "successfully unfollow a leader index" do
    follow_index(@follower_index.name, @leader_index.name)

    pause_follow(@follower_index.name)

    @follower_index.close

    response = unfollow_index(@follower_index.name)

    assert response["acknowledged"]

    @follower_index.open

    wait_for_index(@follower_index.name, "green")

    create_document(@leader_index, "book", { _id: 2, title: "Book 2" })

    doc = @follower_index.docs.get(id: 2, type: "book")

    refute doc["found"]
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
