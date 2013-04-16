require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Docs do

  before do
    @name  = 'docs-test'
    @index = $client.index(@name)

    @index.create \
      :settings => { 'index.number_of_shards' => 1, 'index.number_of_replicas' => 0 },
      :mappings => {
        :doc1 => {
          :_source => { :enabled => true }, :_all => { :enabled => false },
          :properties => {
            :title  => { :type => 'string', :analyzer => 'standard' },
            :author => { :type => 'string', :index => 'not_analyzed' }
          }
        },
        :doc2 => {
          :_source => { :enabled => true }, :_all => { :enabled => false },
          :properties => {
            :title  => { :type => 'string', :analyzer => 'standard' },
            :author => { :type => 'string', :index => 'not_analyzed' }
          }
        }
      }

    @index.refresh
    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it 'gets documents from the search index' do
    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal false, h['exists']

    @docs.add \
      :_id    => 1,
      :_type  => 'doc1',
      :title  => 'just a test document',
      :author => 'pea53'

    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal true, h['exists']
  end

  it 'gets multiple documents from the search index' do
    @docs.add \
      :_id    => 1,
      :_type  => 'doc1',
      :title  => 'the author of gravatar',
      :author => 'mojombo'

    @docs.add \
      :_id    => 2,
      :_type  => 'doc1',
      :title  => 'the author of resque',
      :author => 'defunkt'

    @docs.add \
      :_id    => 1,
      :_type  => 'doc2',
      :title  => 'the author of logging',
      :author => 'pea53'

    h = @docs.multi_get :docs => [
      { :_id => 1, :_type => 'doc1' },
      { :_id => 1, :_type => 'doc2' }
    ]
    docs = h['docs'].map { |d| d['_source'] }
    assert_equal 'mojombo', docs.first['author']
    assert_equal 'pea53', docs.last['author']

    h = @docs.multi_get :ids => [2, 1], :_type => 'doc1'
    docs = h['docs'].map { |d| d['_source'] }
    assert_equal 'defunkt', docs.first['author']
    assert_equal 'mojombo', docs.last['author']

    h = @docs.multi_get :ids => [1, 2, 3, 4], :_type => 'doc1'
    docs = h['docs'].map { |d| d['exists'] }
    assert_equal [true, true, false, false], docs
  end


end
