# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::MultiSearch do

  before do
    @name  = "elastomer-msearch-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: { type: "text", analyzer: "standard" },
            author: { type: "keyword" }
          }
        }, !$client.version_support.es_version_7_plus?)
      wait_for_index(@name)
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it "performs multisearches" do
    populate!

    body = [
      '{"index" : "elastomer-msearch-test"}',
      '{"query" : {"match_all" : {}}}',
      '{"index" : "elastomer-msearch-test"}',
      '{"query" : {"match": {"author" : "Author 2"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.multi_search body
    response1, response2 = h["responses"]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response1["hits"]["total"]["value"]
      assert_equal 1, response2["hits"]["total"]["value"]
    else
      assert_equal 2, response1["hits"]["total"]
      assert_equal 1, response2["hits"]["total"]
    end

    assert_equal "2", response2["hits"]["hits"][0]["_id"]

    body = [
      "{}",
      '{"query" : {"match": {"author" : "Author 2"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.multi_search body, index: @name
    response1 = h["responses"].first

    if $client.version_support.es_version_7_plus?
      assert_equal 1, response1["hits"]["total"]["value"]
    else
      assert_equal 1, response1["hits"]["total"]
    end

    assert_equal "2", response1["hits"]["hits"][0]["_id"]
  end

  it "performs multisearches with .msearch" do
    populate!

    body = [
      '{"index" : "elastomer-msearch-test"}',
      '{"query" : {"match_all" : {}}}',
      '{"index" : "elastomer-msearch-test"}',
      '{"query" : {"match": {"author" : "Author 2"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.msearch body
    response1, response2 = h["responses"]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response1["hits"]["total"]["value"]
      assert_equal 1, response2["hits"]["total"]["value"]
    else
      assert_equal 2, response1["hits"]["total"]
      assert_equal 1, response2["hits"]["total"]
    end

    assert_equal "2", response2["hits"]["hits"][0]["_id"]

    body = [
      "{}",
      '{"query" : {"match": {"author" : "Author 2"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.msearch body, index: @name
    response1 = h["responses"].first

    if $client.version_support.es_version_7_plus?
      assert_equal 1, response1["hits"]["total"]["value"]
    else
      assert_equal 1, response1["hits"]["total"]
    end

    assert_equal "2", response1["hits"]["hits"][0]["_id"]
  end

  it "supports a nice block syntax" do
    populate!

    h = $client.multi_search do |m|
      m.search({query: { match_all: {}}}, index: @name)
      m.search({query: { match: { "title" => "author" }}}, index: @name)
    end

    response1, response2 = h["responses"]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response1["hits"]["total"]["value"]
      assert_equal 2, response2["hits"]["total"]["value"]
    else
      assert_equal 2, response1["hits"]["total"]
      assert_equal 2, response2["hits"]["total"]
    end

    h = @index.multi_search do |m|
      m.search({query: { match_all: {}}})
      m.search({query: { match: { "title" => "author" }}})
    end

    response1, response2 = h["responses"]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response1["hits"]["total"]["value"]
      assert_equal 2, response2["hits"]["total"]["value"]
    else
      assert_equal 2, response1["hits"]["total"]
      assert_equal 2, response2["hits"]["total"]
    end

    type = $client.version_support.es_version_7_plus? ? "" : "book"
    h = @index.docs(type).multi_search do |m|
      m.search({query: { match_all: {}}})
      m.search({query: { match: { "title" => "2" }}})
    end

    response1, response2 = h["responses"]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response1["hits"]["total"]["value"]
      assert_equal 1, response2["hits"]["total"]["value"]
    else
      assert_equal 2, response1["hits"]["total"]
      assert_equal 1, response2["hits"]["total"]
    end
  end

  it "performs suggestion queries using the search endpoint" do
    populate!

    h = @index.multi_search do |m|
      m.search({
        query: {
          match: {
            title: "by author"
          }
        },
        suggest: {
          suggestion1: {
            text: "by author",
            term: {
              field: "author"
            }
          }
        }
      })
    end

    response = h["responses"][0]

    if $client.version_support.es_version_7_plus?
      assert_equal 2, response["hits"]["total"]["value"]
    else
      assert_equal 2, response["hits"]["total"]
    end

    refute_nil response["suggest"], "expected suggester text to be returned"
  end

  def populate!
    @docs.index \
      document_wrapper("book", {
        _id: 1,
        title: "Book 1 by author 1",
        author: "Author 1"
      })

    @docs.index \
      document_wrapper("book", {
        _id: 2,
        title: "Book 2 by author 2",
        author: "Author 2"
      })

    @index.refresh
  end
  # rubocop:enable Metrics/MethodLength
end
