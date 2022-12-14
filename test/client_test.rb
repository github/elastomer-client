# frozen_string_literal: true

require File.expand_path("../test_helper", __FILE__)
require "elastomer/notifications"

describe Elastomer::Client do

  it "uses the adapter specified at creation" do
    c = Elastomer::Client.new(adapter: :test)
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
      assert_match %r/index_not_found_exception/, err.message
    end
  end

  it "raises an error on rejected execution exceptions" do
    rejected_execution_response = {
      error: {
        root_cause: [{
          type: "es_rejected_execution_exception",
          reason: "rejected execution of org.elasticsearch.transport.TransportService$7@5a787cd5 on EsThreadPoolExecutor[bulk, queue capacity = 200, org.elasticsearch.common.util.concurrent.EsThreadPoolExecutor@1338862c[Running, pool size = 32, active threads = 32, queued tasks = 213, completed tasks = 193082975]]"
        }],
        type: "es_rejected_execution_exception",
        reason: "rejected execution of org.elasticsearch.transport.TransportService$7@5a787cd5 on EsThreadPoolExecutor[bulk, queue capacity = 200, org.elasticsearch.common.util.concurrent.EsThreadPoolExecutor@1338862c[Running, pool size = 32, active threads = 32, queued tasks = 213, completed tasks = 193082975]]"
      }
    }.to_json

    stub_request(:post, $client.url+"/_bulk").to_return({
      body: rejected_execution_response
    })

    begin
      $client.post "/_bulk"
      assert false, "exception was not raised when it should have been"
    rescue Elastomer::Client::RejectedExecutionError => err
      assert_match %r/es_rejected_execution_exception/, err.message
    end
  end

  it "wraps Faraday errors with our own exceptions" do
    error = Faraday::TimeoutError.new("it took too long")
    wrapped = $client.wrap_faraday_error(error, :get, "/_cat/indices")

    assert_instance_of Elastomer::Client::TimeoutError, wrapped
    assert_equal "it took too long :: GET /_cat/indices", wrapped.message
  end

  it "handles path expansions" do
    uri = $client.expand_path "/{foo}/{bar}", foo: "_cluster", bar: "health"
    assert_equal "/_cluster/health", uri

    uri = $client.expand_path "{/foo}{/baz}{/bar}", foo: "_cluster", bar: "state"
    assert_equal "/_cluster/state", uri
  end

  it "handles query parameters" do
    uri = $client.expand_path "/_cluster/health", level: "shards"
    assert_equal "/_cluster/health?level=shards", uri
  end

  it "validates path expansions" do
    assert_raises(ArgumentError) {
      $client.expand_path "/{foo}/{bar}", foo: "_cluster", bar: nil
    }

    assert_raises(ArgumentError) {
      $client.expand_path "/{foo}/{bar}", foo: "_cluster", bar: ""
    }
  end

  it "hides basic_auth and token_auth params from inspection" do
    client_params = $client_params.merge(basic_auth: {
      username: "my_user",
      password: "my_secret_password"
    }, token_auth: "my_secret_token")
    client = Elastomer::Client.new(**client_params)
    refute_match(/my_user/, client.inspect)
    refute_match(/my_secret_password/, client.inspect)
    refute_match(/my_secret_token/, client.inspect)
    assert_match(/@basic_auth=\[FILTERED\]/, client.inspect)
    assert_match(/@token_auth=\[FILTERED\]/, client.inspect)
  end

  describe "authorization" do
    it "can use basic authentication" do
      client_params = $client_params.merge(basic_auth: {
        username: "my_user",
        password: "my_secret_password"
      })
      client = Elastomer::Client.new(**client_params)

      connection = Faraday::Connection.new
      basic_auth_spy = Spy.on(connection, :basic_auth).and_return(nil)

      Faraday.stub(:new, $client_params[:url], connection) do
        client.ping
      end

      assert basic_auth_spy.has_been_called_with?("my_user", "my_secret_password")
    end

    it "ignores basic authentication if password is missing" do
      client_params = $client_params.merge(basic_auth: {
        username: "my_user"
      })
      client = Elastomer::Client.new(**client_params)

      connection = Faraday::Connection.new
      basic_auth_spy = Spy.on(connection, :basic_auth).and_return(nil)

      Faraday.stub(:new, $client_params[:url], connection) do
        client.ping
      end

      refute basic_auth_spy.has_been_called?
    end

    it "ignores basic authentication if username is missing" do
      client_params = $client_params.merge(basic_auth: {
        password: "my_secret_password"
      })
      client = Elastomer::Client.new(**client_params)

      connection = Faraday::Connection.new
      basic_auth_spy = Spy.on(connection, :basic_auth).and_return(nil)

      Faraday.stub(:new, $client_params[:url], connection) do
        client.ping
      end

      refute basic_auth_spy.has_been_called?
    end

    it "can use token authentication" do
      client_params = $client_params.merge(token_auth: "my_secret_token")
      client = Elastomer::Client.new(**client_params)

      connection = Faraday::Connection.new
      token_auth_spy = Spy.on(connection, :token_auth).and_return(nil)

      Faraday.stub(:new, $client_params[:url], connection) do
        client.ping
      end

      assert token_auth_spy.has_been_called_with?("my_secret_token")
    end

    it "prefers token authentication over basic" do
      client_params = $client_params.merge(basic_auth: {
        username: "my_user",
        password: "my_secret_password"
      }, token_auth: "my_secret_token")
      client = Elastomer::Client.new(**client_params)

      connection = Faraday::Connection.new
      basic_auth_spy = Spy.on(connection, :basic_auth).and_return(nil)
      token_auth_spy = Spy.on(connection, :token_auth).and_return(nil)

      Faraday.stub(:new, $client_params[:url], connection) do
        client.ping
      end

      refute basic_auth_spy.has_been_called?
      assert token_auth_spy.has_been_called_with?("my_secret_token")
    end
  end

  describe "when extracting and converting :body params" do
    it "deletes the :body from the params (or it gets the hose)" do
      params = { body: nil, q: "what what?" }
      body = $client.extract_body params

      assert_nil body
      assert_equal({q: "what what?"}, params)
    end

    it "leaves String values unchanged" do
      body = $client.extract_body body: '{"query":{"match_all":{}}}'
      assert_equal '{"query":{"match_all":{}}}', body

      body = $client.extract_body body: "not a JSON string, but who cares!"
      assert_equal "not a JSON string, but who cares!", body
    end

    it "joins Array values" do
      body = $client.extract_body body: %w[foo bar baz]
      assert_equal "foo\nbar\nbaz\n", body

      body = $client.extract_body body: [
        "the first entry",
        "the second entry",
        nil
      ]
      assert_equal "the first entry\nthe second entry\n", body
    end

    it "converts values to JSON" do
      body = $client.extract_body body: true
      assert_equal "true", body

      body = $client.extract_body body: {query: {match_all: {}}}
      assert_equal '{"query":{"match_all":{}}}', body
    end

    it "returns frozen strings" do
      body = $client.extract_body body: '{"query":{"match_all":{}}}'
      assert_equal '{"query":{"match_all":{}}}', body
      assert body.frozen?, "the body string should be frozen"

      body = $client.extract_body body: %w[foo bar baz]
      assert_equal "foo\nbar\nbaz\n", body
      assert body.frozen?, "Array body strings should be frozen"

      body = $client.extract_body body: {query: {match_all: {}}}
      assert_equal '{"query":{"match_all":{}}}', body
      assert body.frozen?, "JSON encoded body strings should be frozen"
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
      assert_match(/[\d\.]+/, $client.version)
    end

    it "does not make an HTTP request for version if it is provided at create time" do
      request = stub_request(:get, "#{$client.url}/")

      client = Elastomer::Client.new(**$client_params.merge(es_version: "5.6.6"))
      assert_equal "5.6.6", client.version

      assert_not_requested request
    end

    it "gets semantic version" do
      version_string = $client.version
      assert_equal Semantic::Version.new(version_string), $client.semantic_version
    end
  end

  describe "duplicating a client connection" do
    it "is configured the same" do
      client = $client.dup

      refute_same $client, client

      assert_equal $client.host, client.host
      assert_equal $client.port, client.port
      assert_equal $client.url, client.url
      assert_equal $client.read_timeout, client.read_timeout
      assert_equal $client.open_timeout, client.open_timeout
      assert_equal $client.max_request_size, client.max_request_size
    end

    it "has a unique connection" do
      client = $client.dup

      refute_same $client.connection, client.connection
    end
  end

  describe "automatic retry of requests" do
    before do
      @events = []
      @subscriber = ActiveSupport::Notifications.subscribe do |*args|
        @events << ActiveSupport::Notifications::Event.new(*args)
      end
    end

    after do
      @events.clear
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end

    it "defaults to no retries" do
      stub_request(:get, $client.url+"/_cat/indices").
        to_timeout.then.
        to_return({
          headers: {"Content-Type" => "text/plain; charset=UTF-8"},
          body: "green open test-index 1 0 0 0 159b 159b"
        })

      assert_raises(Elastomer::Client::ConnectionFailed) {
        $client.get("/_cat/indices")
      }
    end

    it "retries up to `max_retries` times" do
      stub_request(:get, $client.url+"/test-index/_settings").
        to_timeout.then.
        to_timeout.then.
        to_return({body: %q/{"acknowledged": true}/})

      response = $client.index("test-index").settings(max_retries: 2)

      assert_equal 2, @events.first.payload[:retries]
      assert_equal({"acknowledged" => true}, response)
    end

    it "does not retry on PUT requests" do
      stub_request(:put, $client.url+"/test-index").
        to_timeout.then.
        to_return({body: %q/{"acknowledged": true}/})

      assert_raises(Elastomer::Client::ConnectionFailed) {
        $client.index("test-index").create({}, max_retries: 1)
      }
    end

    it "does not retry on POST requests" do
      stub_request(:post, $client.url+"/test-index/_flush").
        to_timeout.then.
        to_return({body: %q/{"acknowledged": true}/})

      assert_raises(Elastomer::Client::ConnectionFailed) {
        $client.index("test-index").flush(max_retries: 1)
      }
    end

    it "does not retry on DELETE requests" do
      stub_request(:delete, $client.url+"/test-index").
        to_timeout.then.
        to_return({body: %q/{"acknowledged": true}/})

      assert_raises(Elastomer::Client::ConnectionFailed) {
        $client.index("test-index").delete(max_retries: 1)
      }
    end
  end
end
