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
    h = @cluster.settings :flat_settings => true
    assert_equal 'true', h['transient']['cluster.blocks.read_only']

    @cluster.update_settings :transient => { 'cluster.blocks.read_only' => false }
    h = @cluster.settings :flat_settings => true
    assert_equal 'false', h['transient']['cluster.blocks.read_only']
  end

  it 'returns the list of nodes in the cluster' do
    nodes = @cluster.nodes
    assert !nodes.empty?, 'we have to have some nodes'
  end

end
