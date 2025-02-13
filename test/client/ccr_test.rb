# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Ccr do
  before :each do
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
  end

  after :each do
    @leader_index.delete if @leader_index.exists?
    @follower_index.delete if @follower_index.exists?
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

    follow_index(@follower_index, @leader_index)

    doc = @follower_index.docs.get(id: 1, type: "book")

    assert_equal "Book 1", doc["_source"]["title"]
  end

  it "should successfully pauses a follower index" do
    follow_index(@follower_index, @leader_index)

    response = pause_follow(@follower_index)

    assert response["acknowledged"]

    create_document(@leader_index, "book", { _id: 2, title: "Book 2" })

    doc = @follower_index.docs.get(id: 2, type: "book")

    refute doc["found"]
  end

  it "successfully unfollow a leader index" do
    follow_index(@follower_index, @leader_index)

    pause_follow(@follower_index)

    @follower_index.close

    response = unfollow_index(@follower_index)

    assert response["acknowledged"]

    @follower_index.open

    wait_for_index(@follower_index.name, "green")

    create_document(@leader_index, "book", { _id: 2, title: "Book 2" })

    doc = @follower_index.docs.get(id: 2, type: "book")

    refute doc["found"]
  end

end
