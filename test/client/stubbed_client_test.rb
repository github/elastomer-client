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
        [200, {'Content-Type' => 'application/json'}, '{"acknowledged" : true}']
      end

      commands = { :move => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' }}
      h = @client.cluster.reroute commands, :dry_run => true
      assert_acknowledged h
    end

    it 'performs a shutdown of the cluster' do
      @stubs.post('/_shutdown') { [200, {'Content-Type' => 'application/json'}, '{"cluster_name":"elasticsearch"}'] }
      h = @client.cluster.shutdown
      assert_equal "elasticsearch", h['cluster_name']
    end
  end

  describe Elastomer::Client::Nodes do
    it 'performs a shutdown of the node(s)' do
      @stubs.post('/_cluster/nodes/_all/_shutdown')  { [200, {'Content-Type' => 'application/json'}, '{"nodes":{"1":{"name":"Node1"}}}'] }
      @stubs.post('/_cluster/nodes/node2/_shutdown') { [200, {'Content-Type' => 'application/json'}, '{"nodes":{"2":{"name":"Node2"}}}'] }

      h = @client.nodes.shutdown
      assert_equal "Node1", h['nodes']['1']['name']

      h = @client.nodes('node2').shutdown
      assert_equal 'Node2', h['nodes']['2']['name']
    end
  end
end
