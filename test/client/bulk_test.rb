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

  it 'performs a bulk index action' do
    body = [
      '{"index" : {"_id":"1", "_type":"tweet"}}',
      '{"author":"pea53", "message":"just a test tweet"}',
      '{"index" : {"_id":"1", "_type":"book"}}',
      '{"author":"John Scalzi", "title":"Old Mans War"}',
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body, :index => @name

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

end
