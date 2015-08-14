
require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Snapshot do
  if es_version_1_x? && run_snapshot_tests?
    before do
      @index_name = 'elastomer-snapshot-test-index'
      @index = $client.index(@index_name)
      @name = 'elastomer-test'
    end

    after do
      @index.delete if @index.exists?
    end

    it 'determines if a snapshot exists' do
      with_tmp_repo do |repo|
        snapshot = repo.snapshot(@name)
        assert_equal false, snapshot.exists?
        assert_equal false, snapshot.exist?
        snapshot.create({}, :wait_for_completion => true)
        assert_equal true, snapshot.exist?
      end
    end

    it 'creates snapshots' do
      with_tmp_repo do |repo|
        response = repo.snapshot(@name).create({}, :wait_for_completion => true)
        assert_equal @name, response["snapshot"]["snapshot"]
      end
    end

    it 'creates snapshots with options' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      with_tmp_repo do |repo|
        response = repo.snapshot(@name).create({:indices => [@index_name]}, :wait_for_completion => true)
        assert_equal [@index_name], response["snapshot"]["indices"]
        assert_equal 1, response["snapshot"]["shards"]["total"]
      end
    end

    it 'gets snapshot info for one and all' do
      with_tmp_snapshot do |snapshot, repo|
        response = snapshot.get
        assert_equal snapshot.name, response["snapshots"][0]["snapshot"]
        response = repo.snapshots.get
        assert_equal snapshot.name, response["snapshots"][0]["snapshot"]
      end
    end

    it 'gets snapshot status for one and all' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      with_tmp_repo do |repo|
        repo.snapshot(@name).create({:indices => [@index_name]}, :wait_for_completion => true)
        response = repo.snapshot(@name).status
        assert_equal 1, response["snapshots"][0]["shards_stats"]["total"]
      end
    end

    it 'gets status of snapshots in progress' do
      # we can't reliably get status of an in-progress snapshot in tests, so
      # check for an empty result instead
      with_tmp_repo do |repo|
        response = repo.snapshots.status
        assert_equal [], response["snapshots"]
        response = $client.snapshot.status
        assert_equal [], response["snapshots"]
      end
    end

    it 'disallows nil repo name with non-nil snapshot name' do
      assert_raises(ArgumentError) { $client.repository.snapshot('snapshot') }
      assert_raises(ArgumentError) { $client.snapshot(nil, 'snapshot') }
    end

    it 'deletes snapshots' do
      with_tmp_snapshot do |snapshot|
        response = snapshot.delete
        assert_equal true, response["acknowledged"]
      end
    end

    it 'restores snapshots' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      wait_for_index(@index_name)
      with_tmp_repo do |repo|
        snapshot = repo.snapshot(@name)
        snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
        @index.delete
        response = snapshot.restore({}, :wait_for_completion => true)
        assert_equal 1, response["snapshot"]["shards"]["total"]
      end
    end

    describe "restoring to a different index" do
      before do
        @restored_index_name = "#{@index_name}-restored"
        @restored_index = $client.index(@restored_index_name)
      end

      after do
        @restored_index.delete if @restored_index.exists?
      end

      it 'restores snapshots with options' do
        @index.create(:number_of_shards => 1, :number_of_replicas => 0)
        wait_for_index(@index_name)
        with_tmp_repo do |repo|
          snapshot = repo.snapshot(@name)
          snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
          response = snapshot.restore({
            :rename_pattern => @index_name,
            :rename_replacement => @restored_index_name
          }, :wait_for_completion => true)
          assert_equal [@restored_index_name], response["snapshot"]["indices"]
          assert_equal 1, response["snapshot"]["shards"]["total"]
        end
      end
    end
  end
end
