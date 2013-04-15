require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Cluster do

  before do
    @cluster = $client.cluster
  end

  it 'gets the cluster health' do
    h = @cluster.health
    assert h.key?('cluster_name'), 'the cluster name is returned'
    assert h.key?('status'), 'the cluster status is returned'
  end

  it 'gets the cluster state' do
    h = @cluster.state
    assert h.key?('cluster_name'), 'the cluster name is returned'
    assert h.key?('master_node'), 'the master node is returned'
    assert_instance_of Hash, h['nodes'], 'the node list is returned'
  end

  it 'gets the cluster settings' do
    h = @cluster.settings
    assert_instance_of Hash, h['persistent'], 'the persistent settings are returned'
    assert_instance_of Hash, h['transient'], 'the transient settings are returned'
  end

  it 'updates the cluster settings' do
    @cluster.update_settings :transient => { 'cluster.blocks.read_only' => true }
    h = @cluster.settings
    assert_equal({'cluster.blocks.read_only' => 'true'}, h['transient'])

    @cluster.update_settings :transient => { 'cluster.blocks.read_only' => false }
    h = @cluster.settings
    assert_equal({'cluster.blocks.read_only' => 'false'}, h['transient'])
  end

  it 'reroutes shards' do
    stubs = Faraday::Adapter.lookup_middleware(:test)::Stubs.new
    client = Elastomer::Client.new :adapter => [:test, stubs]
    @cluster = client.cluster

    stubs.post '/_cluster/reroute?dry_run=true' do |env|
      assert_match %r/^\{"commands":\[\{"move":\{[^\{\}]+\}\}\]\}$/, env[:body]

      [200, {'Content-Type' => 'application/json'}, '{"ok" : true}']
    end

    commands = { :move => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' }}
    h = @cluster.reroute commands, :dry_run => true
    assert h['ok']
  end

  it 'performas a shutdown of the cluster' do
    stubs = Faraday::Adapter.lookup_middleware(:test)::Stubs.new
    client = Elastomer::Client.new :adapter => [:test, stubs]
    @cluster = client.cluster

    stubs.post('/_shutdown') { [200, {'Content-Type' => 'application/json'}, '{"ok" : true}'] }
    h = @cluster.shutdown
    assert h['ok']
  end

  it 'returns the list of nodes in the cluster' do
    nodes = @cluster.nodes
    assert !nodes.empty?, 'we have to have some nodes'
  end

end
