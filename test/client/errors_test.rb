require File.expand_path("../../test_helper", __FILE__)

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
    assert_equal "IndexMissingException", err.error

    body = {
      "error" => {
        "index"         => "non-existent-index",
        "reason"        => "no such index",
        "resource.id"   => "non-existent-index",
        "resource.type" => "index_or_alias",
        "root_cause"=> [{
          "index"         => "non-existent-index",
          "reason"        => "no such index",
          "resource.id"   => "non-existent-index",
          "resource.type" => "index_or_alias",
          "type"          => "index_not_found_exception"
        }],
       "type" => "index_not_found_exception"
      },
     "status" => 404
    }
    response = Faraday::Response.new(:body => body)
    err = Elastomer::Client::Error.new(response)
    assert_equal body["error"].to_s, err.message
    assert_equal body["error"], err.error
  end

  it "is instantiated from another exception" do
    err = Faraday::Error::ConnectionFailed.new "could not connect to host"
    err.set_backtrace %w[one two three four]

    err = Elastomer::Client::Error.new(err, "POST", "/index/doc")
    assert_equal "could not connect to host :: POST /index/doc", err.message
    assert_equal %w[one two three four], err.backtrace
  end

  it "is fatal by default" do
    assert Elastomer::Client::Error.fatal, "client errors are fatal by default"

    error = Elastomer::Client::Error.new "oops!"
    assert !error.retry?, "client errors are not retryable by default"
  end

  it "supports .fatal? alias" do
    assert Elastomer::Client::Error.fatal?, "client errors support .fatal?"
  end

  it "has some fatal subclasses" do
    assert Elastomer::Client::ResourceNotFound.fatal, "Resource not found is fatal"
    assert Elastomer::Client::ParsingError.fatal, "Parsing error is fatal"
    assert Elastomer::Client::SSLError.fatal, "SSL error is fatal"
    assert Elastomer::Client::RequestError.fatal, "Request error is fatal"
  end

  it "has some non-fatal subclasses" do
    assert !Elastomer::Client::TimeoutError.fatal, "Timeouts are not fatal"
    assert !Elastomer::Client::ConnectionFailed.fatal, "Connection failures are not fatal"
    assert !Elastomer::Client::ServerError.fatal, "Server errors are not fatal"
  end
end
