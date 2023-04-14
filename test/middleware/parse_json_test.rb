# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

describe ElastomerClient::Middleware::ParseJson do
  let(:middleware) { ElastomerClient::Middleware::ParseJson.new(lambda { |env| Faraday::Response.new(env) }) }
  let(:headers) { Hash.new }

  def process(body, content_type = nil)
    env = { body: body, response_headers: Faraday::Utils::Headers.new(headers) }
    env[:response_headers]["content-type"] = content_type if content_type
    middleware.call(env)
  end

  it "doesn't change nil body" do
    response = process(nil)

    assert_nil response.body
  end

  it "nullifies empty body" do
    response = process("")

    assert_nil response.body
  end

  it "nullifies blank body" do
    response = process(" ")

    assert_nil response.body
  end

  it "parses json body with empty type" do
    response = process('{"a":1}')

    assert_equal({"a" => 1}, response.body)
  end

  it "parses json body of correct type" do
    response = process('{"a":1}', "application/json; charset=utf-8")

    assert_equal({"a" => 1}, response.body)
  end

  it "ignores json body if incorrect type" do
    response = process('{"a":1}', "application/xml; charset=utf-8")

    assert_equal('{"a":1}', response.body)
  end

  it "chokes on invalid json" do
    assert_raises(Faraday::Error::ParsingError) { process "{!"      }
    assert_raises(Faraday::Error::ParsingError) { process "invalid" }

    # surprisingly these are all valid according to MultiJson
    #
    # assert_raises(Faraday::Error::ParsingError) { process '"a"'  }
    # assert_raises(Faraday::Error::ParsingError) { process 'true' }
    # assert_raises(Faraday::Error::ParsingError) { process 'null' }
    # assert_raises(Faraday::Error::ParsingError) { process '1'    }
  end
end
