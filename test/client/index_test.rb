require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Index do

  before do
    @name  = 'index-test'
    @index = $client.index @name
  end

  after do
    @index.delete if @index.exists?
  end

  it 'requires an index name' do
    assert_raises(ArgumentError) { $client.index }
  end

  it 'determines if an index exists' do
    assert !@index.exists?, 'the index should not yet exist'
  end

  describe 'when creating an index' do
    it 'creates an index' do
      @index.create :settings => { :number_of_shards => 3, :number_of_replicas => 0 }
      assert @index.exists?, 'the index should now exist'

      settings = @index.settings[@name]
      assert_equal '3', settings['settings']['index.number_of_shards']
      assert_equal '0', settings['settings']['index.number_of_replicas']
    end

    it 'adds mappings for document types' do
      @index.create(
        :settings => { :number_of_shards => 1, :number_of_replicas => 0 },
        :mappings => {
          :doco => {
            :_source => { :enabled => false },
            :_all    => { :enabled => false },
            :properties => {
              :title  => { :type => 'string', :analyzer => 'standard' },
              :author => { :type => 'string', :index => 'not_analyzed' }
            }
          }
        }
      )
      assert @index.exists?, 'the index should now exist'

      mapping = @index.mapping[@name]
      assert mapping.key?('doco'), 'the doco mapping is present'
    end
  end

end
