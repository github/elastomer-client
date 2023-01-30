# frozen_string_literal: true

require_relative "../test_helper"

describe Elastomer::Client::Scroller do

  before do
    @name  = "elastomer-scroller-test"
    @index = $client.index(@name)
    @type =  $client.version_support.es_version_7_plus? ? "_doc" : "book"

    unless @index.exists?
      @index.create \
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: { type: "text", analyzer: "standard" },
            author: { type: "keyword" },
            sorter: { type: "integer" }
          }
        }, true)

      wait_for_index(@name)
      populate!
    end
  end

  after do
    @index.delete if @index.exists?
  end

  it "scans over all documents in an index" do
    scan = @index.scan '{"query":{"match_all":{}}}', size: 10

    count = 0
    scan.each_document { |h| count += 1 }

    assert_equal 25, count
  end

  it "limits results by query" do
    scan = @index.scan query: { bool: { should: [
      {match: {title: "17"}}
    ]}}

    count = 0
    scan.each_document { |h| count += 1 }

    assert_equal 1, count
  end

  it "scrolls and sorts over all documents" do
    scroll = @index.scroll({
      query: {match_all: {}},
      sort: {sorter: {order: :asc}}
    }, type: @type)

    books = []
    scroll.each_document { |h| books << h["_id"].to_i }

    expected = (0...25).to_a.reverse

    assert_equal expected, books
  end

  it "propagates URL query strings" do
    scan = @index.scan(nil, { q: "title:1 || title:17" })

    count = 0
    scan.each_document { |h| count += 1 }

    assert_equal 2, count
  end

  it "clears one or more scroll IDs" do
    h = $client.start_scroll \
      body: {query: {match_all: {}}},
      index: @index.name,
      type: @type,
      scroll: "1m",
      size: 10

    refute_nil h["_scroll_id"], "response is missing a scroll ID"

    response = $client.clear_scroll(h["_scroll_id"])

    assert response["succeeded"]
    assert_equal 1, response["num_freed"]
  end

  it "raises an exception on existing sort in query" do
    assert_raises(ArgumentError) { @index.scan sort: [:_doc] , query: {} }
  end

  def populate!
    h = @index.bulk do |b|
      25.times { |num|
        if $client.version_support.es_version_7_plus?
          b.index %Q({"author":"Pratchett","title":"DiscWorld Book #{num}","sorter":#{25-num}}), _id: num
        else
          b.index %Q({"author":"Pratchett","title":"DiscWorld Book #{num}","sorter":#{25-num}}), _id: num, _type: "book"
        end
      }
    end

    h["items"].each { |item| assert_bulk_index(item) }

    @index.refresh
  end
end
