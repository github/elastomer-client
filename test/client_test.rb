require File.expand_path('../test_helper', __FILE__)

describe Elastomer::Client do

  it 'uses the adapter specified at creation' do
    c = Elastomer::Client.new(:adapter => :test)
    assert_includes c.connection.builder.handlers, Faraday::Adapter::Test
  end

  it "use Faraday's default adapter if none is specified" do
    c = Elastomer::Client.new
    adapter = Faraday::Adapter.lookup_middleware(Faraday.default_adapter)
    assert_includes c.connection.builder.handlers, adapter
  end

  it 'uses the same connection for all requests' do
    c = $client.connection
    assert_same c, $client.connection
  end

  it 'raises an error for unknown HTTP request methods' do
    assert_raises(ArgumentError) { $client.request :foo, '/', {} }
  end

  it 'raises an error on 4XX responses with an `error` field' do
    begin
      $client.get '/non-existent-index/_search?q=*:*'
      assert false, 'exception was not raised when it should have been'
    rescue Elastomer::Client::Error => err
      assert_equal 404, err.status
      assert_equal 'IndexMissingException[[non-existent-index] missing]', err.message
    end
  end

  it 'handles path expansions' do
    uri = $client.expand_path '/{foo}/{bar}', :foo => '_cluster', :bar => 'health'
    assert_equal '/_cluster/health', uri

    uri = $client.expand_path '{/foo}{/baz}{/bar}', :foo => '_cluster', :bar => 'state'
    assert_equal '/_cluster/state', uri
  end

  it 'handles query parameters' do
    uri = $client.expand_path '/_cluster/health', :level => 'shards'
    assert_equal '/_cluster/health?level=shards', uri
  end

  it 'validates path expansions' do
    assert_raises(ArgumentError) {
      $client.expand_path '/{foo}/{bar}', :foo => '_cluster', :bar => nil
    }

    assert_raises(ArgumentError) {
      $client.expand_path '/{foo}/{bar}', :foo => '_cluster', :bar => ''
    }
  end

  describe 'when validating parameters' do
    it 'rejects nil values' do
      assert_raises(ArgumentError) { $client.validate_param nil }
    end

    it 'rejects empty strings' do
      assert_raises(ArgumentError) { $client.validate_param "" }
      assert_raises(ArgumentError) { $client.validate_param " " }
      assert_raises(ArgumentError) { $client.validate_param " \t \r \n " }
    end

    it 'rejects empty strings and nil values found in arrays' do
      assert_raises(ArgumentError) { $client.validate_param ['foo', nil, 'bar'] }
      assert_raises(ArgumentError) { $client.validate_param ['baz', " \t \r \n "] }
    end

    it 'strips whitespace from strings' do
      assert_equal 'foo', $client.validate_param("  foo  \t")
    end

    it 'joins array values into a string' do
      assert_equal 'foo,bar', $client.validate_param(%w[foo bar])
    end

    it 'flattens arrays' do
      assert_equal 'foo,bar,baz,buz', $client.validate_param(["  foo  \t", %w[bar baz buz]])
    end
  end
end
