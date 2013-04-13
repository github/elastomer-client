require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Cluster do

  it 'gets the cluster health' do
    h = $client.cluster.health
    assert h.key?('cluster_name'), 'the cluster name is returned'
    assert h.key?('status'), 'the cluster status is returned'
  end

  it 'gets the cluster state' do
    h = $client.cluster.state
    assert h.key?('cluster_name'), 'the cluster name is returned'
    assert h.key?('master_node'), 'the master node is returned'
    assert_instance_of Hash, h['nodes'], 'the node list is returned'
  end

  it 'gets the cluster settings' do
    h = $client.cluster.settings
    assert_instance_of Hash, h['persistent'], 'the persistent settings are returned'
    assert_instance_of Hash, h['transient'], 'the transient settings are returned'
  end

  it 'updates the cluster settings' do
    settings = {:transient => { 'cluster.blocks.read_only' => true }}
    $client.cluster.update_settings :body => settings

    h = $client.cluster.settings
    assert_equal({'cluster.blocks.read_only' => 'true'}, h['transient'])

    settings = {:transient => { 'cluster.blocks.read_only' => false }}
    $client.cluster.update_settings :body => settings

    h = $client.cluster.settings
    assert_equal({'cluster.blocks.read_only' => 'false'}, h['transient'])
  end

  it 'reroutes shards' do
    skip 'need to figure out how to noop the test and assert the path is constructed correctly'

    commands = [
      { :move => { :index => 'test', :shard => 0, :from_node => 'node1', :to_node => 'node2' }},
      { :allocate => { :index => 'test', :shard => 1, :node => 'node3' }}
    ]

    h = $client.cluster.reroute :dry_run => true, :body => { :commands => commands }
  end

  it 'performas a shutdown of the cluster' do
    skip 'need to figure out how to noop the test and assert the path is constructed correctly'
  end

end
