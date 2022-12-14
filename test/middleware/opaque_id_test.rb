require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Middleware::OpaqueId do

  before do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/_cluster/health") { |env|
        [200,

          { "X-Opaque-Id"    => env[:request_headers]["X-Opaque-Id"],
            "Content-Type"   => "application/json; charset=UTF-8",
            "Content-Length" => "49" },

          %q[{"cluster_name":"elasticsearch","status":"green"}]
]
      }

      stub.get("/_cluster/state") { |env|
        [200, {"X-Opaque-Id" => "00000000-0000-0000-0000-000000000000"}, %q[{"foo":"bar"}]]
      }
    end

    opts = $client_params.merge \
        opaque_id: true,
        adapter: [:test, stubs]

    @client = Elastomer::Client.new(**opts)
    @client.instance_variable_set(:@version, "5.6.4")
  end

  it 'generates an "X-Opaque-Id" header' do
    health = @client.cluster.health
    assert_equal({"cluster_name" => "elasticsearch", "status" => "green"}, health)
  end

  it "raises an exception on conflicting headers" do
    assert_raises(Elastomer::Client::OpaqueIdError) { @client.cluster.state }
  end

  it "generates a UUID per call" do
    opaque_id = Elastomer::Middleware::OpaqueId.new

    uuid1 = opaque_id.generate_uuid
    uuid2 = opaque_id.generate_uuid

    assert uuid1 != uuid2, "UUIDs should be unique"
  end

  it "generates a UUID per thread" do
    opaque_id = Elastomer::Middleware::OpaqueId.new
    uuids = []
    threads = []

    3.times do
      threads << Thread.new { uuids << opaque_id.generate_uuid }
    end
    threads.each { |t| t.join }

    assert_equal 3, uuids.length, "expecting 3 UUIDs to be generated"

    # each UUID has 16 random characters as the base ID
    uuids.each { |uuid| assert_match(%r/\A[a-zA-Z0-9_-]{16}0{8}\z/, uuid) }

    bases = uuids.map { |uuid| uuid[0, 16] }
    assert_equal 3, bases.uniq.length, "each thread did not get a unique base ID"
  end
end
