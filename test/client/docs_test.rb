require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Docs do

  before do
    @name  = 'elastomer-docs-test'
    @index = $client.index(@name)

    unless @index.exists?
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

      $client.cluster.health \
        :index           => @name,
        :wait_for_status => 'green',
        :timeout         => '5s'
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it 'autogenerates IDs for documents' do
    h = @docs.index \
          :_type  => 'doc2',
          :title  => 'the author of logging',
          :author => 'pea53'

    assert h['ok'], 'everything is NOT ok'
    assert_match %r/^\S{22}$/, h['_id']
  end

  it 'uses the provided document ID' do
    h = @docs.index \
          :_id    => '42',
          :_type  => 'doc2',
          :title  => 'the author of logging',
          :author => 'pea53'

    assert h['ok'], 'everything is NOT ok'
    assert_equal '42', h['_id']
  end

  it 'accepts JSON encoded document strings' do
    h = @docs.index \
          '{"author":"pea53", "title":"the author of logging"}',
          :id   => '42',
          :type => 'doc2'

    assert h['ok'], 'everything is NOT ok'
    assert_equal '42', h['_id']

    h = @docs.index \
          '{"author":"grantr", "title":"the author of rubber-band"}',
          :type => 'doc2'

    assert h['ok'], 'everything is NOT ok'
    assert_match %r/^\S{22}$/, h['_id']
  end

  it 'gets documents from the search index' do
    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal false, h['exists']

    populate!

    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal true, h['exists']
    assert_equal 'mojombo', h['_source']['author']
  end

  it 'gets multiple documents from the search index' do
    populate!

    h = @docs.multi_get :docs => [
      { :_id => 1, :_type => 'doc1' },
      { :_id => 1, :_type => 'doc2' }
    ]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[mojombo pea53], authors

    h = @docs.multi_get :ids => [2, 1], :_type => 'doc1'
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[defunkt mojombo], authors

    h = @index.docs('doc1').multi_get :ids => [1, 2, 3, 4]
    exists = h['docs'].map { |d| d['exists'] }
    assert_equal [true, true, false, false], exists
  end

  it 'deletes documents from the search index' do
    populate!
    @docs = @index.docs('doc2')

    h = @docs.multi_get :ids => [1, 2]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[pea53 grantr], authors

    @docs.delete :id => 1
    h = @docs.multi_get :ids => [1, 2]
    exists = h['docs'].map { |d| d['exists'] }
    assert_equal [false, true], exists
  end

  it 'searches for documents' do
    h = @docs.search :q => '*:*'
    assert_equal 0, h['hits']['total']

    populate!

    h = @docs.search :q => '*:*'
    assert_equal 4, h['hits']['total']

    h = @docs.search :q => '*:*', :type => 'doc1'
    assert_equal 2, h['hits']['total']

    h = @docs.search({
      :query => {:match_all => {}},
      :filter => {:term => {:author => 'defunkt'}}
    }, :type => %w[doc1 doc2] )
    assert_equal 1, h['hits']['total']

    hit = h['hits']['hits'].first
    assert_equal 'the author of resque', hit['_source']['title']
  end

  it 'counts documents' do
    h = @docs.count :q => '*:*'
    assert_equal 0, h['count']

    populate!

    h = @docs.count :q => '*:*'
    assert_equal 4, h['count']

    h = @docs.count :q => '*:*', :type => 'doc1'
    assert_equal 2, h['count']

    h = @docs.count({
      :filtered => {
        :query => {:match_all => {}},
        :filter => {:term => {:author => 'defunkt'}}
      }
    }, :type => %w[doc1 doc2] )
    assert_equal 1, h['count']
  end

  def populate!
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

    @docs.add \
      :_id    => 2,
      :_type  => 'doc2',
      :title  => 'the author of rubber-band',
      :author => 'grantr'

    @index.refresh
  end

end
