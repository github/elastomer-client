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

      $client.cluster.health \
        :index           => @name,
        :wait_for_status => 'green',
        :timeout         => '5s'
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

    ok = h['items'].map {|a| a['index']['ok']}
    assert_equal [true, true], ok

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

    assert h['items'].first['index']['ok'], 'we added a new book'
    assert h['items'].last['delete']['ok'], 'we removed a book'

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

    assert_instance_of Array, h['took']
    assert_equal 1, h['took'].length

    assert items.first['index']['ok'], 'indexing failed'
    assert items.last['create']['ok'], 'creation failed'

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

    assert items.first['create']['ok'], 'we created a new book'
    assert items.last['delete']['ok'], 'we removed a book'

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

    assert_instance_of Array, h['took']
    assert_equal 1, h['took'].length

    assert items.first['index']['ok'], 'indexing failed'
    assert items.last['create']['ok'], 'creation failed'

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

    assert items.first['index']['ok'], 'we added a new book'
    assert items.last['delete']['ok'], 'we removed a book'

    @index.refresh

    h = @index.docs('book').get :id => 1
    assert !h['exists'], 'was not successfully deleted'

    h = @index.docs('book').get :id => 2
    assert_equal 'Tolkien', h['_source']['author']
  end

  it 'executes a bulk API call when a request size is reached' do
    h = @index.bulk(:request_size => 1024) do |b|
      20.times { |num|
        document = {:_id => num, :_type => 'tweet', :author => 'pea53', :message => "this is tweet number #{num}"}
        b.index document
      }
    end

    assert_equal 2, h['took'].length
    assert h['items'].all? { |a| a['index']['ok'] }, 'all documents were not indexed properly'

    @index.refresh
    h = @index.docs.search :q => '*:*', :search_type => 'count'

    assert_equal 20, h['hits']['total']
  end

end
