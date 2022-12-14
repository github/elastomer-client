require_relative "../test_helper"

describe Elastomer::Client::Nodes do

  it "gets info for the node(s)" do
    h = $client.nodes.info
    assert h.key?("cluster_name"), "the cluster name is returned"
    assert_instance_of Hash, h["nodes"], "the node list is returned"
  end

  it "gets stats for the node(s)" do
    h = $client.nodes.stats
    assert_instance_of Hash, h["nodes"], "the node list is returned"

    node = h["nodes"].values.first
    assert node.key?("indices"), "indices stats are returned"
  end

  it "filters node info" do
    h = $client.nodes.info(info: "os")
    node = h["nodes"].values.first
    assert node.key?("os"), "expected os info to be present"
    assert !node.key?("jvm"), "expected jvm info to be absent"

    h = $client.nodes.info(info: %w[jvm process])
    node = h["nodes"].values.first
    assert node.key?("jvm"), "expected jvm info to be present"
    assert node.key?("process"), "expected process info to be present"
    assert !node.key?("network"), "expected network info to be absent"
  end

  it "filters node stats" do
    h = $client.nodes.stats(stats: "http")
    node = h["nodes"].values.first
    assert node.key?("http"), "expected http stats to be present"
    assert !node.key?("indices"), "expected indices stats to be absent"
  end

  it "gets the hot threads for the node(s)" do
    str = $client.nodes.hot_threads read_timeout: 2
    assert_instance_of String, str
    assert !str.nil?, "expected response to not be nil"
    assert !str.empty?, "expected response to not be empty"
  end

  it "can be scoped to a single node" do
    h = $client.nodes("node-with-no-name").info
    assert_empty h["nodes"]
  end

  it "can be scoped to multiple nodes" do
    h = $client.nodes(%w[node1 node2 node3]).info
    assert_empty h["nodes"]
  end

end
