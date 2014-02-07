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

    h = @docs.index \
          :_id    => nil,
          :_type  => 'doc3',
          :title  => 'the author of rubber-band',
          :author => 'grantr'

    assert h['ok'], 'everything is NOT ok'
    assert_match %r/^\S{22}$/, h['_id']

    h = @docs.index \
          :_id    => '',
          :_type  => 'doc4',
          :title  => 'the author of toml',
          :author => 'mojombo'

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

    assert_raises(ArgumentError) { @docs.delete :id => nil }
    assert_raises(ArgumentError) { @docs.delete :id => '' }
    assert_raises(ArgumentError) { @docs.delete :id => "\t" }
  end

  it 'does not care if you delete a document that is not there' do
    @docs = @index.docs('doc2')
    h = @docs.delete :id => 42

    assert true == h['ok'], 'failed to perform delete operation'
    assert false == h['found'], 'that document was not there'
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

    h = @docs.count :q => '*:*', :type => 'doc1,doc2'
    assert_equal 4, h['count']

    h = @docs.count({
      :filtered => {
        :query => {:match_all => {}},
        :filter => {:term => {:author => 'defunkt'}}
      }
    }, :type => %w[doc1 doc2] )
    assert_equal 1, h['count']
  end

  it 'searches for more like this' do
    populate!

    # for some reason, if there's no document indexed here all the mlt
    # queries return zero results
    @docs.add \
      :_id    => 3,
      :_type  => 'doc1',
      :title  => 'the author of faraday',
      :author => 'technoweenie'

    @index.refresh

    h = @docs.more_like_this({
      :type => 'doc1',
      :id   => 1,
      :mlt_fields    => 'title',
      :min_term_freq => 1
    })
    assert_equal 2, h["hits"]["total"]

    h = @docs.more_like_this({
      :facets => {
        "author" => {
          :terms => {
            :field => "author"
          }
        }
      }
    }, {
      :type => 'doc1',
      :id   => 1,
      :mlt_fields    => 'title,author',
      :min_term_freq => 1
    })
    assert_equal 2, h["hits"]["total"]
    assert_equal 2, h["facets"]["author"]["total"]
  end

  it 'explains scoring' do
    populate!

    h = @docs.explain({
      :query => {
        :field => {
          "author" => "defunkt"
        }
      }
    }, :type => 'doc1', :id => 2)
    assert_equal true, h["matched"]

    h = @docs.explain(:type => 'doc2', :id => 2, :q => "pea53")
    assert_equal false, h["matched"]
  end

  it 'validates queries' do
    populate!

    h = @docs.validate :q => '*:*'
    assert_equal true, h["valid"]

    h = @docs.validate({
      :filtered => {
        :query => {:match_all => {}},
        :filter => {:term => {:author => 'defunkt'}}
      }
    }, :type => %w[doc1 doc2] )
    assert_equal true, h["valid"]
  end

  it 'updates documents' do
    populate!

    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal true, h['exists']
    assert_equal 'mojombo', h['_source']['author']

    @docs.update({
      :_id   => '1',
      :_type => 'doc1',
      :doc   => {:author => 'TwP'}
    })
    h = @docs.get :id => '1', :type => 'doc1'
    assert_equal true, h['exists']
    assert_equal 'TwP', h['_source']['author']

    @docs.update({
      :_id   => '42',
      :_type => 'doc1',
      :doc   => {
        :author => 'TwP',
        :title  => 'the ineffable beauty of search'
      },
      :doc_as_upsert => true
    })
    h = @docs.get :id => '42', :type => 'doc1'
    assert_equal true, h['exists']
    assert_equal 'TwP', h['_source']['author']
    assert_equal 'the ineffable beauty of search', h['_source']['title']
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
