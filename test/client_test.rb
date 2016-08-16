require File.expand_path("../test_helper", __FILE__)

describe Elastomer::Client do

  it "uses the adapter specified at creation" do
    c = Elastomer::Client.new(:adapter => :test)
    assert_includes c.connection.builder.handlers, Faraday::Adapter::Test
  end

  it "use Faraday's default adapter if none is specified" do
    c = Elastomer::Client.new
    adapter = Faraday::Adapter.lookup_middleware(Faraday.default_adapter)
    assert_includes c.connection.builder.handlers, adapter
  end

  it "uses the same connection for all requests" do
    c = $client.connection
    assert_same c, $client.connection
  end

  it "raises an error for unknown HTTP request methods" do
    assert_raises(ArgumentError) { $client.request :foo, "/", {} }
  end

  it "raises an error on 4XX responses with an `error` field" do
    begin
      $client.get "/non-existent-index/_search?q=*:*"
      assert false, "exception was not raised when it should have been"
    rescue Elastomer::Client::Error => err
      assert_equal 404, err.status
      if es_version_1_x?
        assert_equal "IndexMissingException[[non-existent-index] missing]", err.message
      elsif es_version_2_x?
        assert_match %r/index_not_found_exception/, err.message
      else
        fail "Elasticserch #{$client.version} is not supported"
      end
    end
  end

  it "handles path expansions" do
    uri = $client.expand_path "/{foo}/{bar}", :foo => "_cluster", :bar => "health"
    assert_equal "/_cluster/health", uri

    uri = $client.expand_path "{/foo}{/baz}{/bar}", :foo => "_cluster", :bar => "state"
    assert_equal "/_cluster/state", uri
  end

  it "handles query parameters" do
    uri = $client.expand_path "/_cluster/health", :level => "shards"
    assert_equal "/_cluster/health?level=shards", uri
  end

  it "validates path expansions" do
    assert_raises(ArgumentError) {
      $client.expand_path "/{foo}/{bar}", :foo => "_cluster", :bar => nil
    }

    assert_raises(ArgumentError) {
      $client.expand_path "/{foo}/{bar}", :foo => "_cluster", :bar => ""
    }
  end

  describe "when extracting and converting :body params" do
    it "deletes the :body from the params (or it gets the hose)" do
      params = { :body => nil, :q => "what what?" }
      body = $client.extract_body params

      assert_nil body
      assert_equal({:q => "what what?"}, params)
    end

    it "leaves String values unchanged" do
      body = $client.extract_body :body => '{"query":{"match_all":{}}}'
      assert_equal '{"query":{"match_all":{}}}', body

      body = $client.extract_body :body => "not a JSON string, but who cares!"
      assert_equal "not a JSON string, but who cares!", body
    end

    it "joins Array values" do
      body = $client.extract_body :body => %w[foo bar baz]
      assert_equal "foo\nbar\nbaz\n", body

      body = $client.extract_body :body => [
        "the first entry",
        "the second entry",
        nil
      ]
      assert_equal "the first entry\nthe second entry\n", body
    end

    it "converts values to JSON" do
      body = $client.extract_body :body => true
      assert_equal "true", body

      body = $client.extract_body :body => {:query => {:match_all => {}}}
      assert_equal '{"query":{"match_all":{}}}', body
    end
  end

  describe "when validating parameters" do
    it "rejects nil values" do
      assert_raises(ArgumentError) { $client.assert_param_presence nil }
    end

    it "rejects empty strings" do
      assert_raises(ArgumentError) { $client.assert_param_presence "" }
      assert_raises(ArgumentError) { $client.assert_param_presence " " }
      assert_raises(ArgumentError) { $client.assert_param_presence " \t \r \n " }
    end

    it "rejects empty strings and nil values found in arrays" do
      assert_raises(ArgumentError) { $client.assert_param_presence ["foo", nil, "bar"] }
      assert_raises(ArgumentError) { $client.assert_param_presence ["baz", " \t \r \n "] }
    end

    it "strips whitespace from strings" do
      assert_equal "foo", $client.assert_param_presence("  foo  \t")
    end

    it "joins array values into a string" do
      assert_equal "foo,bar", $client.assert_param_presence(%w[foo bar])
    end

    it "flattens arrays" do
      assert_equal "foo,bar,baz,buz", $client.assert_param_presence(["  foo  \t", %w[bar baz buz]])
    end

    it "allows strings" do
      assert_equal "foo", $client.assert_param_presence("foo")
    end

    it "converts numbers and symbols to strings" do
      assert_equal "foo", $client.assert_param_presence(:foo)
      assert_equal "9", $client.assert_param_presence(9)
    end
  end

  describe "top level actions" do
    it "pings the cluster" do
      assert_equal true, $client.ping
      assert_equal true, $client.available?
    end

    it "gets cluster info" do
      h = $client.info
      assert h.key?("name"), "expected cluster name to be returned"
      assert h.key?("version"), "expected cluster version information to be returned"
      assert h["version"].key?("number"), "expected cluster version number to be returned"
    end

    it "gets cluster version" do
      assert_match /[\d\.]+/, $client.version
    end

    it "gets semantic version" do
      version_string = $client.version
      assert_equal Semantic::Version.new(version_string), $client.semantic_version
    end
  end
end
