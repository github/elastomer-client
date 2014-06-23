
require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Repository do
  if es_version_1_x?
    before do
      @index_name = 'elastomer-snapshot-test-index'
      @index = $client.index(@index_name)
      @repo_name = 'elastomer-snapshot-test'
      @name = 'elastomer-test'
      @repo = $client.repository(@repo_name)
      @snapshot = $client.snapshot(@repo_name, @name)
      @repo.delete if @repo.exists?
      # No need to delete snapshots because each with_tmp_repo location is unique
    end

    after do
      @repo.delete if @repo.exists?
      @index.delete if @index.exists?
    end

    it 'determines if a snapshot exists' do
      with_tmp_repo do
        assert_equal false, @snapshot.exists?
        assert_equal false, @snapshot.exist?
        @snapshot.create({}, :wait_for_completion => true)
        assert_equal true, @snapshot.exist?
      end
    end

    it 'creates snapshots' do
      with_tmp_repo do
        response = @snapshot.create({}, :wait_for_completion => true)
        assert_equal @name, response["snapshot"]["snapshot"]
      end
    end

    it 'creates snapshots with options' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      with_tmp_repo do
        response = @snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
        assert_equal [@index_name], response["snapshot"]["indices"]
        assert_equal 1, response["snapshot"]["shards"]["total"]
      end
    end

    it 'gets snapshot info for one and all' do
      with_tmp_snapshot do
        response = @snapshot.get
        assert_equal @name, response["snapshots"][0]["snapshot"]
        response = @repo.snapshots.get
        assert_equal @name, response["snapshots"][0]["snapshot"]
      end
    end

    it 'gets snapshot status for one and all' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      with_tmp_repo do
        @snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
        response = @snapshot.status
        assert_equal 1, response["snapshots"][0]["shards_stats"]["total"]
      end
    end

    it 'gets status of snapshots in progress' do
      # we can't reliably get status of an in-progress snapshot in tests, so
      # check for an empty result instead
      response = @repo.snapshots.status
      assert_equal [], response["snapshots"]
      response = $client.snapshot.status
      assert_equal [], response["snapshots"]
    end

    it 'disallows nil repo name with non-nil snapshot name' do
      assert_raises(ArgumentError) { $client.repository.snapshot('snapshot') }
      assert_raises(ArgumentError) { $client.snapshot(nil, 'snapshot') }
    end

    it 'deletes snapshots' do
      with_tmp_snapshot do
        response = @snapshot.delete
        assert_equal true, response["acknowledged"]
      end
    end

    it 'restores snapshots' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      wait_for_index(@index_name)
      with_tmp_repo do
        @snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
        @index.delete
        response = @snapshot.restore({}, :wait_for_completion => true)
        assert_equal 1, response["snapshot"]["shards"]["total"]
      end
    end

    it 'restores snapshots with options' do
      @index.create(:number_of_shards => 1, :number_of_replicas => 0)
      wait_for_index(@index_name)
      with_tmp_repo do
        @snapshot.create({:indices => [@index_name]}, :wait_for_completion => true)
        response = @snapshot.restore({
          :rename_pattern => @index_name,
          :rename_replacement => "#{@index_name}-restored"
        }, :wait_for_completion => true)
        assert_equal ["#{@index_name}-restored"], response["snapshot"]["indices"]
        assert_equal 1, response["snapshot"]["shards"]["total"]
      end
    end
  end
end
