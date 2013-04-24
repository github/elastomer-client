require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Index do

  before do
    @name  = 'elastomer-index-test'
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

      settings = @index.settings[@name]['settings']
      assert_equal '3', settings['index.number_of_shards']
      assert_equal '0', settings['index.number_of_replicas']
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

  it 'updates index settings' do
    @index.create :settings => { :number_of_shards => 1, :number_of_replicas => 0 }

    @index.update_settings 'index.number_of_replicas' => 1
    settings = @index.settings[@name]['settings']
    assert_equal '1', settings['index.number_of_replicas']
  end

  it 'updates document mappings' do
    @index.create(
      :mappings => {
        :doco => {
          :_source => { :enabled => false },
          :_all    => { :enabled => false },
          :properties => {:title  => { :type => 'string', :analyzer => 'standard' }}
        }
      }
    )
    properties = @index.mapping[@name]['doco']['properties']
    assert_equal %w[title], properties.keys.sort

    @index.update_mapping 'doco', { :doco => { :properties => {
      :author => { :type => 'string', :index => 'not_analyzed' }
    }}}
    properties = @index.mapping[@name]['doco']['properties']
    assert_equal %w[author title], properties.keys.sort

    @index.update_mapping 'mux_mool', { :mux_mool => { :properties => {
      :song => { :type => 'string', :index => 'not_analyzed' }
    }}}
    properties = @index.mapping[@name]['mux_mool']['properties']
    assert_equal %w[song], properties.keys.sort
  end

  it 'deletes document mappings' do
    @index.create(
      :mappings => {
        :doco => {
          :_source => { :enabled => false },
          :_all    => { :enabled => false },
          :properties => {:title  => { :type => 'string', :analyzer => 'standard' }}
        }
      }
    )
    assert @index.mapping[@name].key?('doco'), 'we should have a "doco" mapping'

    @index.delete_mapping 'doco'
    assert !@index.mapping[@name].key?('doco'), 'we should no longer have a "doco" mapping'
  end

  it 'lists all aliases to the index' do
    assert_empty @index.get_aliases, 'no aliases for an index that does not exist'

    @index.create(nil)
    assert_equal({@name => {'aliases' => {}}}, @index.get_aliases)

    $client.cluster.aliases :add => {:index => @name, :alias => 'foofaloo'}
    assert_equal({@name => {'aliases' => {'foofaloo' => {}}}}, @index.get_aliases)
  end

  it 'analyzes text and returns tokens' do
    tokens = @index.analyze 'Just a few words to analyze.', :index => nil
    tokens = tokens['tokens'].map { |h| h['token'] }
    assert_equal %w[just few words analyze], tokens

    tokens = @index.analyze 'Just a few words to analyze.', :analyzer => 'simple', :index => nil
    tokens = tokens['tokens'].map { |h| h['token'] }
    assert_equal %w[just a few words to analyze], tokens
  end

  describe "when an index exists" do
    before do
      @index.create(nil)
    end

    #TODO assert this only hits the desired index
    it 'deletes' do
      response = @index.delete
      assert_equal true, response["ok"]
    end

    it 'opens' do
      response = @index.open
      assert_equal true, response["ok"]
    end

    it 'closes' do
      response = @index.close
      assert_equal true, response["ok"]
    end

    it 'refreshes' do
      response = @index.refresh
      assert_equal true, response["ok"]
    end

    it 'flushes' do
      response = @index.flush
      assert_equal true, response["ok"]
    end

    it 'optimizes' do
      response = @index.optimize
      assert_equal true, response["ok"]
    end

    it 'snapshots' do
      response = @index.snapshot
      assert_equal true, response["ok"]
    end

    it 'gets stats' do
      response = @index.stats
      assert_includes response["_all"]["indices"], "elastomer-index-test"
    end

    it 'gets status' do
      response = @index.status
      assert_includes response["indices"], "elastomer-index-test"
    end

  end
end
