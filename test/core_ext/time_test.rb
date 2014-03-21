require File.expand_path('../../test_helper', __FILE__)
require 'elastomer/core_ext/time'

describe 'JSON conversions for Time' do
  before do
    @name  = 'elastomer-time-test'
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { 'index.number_of_shards' => 1, 'index.number_of_replicas' => 0 },
        :mappings => {
          :doc1 => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title      => { :type => 'string', :index => 'not_analyzed' },
              :created_at => { :type => 'date' }
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

  it 'generates ISO8601 formatted time strings' do
    time = Time.utc(2013, 5, 3, 10, 1, 31)
    assert_equal '"2013-05-03T10:01:31Z"', MultiJson.encode(time)
  end

  it 'indexes time fields' do
    time = Time.utc(2013, 5, 3, 10, 1, 31)
    h = @docs.index({:title => 'test document', :created_at => time}, :type => 'doc1')

    assert h['created'], 'document was not created'

    doc = @docs.get(:type => 'doc1', :id => h['_id'])
    assert_equal '2013-05-03T10:01:31Z', doc['_source']['created_at']
  end
end
