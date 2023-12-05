# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Cluster do

  before do
    @name = "elastomer-cluster-test"
    @index = $client.index @name
    @index.delete if @index.exists?
    @cluster = $client.cluster
  end

  after do
    @index.delete if @index.exists?
  end

  it "gets the cluster health" do
    h = @cluster.health

    assert h.key?("cluster_name"), "the cluster name is returned"
    assert h.key?("status"), "the cluster status is returned"
  end

  it "gets the cluster state" do
    h = @cluster.state

    assert h.key?("cluster_name"), "the cluster name is returned"
    assert h.key?("master_node"), "the master node is returned"
    assert_instance_of Hash, h["nodes"], "the node list is returned"
    assert_instance_of Hash, h["metadata"], "the metadata are returned"
  end

  it "filters cluster state by metrics" do
    h = @cluster.state(metrics: "nodes")

    refute h.key("metadata"), "expected only nodes state"
    h = @cluster.state(metrics: "metadata")

    refute h.key("nodes"), "expected only metadata state"
  end

  it "filters cluster state by indices" do
    @index.create(default_index_settings) unless @index.exists?
    h = @cluster.state(metrics: "metadata", indices: @name)

    assert_equal [@name], h["metadata"]["indices"].keys
  end

  it "gets the cluster settings" do
    h = @cluster.get_settings

    assert_instance_of Hash, h["persistent"], "the persistent settings are returned"
    assert_instance_of Hash, h["transient"], "the transient settings are returned"
  end

  it "gets the cluster settings with .settings" do
    h = @cluster.settings

    assert_instance_of Hash, h["persistent"], "the persistent settings are returned"
    assert_instance_of Hash, h["transient"], "the transient settings are returned"
  end

  it "updates the cluster settings" do
    @cluster.update_settings transient: { "indices.recovery.max_bytes_per_sec" => "30mb" }
    h = @cluster.settings

    value = h["transient"]["indices"]["recovery"]["max_bytes_per_sec"]

    assert_equal "30mb", value

    @cluster.update_settings transient: { "indices.recovery.max_bytes_per_sec" => "60mb" }
    h = @cluster.settings

    value = h["transient"]["indices"]["recovery"]["max_bytes_per_sec"]

    assert_equal "60mb", value
  end

  it "returns cluster stats" do
    h = @cluster.stats
    expected = $client.version_support.es_version_8_plus? ? %w[cluster_name cluster_uuid indices nodes status timestamp] : %w[cluster_name indices nodes status timestamp]
    expected.unshift("_nodes")

    assert_equal expected, h.keys.sort
  end

  it "returns a list of pending tasks" do
    h = @cluster.pending_tasks

    assert_equal %w[tasks], h.keys.sort
    assert h["tasks"].is_a?(Array), "the tasks lists is always an Array even if empty"
  end

  it "returns the list of indices in the cluster" do
    @index.create(default_index_settings) unless @index.exists?
    indices = @cluster.indices

    refute_empty indices, "expected to see an index"
  end

  it "returns the list of nodes in the cluster" do
    nodes = @cluster.nodes

    refute_empty nodes, "we have to have some nodes"
  end

  describe "when working with aliases" do
    before do
      @name = "elastomer-cluster-test"
      @index = $client.index @name
      @index.create(default_index_settings) unless @index.exists?
      wait_for_index(@name)
    end

    after do
      @index.delete if @index.exists?
    end

    it "adds and gets an alias" do
      hash = @cluster.get_aliases

      assert_empty hash[@name]["aliases"]

      @cluster.update_aliases \
        add: {index: @name, alias: "elastomer-test-unikitty"}

      hash = @cluster.get_aliases

      assert_equal ["elastomer-test-unikitty"], hash[@name]["aliases"].keys
    end

    it "adds and gets an alias with .aliases" do
      hash = @cluster.aliases

      assert_empty hash[@name]["aliases"]

      @cluster.update_aliases \
        add: {index: @name, alias: "elastomer-test-unikitty"}

      hash = @cluster.aliases

      assert_equal ["elastomer-test-unikitty"], hash[@name]["aliases"].keys
    end

    it "removes an alias" do
      @cluster.update_aliases \
        add: {index: @name, alias: "elastomer-test-unikitty"}

      hash = @cluster.get_aliases

      assert_equal ["elastomer-test-unikitty"], hash[@name]["aliases"].keys

      @cluster.update_aliases([
        {add:    {index: @name, alias: "elastomer-test-SpongeBob-SquarePants"}},
        {remove: {index: @name, alias: "elastomer-test-unikitty"}}
      ])

      hash = @cluster.get_aliases

      assert_equal ["elastomer-test-SpongeBob-SquarePants"], hash[@name]["aliases"].keys
    end

    it "accepts the full aliases actions hash" do
      @cluster.update_aliases actions: [
        {add: {index: @name, alias: "elastomer-test-He-Man"}},
        {add: {index: @name, alias: "elastomer-test-Skeletor"}}
      ]

      hash = @cluster.get_aliases(index: @name)

      assert_equal %w[elastomer-test-He-Man elastomer-test-Skeletor], hash[@name]["aliases"].keys.sort
    end
  end

end
