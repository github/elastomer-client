require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Repository do

  if es_version_1_x?

    before do
      @name = 'elastomer-repository-test'
      @repo = $client.repository(@name)
      @repo.delete if @repo.exists?
    end

    after do
      @repo.delete if @repo.exists?
    end

    it 'determines if a repo exists' do
      assert_equal false, @repo.exists?
      assert_equal false, @repo.exist?
      with_tmp_repo do
        assert_equal true, @repo.exists?
      end
    end

    it 'creates repos' do
      Dir.mktmpdir do |dir|
        response = @repo.create({:type => 'fs', :settings => {:location => dir}})
        assert_equal true, response["acknowledged"]
      end
    end

    it 'cannot create a repo without a name' do
      Dir.mktmpdir do |dir|
        lambda {
          $client.repository.create({:type => 'fs', :settings => {:location => dir}})
        }.must_raise ArgumentError
      end
    end

    it 'gets repos' do
      with_tmp_repo do
        response = @repo.get
        refute_nil response[@name]
      end
    end

    it 'gets all repos' do
      with_tmp_repo do
        response = $client.repository.get
        refute_nil response[@name]
      end
    end

    it 'gets repo status' do
      with_tmp_repo do
        response = @repo.status
        assert_equal [], response["snapshots"]
      end
    end

    it 'gets status of all repos' do
      response = $client.repository.status
      assert_equal [], response["snapshots"]
    end

    it 'updates repos' do
      Dir.mktmpdir do |dir|
        @repo.create({:type => 'fs', :settings => {:location => dir}})
        response = @repo.update(:type => 'fs', :settings => {:compress => true, :location => dir})
        assert_equal true, response["acknowledged"]
        response = @repo.get
        assert_equal "true", response[@name]["settings"]["compress"]
      end
    end

    it 'cannot update a repo without a name' do
      Dir.mktmpdir do |dir|
        lambda {
          $client.repository.update({:type => 'fs', :settings => {:location => dir}})
        }.must_raise ArgumentError
      end
    end

    it 'deletes repos' do
      with_tmp_repo do
        response = @repo.delete
        assert_equal true, response["acknowledged"]
        assert_equal false, @repo.exists?
      end
    end

    it 'cannot delete a repo without a name' do
      lambda {
        $client.repository.delete
      }.must_raise ArgumentError
    end

    it 'gets snapshots' do
      with_tmp_repo do
        response = @repo.snapshots.get
        assert_equal [], response["snapshots"]
        response = @repo.snapshot.get
        assert_equal [], response["snapshots"]
        assert_equal false, @repo.snapshot('elastomer-test').exists?
      end
    end
  end
end
