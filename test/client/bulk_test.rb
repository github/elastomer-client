require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Bulk do

  before do
    @name  = 'elastomer-bulk-test'
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { 'index.number_of_shards' => 1, 'index.number_of_replicas' => 0 },
        :mappings => {
          :tweet => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :message => { :type => 'string', :analyzer => 'standard' },
              :author  => { :type => 'string', :index => 'not_analyzed' }
            }
          },
          :book => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => { :type => 'string', :analyzer => 'standard' },
              :author => { :type => 'string', :index => 'not_analyzed' }
            }
          }
        }

      wait_for_index(@name)
    end
  end

  after do
    @index.delete if @index.exists?
  end

  it 'performs bulk index actions' do
    body = [
      '{"index" : {"_id":"1", "_type":"tweet", "_index":"elastomer-bulk-test"}}',
      '{"author":"pea53", "message":"just a test tweet"}',
      '{"index" : {"_id":"1", "_type":"book", "_index":"elastomer-bulk-test"}}',
      '{"author":"John Scalzi", "title":"Old Mans War"}',
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body

    assert_bulk_index(h['items'][0])
    assert_bulk_index(h['items'][1])

    @index.refresh

    h = @index.docs('tweet').get :id => 1
    assert_equal 'pea53', h['_source']['author']

    h = @index.docs('book').get :id => 1
    assert_equal 'John Scalzi', h['_source']['author']


    body = [
      '{"index" : {"_id":"2", "_type":"book"}}',
      '{"author":"Tolkien", "title":"The Silmarillion"}',
      '{"delete" : {"_id":"1", "_type":"book"}}',
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body, :index => @name

    assert_bulk_index h['items'].first, 'expected to index a book'
    assert_bulk_delete h['items'].last, 'expected to delete a book'

    @index.refresh

    h = @index.docs('book').get :id => 1
    assert !h['exists'], 'was not successfully deleted'

    h = @index.docs('book').get :id => 2
    assert_equal 'Tolkien', h['_source']['author']
  end

  it 'supports a nice block syntax' do
    h = @index.bulk do |b|
      b.index :_id => 1,   :_type => 'tweet', :author => 'pea53', :message => 'just a test tweet'
      b.index :_id => nil, :_type => 'book', :author => 'John Scalzi', :title => 'Old Mans War'
    end
    items = h['items']

    assert_instance_of Fixnum, h['took']

    assert_bulk_index h['items'].first
    assert_bulk_create h['items'].last

    book_id = items.last['create']['_id']
    assert_match %r/^\S{22}$/, book_id

    @index.refresh

    h = @index.docs('tweet').get :id => 1
    assert_equal 'pea53', h['_source']['author']

    h = @index.docs('book').get :id => book_id
    assert_equal 'John Scalzi', h['_source']['author']


    h = @index.bulk do |b|
      b.index  :_id => '', :_type => 'book', :author => 'Tolkien', :title => 'The Silmarillion'
      b.delete :_id => book_id, :_type => 'book'
    end
    items = h['items']

    assert_bulk_create h['items'].first, 'expected to create a book'
    assert_bulk_delete h['items'].last, 'expected to delete a book'

    book_id2 = items.first['create']['_id']
    assert_match %r/^\S{22}$/, book_id2

    @index.refresh

    h = @index.docs('book').get :id => book_id
    assert !h['exists'], 'was not successfully deleted'

    h = @index.docs('book').get :id => book_id2
    assert_equal 'Tolkien', h['_source']['author']
  end

  it 'allows documents to be JSON strings' do
    h = @index.bulk do |b|
      b.index  '{"author":"pea53", "message":"just a test tweet"}', :_id => 1, :_type => 'tweet'
      b.create '{"author":"John Scalzi", "title":"Old Mans War"}',  :_id => 1, :_type => 'book'
    end
    items = h['items']

    assert_instance_of Fixnum, h['took']

    assert_bulk_index h['items'].first
    assert_bulk_create h['items'].last

    @index.refresh

    h = @index.docs('tweet').get :id => 1
    assert_equal 'pea53', h['_source']['author']

    h = @index.docs('book').get :id => 1
    assert_equal 'John Scalzi', h['_source']['author']


    h = @index.bulk do |b|
      b.index '{"author":"Tolkien", "title":"The Silmarillion"}', :_id => 2, :_type => 'book'
      b.delete :_id => 1, :_type => 'book'
    end
    items = h['items']

    assert_bulk_index h['items'].first, 'expected to index a book'
    assert_bulk_delete h['items'].last, 'expected to delete a book'

    @index.refresh

    h = @index.docs('book').get :id => 1
    assert !h['exists'], 'was not successfully deleted'

    h = @index.docs('book').get :id => 2
    assert_equal 'Tolkien', h['_source']['author']
  end

  it 'executes a bulk API call when a request size is reached' do
    ary = []
    ary << @index.bulk(:request_size => 300) do |b|
      2.times { |num|
        document = {:_id => num, :_type => 'tweet', :author => 'pea53', :message => "tweet #{num} is a 100 character request"}
        ary << b.index(document)
      }
      ary.compact!
      assert_equal 0, ary.length

      7.times { |num|
        document = {:_id => num+2, :_type => 'tweet', :author => 'pea53', :message => "tweet #{num+2} is a 100 character request"}
        ary << b.index(document)
      }
      ary.compact!
      assert_equal 3, ary.length

      document = {:_id => 10, :_type => 'tweet', :author => 'pea53', :message => "tweet 10 is a 102 character request"}
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 4, ary.length
    ary.each { |a| a['items'].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search :q => '*:*', :search_type => 'count'

    assert_equal 10, h['hits']['total']
  end

  it 'executes a bulk API call when an action count is reached' do
    ary = []
    ary << @index.bulk(:action_count => 3) do |b|
      2.times { |num|
        document = {:_id => num, :_type => 'tweet', :author => 'pea53', :message => "this is tweet number #{num}"}
        ary << b.index(document)
      }
      ary.compact!
      assert_equal 0, ary.length

      7.times { |num|
        document = {:_id => num+2, :_type => 'tweet', :author => 'pea53', :message => "this is tweet number #{num+2}"}
        ary << b.index(document)
      }
      ary.compact!
      assert_equal 3, ary.length

      document = {:_id => 10, :_type => 'tweet', :author => 'pea53', :message => "this is tweet number 10"}
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 4, ary.length
    ary.each { |a| a['items'].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search :q => '*:*', :search_type => 'count'

    assert_equal 10, h['hits']['total']
  end

  it 'uses :id from parameters' do
    response = @index.bulk do |b|
      document = { :_type => 'tweet', :author => 'pea53', :message => 'just a test tweet' }
      params = { :id => 'foo' }

      b.index document, params
    end

    assert_instance_of Fixnum, response['took']

    items = response['items']
    assert_bulk_index(items[0])

    assert_equal 'foo', items[0]['index']['_id']
  end
end
