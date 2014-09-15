require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Error do

  it "is instantiated with a simple message" do
    err = Elastomer::Client::Error.new "something went wrong"
    assert_equal "something went wrong", err.message
  end

  it "is instantiated from an HTTP response" do
    response = Faraday::Response.new(:body => "UTF8Error invalid middle-byte")
    err = Elastomer::Client::Error.new(response)
    assert_equal "UTF8Error invalid middle-byte", err.message

    response = Faraday::Response.new(:body => {"error" => "IndexMissingException"})
    err = Elastomer::Client::Error.new(response)
    assert_equal "IndexMissingException", err.message
  end

  it "is instantiated from another exception" do
    err = Faraday::Error::ConnectionFailed.new "could not connect to host"
    err.set_backtrace %w[one two three four]

    err = Elastomer::Client::Error.new(err, "POST", "/index/doc")
    assert_equal "could not connect to host: POST /index/doc", err.message
    assert_equal %w[one two three four], err.backtrace
  end
end
