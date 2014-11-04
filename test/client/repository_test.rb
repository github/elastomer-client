require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Repository do

  if es_version_1_x?

    before do
      @name = 'elastomer-repository-test'
      @repo = $client.repository(@name)
    end

    it 'determines if a repo exists' do
      assert_equal false, @repo.exists?
      assert_equal false, @repo.exist?
      with_tmp_repo(@name) do
        assert_equal true, @repo.exists?
      end
    end

    it 'creates repos' do
      response = create_repo(@name)
      assert_equal true, response["acknowledged"]
      delete_repo(@name)
    end

    it 'cannot create a repo without a name' do
      lambda {
        create_repo(nil)
      }.must_raise ArgumentError
    end

    it 'gets repos' do
      with_tmp_repo do |repo|
        response = repo.get
        refute_nil response[repo.name]
      end
    end

    it 'gets all repos' do
      with_tmp_repo do |repo|
        response = $client.repository.get
        refute_nil response[repo.name]
      end
    end

    it 'gets repo status' do
      with_tmp_repo do |repo|
        response = repo.status
        assert_equal [], response["snapshots"]
      end
    end

    it 'gets status of all repos' do
      response = $client.repository.status
      assert_equal [], response["snapshots"]
    end

    it 'updates repos' do
      with_tmp_repo do |repo|
        settings = repo.get[repo.name]['settings']
        response = repo.update(:type => 'fs', :settings => settings.merge('compress' => true))
        assert_equal true, response["acknowledged"]
        assert_equal "true", repo.get[repo.name]["settings"]["compress"]
      end
    end

    it 'cannot update a repo without a name' do
      with_tmp_repo do |repo|
        lambda {
          settings = repo.get[repo.name]['settings']
          $client.repository.update(:type => 'fs', :settings => settings.merge('compress' => true))
        }.must_raise ArgumentError
      end
    end

    it 'deletes repos' do
      with_tmp_repo do |repo|
        response = repo.delete
        assert_equal true, response["acknowledged"]
        assert_equal false, repo.exists?
      end
    end

    it 'cannot delete a repo without a name' do
      lambda {
        $client.repository.delete
      }.must_raise ArgumentError
    end

    it 'gets snapshots' do
      with_tmp_repo do |repo|
        response = repo.snapshots.get
        assert_equal [], response["snapshots"]

        create_snapshot(repo, 'test-snapshot')
        response = repo.snapshot.get
        assert_equal ['test-snapshot'], response["snapshots"].collect { |info| info["snapshot"] }

        snapshot2 = create_snapshot(repo, 'test-snapshot2')
        response  = repo.snapshots.get
        snapshot_names = response["snapshots"].collect { |info| info["snapshot"] }
        assert_includes snapshot_names, 'test-snapshot'
        assert_includes snapshot_names, 'test-snapshot2'
      end
    end
  end
end
