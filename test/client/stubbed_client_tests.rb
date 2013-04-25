require File.expand_path('../../test_helper', __FILE__)

describe 'stubbed client tests' do
  before do
    @stubs  = Faraday::Adapter.lookup_middleware(:test)::Stubs.new
    @client = Elastomer::Client.new :adapter => [:test, @stubs]
  end

  describe Elastomer::Client::Cluster do
    it 'reroutes shards' do
      @stubs.post '/_cluster/reroute?dry_run=true' do |env|
        assert_match %r/^\{"commands":\[\{"move":\{[^\{\}]+\}\}\]\}$/, env[:body]
        [200, {'Content-Type' => 'application/json'}, '{"ok" : true}']
      end

      commands = { :move => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' }}
      h = @client.cluster.reroute commands, :dry_run => true
      assert_equal true, h['ok']
    end

    it 'performs a shutdown of the cluster' do
      @stubs.post('/_shutdown') { [200, {'Content-Type' => 'application/json'}, '{"ok" : true}'] }
      h = @client.cluster.shutdown
      assert_equal true, h['ok']
    end
  end

  describe Elastomer::Client::Nodes do
    it 'performs a shutdown of the node(s)' do
      @stubs.post('/_cluster/nodes/_shutdown')       { [200, {'Content-Type' => 'application/json'}, '{"ok":true}'] }
      @stubs.post('/_cluster/nodes/node1/_shutdown') { [200, {'Content-Type' => 'application/json'}, '{"ok":"node1"}'] }

      h = @client.nodes.shutdown
      assert_equal true, h['ok']

      h = @client.nodes('node1').shutdown
      assert_equal 'node1', h['ok']
    end
  end
end
