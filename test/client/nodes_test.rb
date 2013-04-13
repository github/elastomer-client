require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Nodes do

  it 'gets info for the ndoe(s)' do
    h = $client.nodes.info
    assert h.key?('cluster_name'), 'the cluster name is returned'
    assert_instance_of Hash, h['nodes'], 'the node list is returned'
  end

  it 'gets stats for the node(s)' do
    h = $client.nodes.stats
    assert_instance_of Hash, h['nodes'], 'the node list is returned'

    node = h['nodes'].values.first
    assert node.key?('indices'), 'indices stats are returned'
  end

  it 'gets the hot threads for the node(s)' do
    str = $client.nodes.hot_threads
    assert_instance_of String, str
    assert_match %r/cpu usage by thread/, str
  end

  it 'performas a shutdown of the node(s)' do
    skip 'need to figure out how to noop the test and assert the path is constructed correctly'
  end

end
