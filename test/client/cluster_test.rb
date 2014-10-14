require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Cluster do

  before do
    @name = 'elastomer-cluster-test'
    @index = $client.index @name
    @index.delete if @index.exists?
    @cluster = $client.cluster
  end

  after do
    @index.delete if @index.exists?
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
    assert_instance_of Hash, h['metadata'], 'the metadata are returned'
  end

  if es_version_1_x?
    it 'filters cluster state by metrics' do
      h = @cluster.state(:metrics => 'nodes')
      refute h.key('metadata'), 'expected only nodes state'
      h = @cluster.state(:metrics => 'metadata')
      refute h.key('nodes'), 'expected only metadata state'
    end

    it 'filters cluster state by indices' do
      @index.create({}) unless @index.exists?
      h = @cluster.state(:metrics => 'metadata', :indices => @name)
      assert [@name], h['metadata']['indices'].keys
    end
  end

  it 'gets the cluster settings' do
    h = @cluster.settings
    assert_instance_of Hash, h['persistent'], 'the persistent settings are returned'
    assert_instance_of Hash, h['transient'], 'the transient settings are returned'
  end

  it 'updates the cluster settings' do
    @cluster.update_settings :transient => { 'indices.ttl.interval' => "30" }
    h = @cluster.settings

    #COMPATIBILITY
    # ES 1.0 changed the default return format of cluster settings to always
    # expand nested properties, e.g.
    # {"indices.ttl.interval": "30"} changed to
    # {"indices": {"ttl": {"interval":"30"}}}

    # To support both versions, we check for either return format.
    value = h['transient']['indices.ttl.interval'] ||
            h['transient']['indices']['ttl']['interval']
    assert_equal "30", value

    @cluster.update_settings :transient => { 'indices.ttl.interval' => "60" }
    h = @cluster.settings

    value = h['transient']['indices.ttl.interval'] ||
            h['transient']['indices']['ttl']['interval']
    assert_equal "60", value
  end

  it 'returns cluster stats' do
    h = @cluster.stats
    assert_equal %w[cluster_name indices nodes status timestamp], h.keys.sort
  end

  it 'returns cluster recovery' do
    indices = @cluster.indices.keys.sort
    h = @cluster.recovery
    assert_equal indices, h.keys.sort
  end

  it 'returns a list of pending tasks' do
    h = @cluster.pending_tasks
    assert_equal %w[tasks], h.keys.sort
    assert h['tasks'].is_a?(Array), "the tasks lists is always an Array even if empty"
  end

  it 'returns the list of indices in the cluster' do
    @index.create({}) unless @index.exists?
    indices = @cluster.indices
    assert !indices.empty?, 'expected to see an index'
  end

  it 'returns the list of nodes in the cluster' do
    nodes = @cluster.nodes
    assert !nodes.empty?, 'we have to have some nodes'
  end

  describe 'when working with aliases' do
    before do
      @name = 'elastomer-cluster-test'
      @index = $client.index @name
      @index.create({}) unless @index.exists?
      wait_for_index(@name)
    end

    after do
      @index.delete if @index.exists?
    end

    it 'adds an alias' do
      hash = @cluster.get_aliases
      assert_empty hash[@name]['aliases']

      @cluster.update_aliases \
        :add => {:index => @name, :alias => 'elastomer-test-unikitty'}

      hash = @cluster.get_aliases
      assert_equal ['elastomer-test-unikitty'], hash[@name]['aliases'].keys
    end

    it 'removes an alias' do
      @cluster.update_aliases \
        :add => {:index => @name, :alias => 'elastomer-test-unikitty'}

      hash = @cluster.get_aliases
      assert_equal ['elastomer-test-unikitty'], hash[@name]['aliases'].keys

      @cluster.update_aliases([
        {:add    => {:index => @name, :alias => 'elastomer-test-SpongeBob-SquarePants'}},
        {:remove => {:index => @name, :alias => 'elastomer-test-unikitty'}}
      ])

      hash = @cluster.get_aliases
      assert_equal ['elastomer-test-SpongeBob-SquarePants'], hash[@name]['aliases'].keys
    end

    it 'accepts the full aliases actions hash' do
      @cluster.update_aliases :actions => [
        {:add => {:index => @name, :alias => 'elastomer-test-He-Man'}},
        {:add => {:index => @name, :alias => 'elastomer-test-Skeletor'}}
      ]

      hash = @cluster.get_aliases(:index => @name)
      assert_equal %w[elastomer-test-He-Man elastomer-test-Skeletor], hash[@name]['aliases'].keys.sort
    end
  end

end
