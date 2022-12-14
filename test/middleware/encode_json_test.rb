# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Middleware::EncodeJson do
  let(:middleware) { Elastomer::Middleware::EncodeJson.new(lambda { |env| env }) }

  def process(body, content_type: nil, method: :post)
    env = { body: body, request_headers: Faraday::Utils::Headers.new, method: method }
    env[:request_headers]["content-type"] = content_type if content_type
    middleware.call(env)
  end

  it "handles no body" do
    result = process(nil)
    assert_nil result[:body]
    assert_equal "application/json", result[:request_headers]["content-type"]

    result = process(nil, method: :get)
    assert_nil result[:body]
    assert_nil result[:request_headers]["content-type"]
  end

  it "handles empty body" do
    result = process("")
    assert_empty result[:body]
    assert_equal "application/json", result[:request_headers]["content-type"]

    result = process("", method: :get)
    assert_empty result[:body]
    assert_nil result[:request_headers]["content-type"]
  end

  it "handles string body" do
    result = process('{"a":1}')
    assert_equal '{"a":1}', result[:body]
    assert_equal "application/json", result[:request_headers]["content-type"]
  end

  it "handles object body" do
    result = process({a: 1})
    assert_equal '{"a":1}', result[:body]
    assert_equal "application/json", result[:request_headers]["content-type"]
  end

  it "handles empty object body" do
    result = process({})
    assert_equal "{}", result[:body]
    assert_equal "application/json", result[:request_headers]["content-type"]
  end

  it "handles object body with json type" do
    result = process({a: 1}, content_type: "application/json; charset=utf-8")
    assert_equal '{"a":1}', result[:body]
    assert_equal "application/json; charset=utf-8", result[:request_headers]["content-type"]
  end

  it "handles object body with incompatible type" do
    result = process({a: 1}, content_type: "application/xml; charset=utf-8")
    assert_equal({a: 1}, result[:body])
    assert_equal "application/xml; charset=utf-8", result[:request_headers]["content-type"]
  end
end
