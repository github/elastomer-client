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
    @cluster.update_settings :transient => { 'indices.ttl.interval' => "30" }
    h = @cluster.settings
    assert_equal "30", h['transient']['indices.ttl.interval']

    @cluster.update_settings :transient => { 'indices.ttl.interval' => "60" }
    h = @cluster.settings
    assert_equal "60", h['transient']['indices.ttl.interval']
  end

  it 'returns the list of nodes in the cluster' do
    nodes = @cluster.nodes
    assert !nodes.empty?, 'we have to have some nodes'
  end

end
