require_relative "../test_helper"

describe "stubbed client tests" do
  before do
    @stubs  = Faraday::Adapter.lookup_middleware(:test)::Stubs.new
    @client = Elastomer::Client.new adapter: [:test, @stubs]
    @client.instance_variable_set(:@version, "5.6.4")
  end

  describe Elastomer::Client::Cluster do
    it "reroutes shards" do
      @stubs.post "/_cluster/reroute?dry_run=true" do |env|
        assert_match %r/^\{"commands":\[\{"move":\{[^\{\}]+\}\}\]\}$/, env[:body]
        [200, {"Content-Type" => "application/json"}, '{"acknowledged" : true}']
      end

      commands = { move: { index: "test", shard: 0, from_node: "node1", to_node: "node2" }}
      h = @client.cluster.reroute commands, dry_run: true
      assert_acknowledged h
    end
  end
end
