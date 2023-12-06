# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)
require "elastomer_client/core_ext/time"

describe "JSON conversions for Time" do
  before do
    @name  = "elastomer-time-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: { type: "keyword" },
            created_at: { type: "date" }
          }
        }, !$client.version_support.es_version_8_plus?)

      wait_for_index(@name)
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it "generates ISO8601 formatted time strings" do
    time = Time.utc(2013, 5, 3, 10, 1, 31)

    assert_equal '"2013-05-03T10:01:31.000Z"', MultiJson.encode(time)
  end

  it "indexes time fields" do
    time = Time.utc(2013, 5, 3, 10, 1, 31)
    h = @docs.index(document_wrapper("book", {title: "Book 1", created_at: time}))

    assert_created(h)

    doc = $client.version_support.es_version_8_plus? ? @docs.get(id: h["_id"]) : @docs.get(type: "book", id: h["_id"])

    assert_equal "2013-05-03T10:01:31.000Z", doc["_source"]["created_at"]
  end
end
