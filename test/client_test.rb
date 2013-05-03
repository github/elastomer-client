require File.expand_path('../test_helper', __FILE__)

describe Elastomer::Client do

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
    rescue Elastomer::Client::IndexMissingException => err
      assert_equal 404, err.status
      assert_equal '[non-existent-index] missing', err.message
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
end
