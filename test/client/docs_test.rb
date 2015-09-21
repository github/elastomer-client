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
              :title  => { :type => 'string', :analyzer => 'standard', :term_vector => 'with_positions_offsets' },
              :author => { :type => 'string', :index => 'not_analyzed' }
            }
          }
        }

      wait_for_index(@name)
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

    assert_created h
    assert_match %r/^\S{20,22}$/, h['_id']

    h = @docs.index \
          :_id    => nil,
          :_type  => 'doc3',
          :title  => 'the author of rubber-band',
          :author => 'grantr'

    assert_created h
    assert_match %r/^\S{20,22}$/, h['_id']

    h = @docs.index \
          :_id    => '',
          :_type  => 'doc4',
          :title  => 'the author of toml',
          :author => 'mojombo'

    assert_created h
    assert_match %r/^\S{20,22}$/, h['_id']
  end

  it 'uses the provided document ID' do
    h = @docs.index \
          :_id    => '42',
          :_type  => 'doc2',
          :title  => 'the author of logging',
          :author => 'pea53'

    assert_created h
    assert_equal '42', h['_id']
  end

  it 'accepts JSON encoded document strings' do
    h = @docs.index \
          '{"author":"pea53", "title":"the author of logging"}',
          :id   => '42',
          :type => 'doc2'

    assert_created h
    assert_equal '42', h['_id']

    h = @docs.index \
          '{"author":"grantr", "title":"the author of rubber-band"}',
          :type => 'doc2'

    assert_created h
    assert_match %r/^\S{20,22}$/, h['_id']
  end

  it 'extracts underscore attributes from the document' do
    doc = {
      :_id => '12',
      :_type => 'doc2',
      :_routing => 'author',
      '_consistency' => 'all',
      :title => "The Adventures of Huckleberry Finn",
      :author => "Mark Twain",
      :_unknown => "unknown attribute"
    }

    h = @docs.index doc
    assert_created h
    assert_equal '12', h['_id']

    refute doc.key?(:_id)
    refute doc.key?(:_type)
    refute doc.key?(:_routing)
    refute doc.key?('_consistency')
    assert doc.key?(:_unknown)
  end

  it 'gets documents from the search index' do
    h = @docs.get :id => '1', :type => 'doc1'
    refute_found h

    populate!

    h = @docs.get :id => '1', :type => 'doc1'
    assert_found h
    assert_equal 'mojombo', h['_source']['author']
  end

  it 'checks if documents exist in the search index' do
    refute @docs.exists?(:id => '1', :type => 'doc1')
    populate!
    assert @docs.exists?(:id => '1', :type => 'doc1')
  end

  it 'checks if documents exist in the search index with .exist?' do
    refute @docs.exist?(:id => '1', :type => 'doc1')
    populate!
    assert @docs.exist?(:id => '1', :type => 'doc1')
  end

  it 'gets multiple documents from the search index' do
    populate!

    h = @docs.multi_get :docs => [
      { :_id => 1, :_type => 'doc1' },
      { :_id => 1, :_type => 'doc2' }
    ]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[mojombo pea53], authors

    h = @docs.multi_get({:ids => [2, 1]}, :type => 'doc1')
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[defunkt mojombo], authors

    h = @index.docs('doc1').multi_get :ids => [1, 2, 3, 4]
    assert_found h['docs'][0]
    assert_found h['docs'][1]
    refute_found h['docs'][2]
    refute_found h['docs'][3]
  end

  it 'gets multiple documents from the search index with .mget' do
    populate!

    h = @docs.mget :docs => [
      { :_id => 1, :_type => 'doc1' },
      { :_id => 1, :_type => 'doc2' }
    ]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[mojombo pea53], authors

    h = @docs.mget({:ids => [2, 1]}, :type => 'doc1')
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[defunkt mojombo], authors

    h = @index.docs('doc1').mget :ids => [1, 2, 3, 4]
    assert_found h['docs'][0]
    assert_found h['docs'][1]
    refute_found h['docs'][2]
    refute_found h['docs'][3]
  end

  it 'deletes documents from the search index' do
    populate!
    @docs = @index.docs('doc2')

    h = @docs.multi_get :ids => [1, 2]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[pea53 grantr], authors

    h = @docs.delete :id => 1
    assert h['found'], "expected document to be found"
    h = @docs.multi_get :ids => [1, 2]
    refute_found h['docs'][0]
    assert_found h['docs'][1]

    assert_raises(ArgumentError) { @docs.delete :id => nil }
    assert_raises(ArgumentError) { @docs.delete :id => '' }
    assert_raises(ArgumentError) { @docs.delete :id => "\t" }
  end

  it 'does not care if you delete a document that is not there' do
    @docs = @index.docs('doc2')
    h = @docs.delete :id => 42

    refute h['found'], 'expected document to not be found'
  end

  it 'deletes documents by query' do
    populate!
    @docs = @index.docs('doc2')

    h = @docs.multi_get :ids => [1, 2]
    authors = h['docs'].map { |d| d['_source']['author'] }
    assert_equal %w[pea53 grantr], authors

    h = @docs.delete_by_query(:q => "author:grantr", :index => @index.name)
    assert_equal(h['_indices'], {
      '_all' => {
        'found' => 1,
        'deleted' => 1,
        'missing' => 0,
        'failed' => 0,
      },
      @name => {
        'found' => 1,
        'deleted' => 1,
        'missing' => 0,
        'failed' => 0,
      },
    })
    @index.refresh
    h = @docs.multi_get :ids => [1, 2]
    assert_found h['docs'][0]
    refute_found h['docs'][1]

    #COMPATIBILITY
    # ES 1.0 normalized all search APIs to use a :query top level element.
    # This broke compatibility with the ES 0.90 delete_by_query api. Since
    # the query hash version of this api never worked with 0.90 in the first
    # place, only test it if running 1.0.
    if es_version_1_x?
      h = @docs.delete_by_query({
            :query => {
              :filtered => {
                :query => {:match_all => {}},
                :filter => {:term => {:author => 'pea53'} } } } },
            :index => @index.name)
      @index.refresh
      h = @docs.multi_get :ids => [1, 2]
      refute_found h['docs'][0]
      refute_found h['docs'][1]
    end
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

  it 'supports the shards search API' do
    if es_version_supports_search_shards?
      h = @docs.search_shards(:type => 'docs1')

      assert h.key?("nodes"), "response contains \"nodes\" information"
      assert h.key?("shards"), "response contains \"shards\" information"
      assert h["shards"].is_a?(Array), "\"shards\" is an array"
    end
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

    #COMPATIBILITY
    # ES 1.0 normalized all search APIs to use a :query top level element.
    # This broke compatibility with the ES 0.90 count api.
    if es_version_1_x?
      h = @docs.count({
        :query => {
          :filtered => {
            :query => {:match_all => {}},
            :filter => {:term => {:author => 'defunkt'}}
          }
        }
      }, :type => %w[doc1 doc2] )
    else
      h = @docs.count({
        :filtered => {
          :query => {:match_all => {}},
          :filter => {:term => {:author => 'defunkt'}}
        }
      }, :type => %w[doc1 doc2] )
    end
    assert_equal 1, h['count']
  end

  it 'searches for more like this' do
    populate!

    # for some reason, if there's no document indexed here all the mlt
    # queries return zero results
    @docs.index \
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
        :match => {
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

    #COMPATIBILITY
    # ES 1.0 normalized all search APIs to use a :query top level element.
    # This broke compatibility with the ES 0.90 validate api.
    if es_version_1_x?
      h = @docs.validate({
        :query => {
          :filtered => {
            :query => {:match_all => {}},
            :filter => {:term => {:author => 'defunkt'}}
          }
        }
      }, :type => %w[doc1 doc2] )
    else
      h = @docs.validate({
        :filtered => {
          :query => {:match_all => {}},
          :filter => {:term => {:author => 'defunkt'}}
        }
      }, :type => %w[doc1 doc2] )
    end
    assert_equal true, h["valid"]
  end

  it 'updates documents' do
    populate!

    h = @docs.get :id => '1', :type => 'doc1'
    assert_found h
    assert_equal 'mojombo', h['_source']['author']

    @docs.update({
      :_id   => '1',
      :_type => 'doc1',
      :doc   => {:author => 'TwP'}
    })
    h = @docs.get :id => '1', :type => 'doc1'
    assert_found h
    assert_equal 'TwP', h['_source']['author']

    if $client.version >= "0.90"
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
      assert_found h
      assert_equal 'TwP', h['_source']['author']
      assert_equal 'the ineffable beauty of search', h['_source']['title']
    end
  end

  it 'supports bulk operations with the same parameters as docs' do
    response = @docs.bulk do |b|
      populate!(b)
    end

    assert_instance_of Fixnum, response['took']

    response = @docs.get(:id => 1, :type => 'doc1')
    assert_found response
    assert_equal 'mojombo', response['_source']['author']
  end

  if es_version_1_x?
    it 'provides access to term vector statistics' do
      populate!

      response = @docs.termvector :type => 'doc2', :id => 1, :fields => 'title'

      assert response['term_vectors']['title']
      assert response['term_vectors']['title']['field_statistics']
      assert response['term_vectors']['title']['terms']
      assert_equal %w[author logging of the], response['term_vectors']['title']['terms'].keys
    end

    it 'provides access to term vector statistics with .termvectors' do
      populate!

      response = @docs.termvectors :type => 'doc2', :id => 1, :fields => 'title'

      assert response['term_vectors']['title']
      assert response['term_vectors']['title']['field_statistics']
      assert response['term_vectors']['title']['terms']
      assert_equal %w[author logging of the], response['term_vectors']['title']['terms'].keys
    end

    it 'provides access to term vector statistics with .term_vector' do
      populate!

      response = @docs.term_vector :type => 'doc2', :id => 1, :fields => 'title'

      assert response['term_vectors']['title']
      assert response['term_vectors']['title']['field_statistics']
      assert response['term_vectors']['title']['terms']
      assert_equal %w[author logging of the], response['term_vectors']['title']['terms'].keys
    end

    it 'provides access to term vector statistics with .term_vectors' do
      populate!

      response = @docs.term_vectors :type => 'doc2', :id => 1, :fields => 'title'

      assert response['term_vectors']['title']
      assert response['term_vectors']['title']['field_statistics']
      assert response['term_vectors']['title']['terms']
      assert_equal %w[author logging of the], response['term_vectors']['title']['terms'].keys
    end

    it 'provides access to multi term vector statistics' do
      populate!

      response = @docs.multi_termvectors({:ids => [1, 2]}, :type => 'doc2', :fields => 'title', :term_statistics => true)
      docs = response['docs']

      assert docs
      assert_equal(%w[1 2], docs.map { |h| h['_id'] }.sort)
    end

    it 'provides access to multi term vector statistics with .multi_term_vectors' do
      populate!

      response = @docs.multi_term_vectors({:ids => [1, 2]}, :type => 'doc2', :fields => 'title', :term_statistics => true)
      docs = response['docs']

      assert docs
      assert_equal(%w[1 2], docs.map { |h| h['_id'] }.sort)
    end
  end

  # Create/index multiple documents.
  #
  # docs - An instance of Elastomer::Client::Docs or Elastomer::Client::Bulk. If
  #        nil uses the @docs instance variable.
  def populate!(docs = @docs)
    docs.index \
      :_id    => 1,
      :_type  => 'doc1',
      :title  => 'the author of gravatar',
      :author => 'mojombo'

    docs.index \
      :_id    => 2,
      :_type  => 'doc1',
      :title  => 'the author of resque',
      :author => 'defunkt'

    docs.index \
      :_id    => 1,
      :_type  => 'doc2',
      :title  => 'the author of logging',
      :author => 'pea53'

    docs.index \
      :_id    => 2,
      :_type  => 'doc2',
      :title  => 'the author of rubber-band',
      :author => 'grantr'

    @index.refresh
  end

end
