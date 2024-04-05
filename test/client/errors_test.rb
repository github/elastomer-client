# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Error do

  it "is instantiated with a simple message" do
    err = ElastomerClient::Client::Error.new "something went wrong"

    assert_equal "something went wrong", err.message
  end

  it "is instantiated from an HTTP response" do
    response = Faraday::Response.new(body: "UTF8Error invalid middle-byte")
    err = ElastomerClient::Client::Error.new(response)

    assert_equal "UTF8Error invalid middle-byte", err.message

    response = Faraday::Response.new(body: {"error" => "IndexMissingException"})
    err = ElastomerClient::Client::Error.new(response)

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
    response = Faraday::Response.new(body:)
    err = ElastomerClient::Client::Error.new(response)

    assert_equal body["error"].to_s, err.message
    assert_equal body["error"], err.error
  end

  it "is instantiated from another exception" do
    err = Faraday::ConnectionFailed.new "could not connect to host"
    err.set_backtrace %w[one two three four]

    err = ElastomerClient::Client::Error.new(err, "POST", "/index/doc")

    assert_equal "could not connect to host :: POST /index/doc", err.message
    assert_equal %w[one two three four], err.backtrace
  end

  it "is fatal by default" do
    assert ElastomerClient::Client::Error.fatal, "client errors are fatal by default"

    error = ElastomerClient::Client::Error.new "oops!"

    refute_predicate error, :retry?, "client errors are not retryable by default"
  end

  it "supports .fatal? alias" do
    assert_predicate ElastomerClient::Client::Error, :fatal?, "client errors support .fatal?"
  end

  it "has some fatal subclasses" do
    assert ElastomerClient::Client::ResourceNotFound.fatal, "Resource not found is fatal"
    assert ElastomerClient::Client::ParsingError.fatal, "Parsing error is fatal"
    assert ElastomerClient::Client::SSLError.fatal, "SSL error is fatal"
    assert ElastomerClient::Client::RequestError.fatal, "Request error is fatal"
    assert ElastomerClient::Client::DocumentAlreadyExistsError.fatal, "DocumentAlreadyExistsError error is fatal"
  end

  it "has some non-fatal subclasses" do
    refute ElastomerClient::Client::TimeoutError.fatal, "Timeouts are not fatal"
    refute ElastomerClient::Client::ConnectionFailed.fatal, "Connection failures are not fatal"
    refute ElastomerClient::Client::ServerError.fatal, "Server errors are not fatal"
    refute ElastomerClient::Client::RejectedExecutionError.fatal, "Rejected execution errors are not fatal"
  end

  it "wraps illegal argument exceptions" do
    begin
      $client.get("/_cluster/health?consistency=all")

      assert false, "IllegalArgument exception was not raised"
    rescue ElastomerClient::Client::IllegalArgument => err
      assert_match(/request \[\/_cluster\/health\] contains unrecognized parameter: \[consistency\]/, err.message)
    end
  end
end
