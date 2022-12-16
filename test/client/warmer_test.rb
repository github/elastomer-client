# typed: true
# frozen_string_literal: true

require_relative "../test_helper"

describe Elastomer::Client::Warmer do
  before do
    unless $client.version_support.supports_warmers?
      skip "warmers are not supported in ES #{$client.version}"
    end

    @name  = "elastomer-warmer-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create(
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: {
          tweet: {
            _source: { enabled: true }, _all: { enabled: false },
            properties: {
              message: $client.version_support.text(analyzer: "standard"),
              author: $client.version_support.keyword
            }
          }
        }
      )
      wait_for_index(@name)
    end
  end

  after do
    @index.delete if defined?(@index) && @index.exists?
  end

  it "creates warmers" do
    h = @index.warmer("test1").create(query: { match_all: {}})

    assert_acknowledged h
  end

  it "deletes warmers" do
    @index.warmer("test1").create(query: { match_all: {}})

    h = @index.warmer("test1").delete

    assert_acknowledged h
  end

  it "gets warmers" do
    body = { "query" => {"match_all" => {}}}
    @index.warmer("test1").create(body)

    h = @index.warmer("test1").get

    assert_equal body, h[@name]["warmers"]["test1"]["source"]
  end

  it "knows when warmers exist" do
    refute_predicate @index.warmer("test1"), :exists?
    refute_predicate @index.warmer("test1"), :exist?

    @index.warmer("test1").create(query: { match_all: {}})

    assert_predicate @index.warmer("test1"), :exists?
  end
end
