require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::DeleteByQuery do

  before do
    @index = $client.index "elastomer-delete-by-query-test"
    @index.delete if @index.exists?
    @docs = @index.docs("docs")
  end

  after do
    @index.delete if @index.exists?
  end

  describe "when an index with documents exists" do
    before do
      @index.create(nil)
      wait_for_index(@index_name)

      @docs.index({ :_id => 0, :name => "mittens" })
      @docs.index({ :_id => 1, :name => "luna" })

      @index.refresh
    end

    it 'deletes by query' do
      response = $client.delete_by_query(nil, :q => "name:mittens")
      assert_equal({
        '_all' => {
          'found' => 1,
          'deleted' => 1,
          'missing' => 0,
          'failed' => 0,
        },
        @index.name => {
          'found' => 1,
          'deleted' => 1,
          'missing' => 0,
          'failed' => 0,
        },
      }, response['_indices'])

      @index.refresh
      response = @docs.multi_get :ids => [0, 1]
      refute_found response['docs'][0]
      assert_found response['docs'][1]
    end

    it 'respects action_count' do
      count = 0
      WebMock.after_request do |request, _|
        count += 1 if request.uri.path =~ /_bulk$/
      end

      response = $client.delete_by_query(nil, :action_count => 1)

      assert_equal(2, count)
    end
  end
end
