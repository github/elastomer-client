require File.expand_path('../test_helper', __FILE__)

describe Elastomer::Client do

  it 'uses the same connection for all requests' do
    c = $client.connection
    assert_same c, $client.connection
  end

  it 'raises an error for unknown HTTP request methods' do
    assert_raises(ArgumentError) { $client.request :foo, '/', {} }
  end

end
