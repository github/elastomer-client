# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Repository do
  before do
    if !run_snapshot_tests?
      skip "To enable snapshot tests, add a path.repo setting to your elasticsearch.yml file."
    end

    @name = "elastomer-repository-test"
    @repo = $client.repository(@name)
  end

  it "determines if a repo exists" do
    refute_predicate @repo, :exists?
    refute_predicate @repo, :exist?
    with_tmp_repo(@name) do
      assert_predicate @repo, :exists?
    end
  end

  it "creates repos" do
    response = create_repo(@name)

    assert response["acknowledged"]
    delete_repo(@name)
  end

  it "cannot create a repo without a name" do
    _(lambda {
      create_repo(nil)
    }).must_raise ArgumentError
  end

  it "gets repos" do
    with_tmp_repo do |repo|
      response = repo.get

      refute_nil response[repo.name]
    end
  end

  it "gets all repos" do
    with_tmp_repo do |repo|
      response = $client.repository.get

      refute_nil response[repo.name]
    end
  end

  it "gets repo status" do
    with_tmp_repo do |repo|
      response = repo.status

      assert_empty response["snapshots"]
    end
  end

  it "gets status of all repos" do
    response = $client.repository.status

    assert_empty response["snapshots"]
  end

  it "updates repos" do
    with_tmp_repo do |repo|
      settings = repo.get[repo.name]["settings"]
      response = repo.update(type: "fs", settings: settings.merge("compress" => true))

      assert response["acknowledged"]
      assert_equal "true", repo.get[repo.name]["settings"]["compress"]
    end
  end

  it "cannot update a repo without a name" do
    with_tmp_repo do |repo|
      _(lambda {
        settings = repo.get[repo.name]["settings"]
        $client.repository.update(type: "fs", settings: settings.merge("compress" => true))
      }).must_raise ArgumentError
    end
  end

  it "deletes repos" do
    with_tmp_repo do |repo|
      response = repo.delete

      assert response["acknowledged"]
      refute_predicate repo, :exists?
    end
  end

  it "cannot delete a repo without a name" do
    _(lambda {
      $client.repository.delete
    }).must_raise ArgumentError
  end

  it "gets snapshots" do
    with_tmp_repo do |repo|
      response = repo.snapshots.get

      assert_empty response["snapshots"]

      create_snapshot(repo, "test-snapshot")
      response = repo.snapshot.get

      assert_equal ["test-snapshot"], response["snapshots"].collect { |info| info["snapshot"] }

      create_snapshot(repo, "test-snapshot2")
      response  = repo.snapshots.get
      snapshot_names = response["snapshots"].collect { |info| info["snapshot"] }

      assert_includes snapshot_names, "test-snapshot"
      assert_includes snapshot_names, "test-snapshot2"
    end
  end
end
