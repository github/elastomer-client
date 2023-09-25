# frozen_string_literal: true

require_relative "../test_helper"
require "json"

describe ElastomerClient::Client::Bulk do

  before do
    @name  = "elastomer-bulk-test"
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
        })

      wait_for_index(@name)
    end
  end

  after do
    @index.delete if @index.exists?
  end

  it "performs bulk index actions" do
    body = [
      {index: document_wrapper("book", {_id: "1", _index: "elastomer-bulk-test"})}.to_json,
      '{"author":"Author 1", "title":"Book 1"}',
      {index: document_wrapper("book", {_id: "2", _index: "elastomer-bulk-test"})}.to_json,
      '{"author":"Author 2", "title":"Book 2"}',
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body

    assert_bulk_index(h["items"][0])
    assert_bulk_index(h["items"][1])

    @index.refresh

    h = @index.docs("book").get id: 1

    assert_equal "Author 1", h["_source"]["author"]

    h = @index.docs("book").get id: 2

    assert_equal "Author 2", h["_source"]["author"]


    body = [
      {index: document_wrapper("book", {_id: "3"})}.to_json,
      '{"author":"Author 3", "title":"Book 3"}',
      {delete: document_wrapper("book", {_id: "1"})}.to_json,
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body, index: @name

    assert_bulk_index h["items"].first, "expected to index a book"
    assert_bulk_delete h["items"].last, "expected to delete a book"

    @index.refresh

    h = @index.docs("book").get id: 1

    refute h["exists"], "was not successfully deleted"

    h = @index.docs("book").get id: 3

    assert_equal "Author 3", h["_source"]["author"]
  end

  it "supports a nice block syntax" do
    h = @index.bulk do |b|
      b.index({ author: "Author 1", title: "Book 1" }, { _id: 1, _type: "book" })
      b.index({ author: "Author 2", title: "Book 2" }, { _id: nil, _type: "book" })
    end
    items = h["items"]

    assert_kind_of Integer, h["took"]

    assert_equal 2, h["items"].length

    assert_bulk_index h["items"].first
    assert_bulk_index h["items"].last
    book_id = items.last["index"]["_id"]

    assert_match %r/^\S{20,22}$/, book_id

    @index.refresh

    h = @index.docs("book").get id: 1

    assert_equal "Author 1", h["_source"]["author"]

    h = @index.docs("book").get id: book_id

    assert_equal "Author 2", h["_source"]["author"]

    h = @index.bulk do |b|
      b.index({ author: "Author 3", title: "Book 3" }, _id: "", _type: "book")
      b.delete ({_id: book_id, _type: "book"})
    end
    items = h["items"]

    assert_equal 2, h["items"].length

    assert_bulk_index h["items"].first, "expected to create a book"
    assert_bulk_delete h["items"].last, "expected to delete a book"

    book_id2 = items.first["index"]["_id"]

    assert_match %r/^\S{20,22}$/, book_id2

    @index.refresh

    h = @index.docs("book").get id: book_id

    refute h["exists"], "was not successfully deleted"

    h = @index.docs("book").get id: book_id2

    assert_equal "Author 3", h["_source"]["author"]
  end

  it "allows documents to be JSON strings" do
    h = @index.bulk do |b|
      b.index  '{"author":"Author 1", "title":"Book 1"}', {_id: 1, _type: "book"}
      b.create '{"author":"Author 2", "title":"Book 2"}', {_id: 2, _type: "book"}
    end

    assert_kind_of Integer, h["took"]

    assert_bulk_index h["items"].first
    assert_bulk_create h["items"].last

    @index.refresh

    h = @index.docs("book").get id: 1

    assert_equal "Author 1", h["_source"]["author"]

    h = @index.docs("book").get id: 2

    assert_equal "Author 2", h["_source"]["author"]

    h = @index.bulk do |b|
      b.index '{"author":"Author 3", "title":"Book 3"}', {_id: 3, _type: "book"}
      b.delete ({_id: 1, _type: "book"})
    end

    assert_bulk_index h["items"].first, "expected to index a book"
    assert_bulk_delete h["items"].last, "expected to delete a book"

    @index.refresh

    h = @index.docs("book").get id: 1

    refute h["exists"], "was not successfully deleted"

    h = @index.docs("book").get id: 3

    assert_equal "Author 3", h["_source"]["author"]
  end

  it "executes a bulk API call when a request size is reached" do
    ary = []
    # since es7 does not include the mapping type in the document, it has less characters per request
    # add characters to the document to get 100 characters per request
    book_title = $client.version_support.es_version_8_plus? ? "A"*52 : "A"*34
    ary << @index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = { author: "Author 1", title: book_title}
        ary << b.index(document, { _id: num, _type: "book" })
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = { author: "Author 1", title: book_title }
        ary << b.index(document, { _id: num+2,  _type: "book" })
      }
      ary.compact!

      assert_equal 4, ary.length

      document = {author: "Author 1", title: book_title}
      ary << b.index(document, {_id: 10,  _type: "book"})
    end
    ary.compact!

    assert_equal 5, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_8_plus?
      assert_equal 10, h["hits"]["total"]["value"]
    else
      assert_equal 10, h["hits"]["total"]
    end
  end

  it "executes a bulk API call when an action count is reached" do
    ary = []
    ary << @index.bulk(action_count: 3) do |b|
      2.times { |num|
        document = {author: "Author 1", title: "This is book number #{num}"}
        ary << b.index(document, {_id: num,  _type: "book"})
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = {author: "Author 1", title: "This is book number #{num+2}"}
        ary << b.index(document, {_id: num+2, _type: "book"})
      }
      ary.compact!

      assert_equal 2, ary.length

      document = {author: "Author 1", title: "This is book number 10"}
      ary << b.index(document, {_id: 10,  _type: "book"})
    end
    ary.compact!

    assert_equal 4, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_8_plus?
      assert_equal 10, h["hits"]["total"]["value"]
    else
      assert_equal 10, h["hits"]["total"]
    end
  end

  it "rejects documents that exceed the maximum request size" do
    client = ElastomerClient::Client.new(**$client_params.merge(max_request_size: 300))
    index  = client.index(@name)

    ary = []
    book_title = $client.version_support.es_version_8_plus? ? "A"*52 : "A"*34
    ary << index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = {author: "Author 1", title: book_title}
        ary << b.index(document, document_wrapper("book", { _id: num }))
      }
      ary.compact!

      assert_equal 0, ary.length

      document = { author: "Author 1", message: "A"*290 }
      assert_raises(ElastomerClient::Client::RequestSizeError) { b.index(document, document_wrapper("book", { _id: 342 })) }
    end
    ary.compact!

    assert_equal 1, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    index.refresh
    h = index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_8_plus?
      assert_equal 2, h["hits"]["total"]["value"]
    else
      assert_equal 2, h["hits"]["total"]
    end
  end

  it "uses :id from parameters and supports symbol and string parameters" do
    response = @index.bulk do |b|
      document1 = { author: "Author 1", title: "Book 1" }
      b.index document1, { id: "foo", type: "book" }

      document2 = { author: "Author 2", title: "Book 2" }
      b.index document2, { "id" => "bar", "type" => "book" }
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    assert_equal "foo", items[0]["index"]["_id"]
    assert_equal "Book 1", @index.docs("book").get(id: "foo")["_source"]["title"]

    assert_equal "bar", items[1]["index"]["_id"]
    assert_equal "Book 2", @index.docs("book").get(id: "bar")["_source"]["title"]
  end

  it "empty symbol and string parameters don't set id" do
    response = @index.bulk do |b|
      document1 = { author: "Author 1", title: "Book 1" }
      b.index document1,  { id: "", type: "book" }

      document2 = { author: "Author 2", title: "Book 2" }
      b.index document2, { "id" => "", "type" => "book" }
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    # ES will generate ids for these documents
    id1 = items[0]["index"]["_id"]
    id2 = items[1]["index"]["_id"]

    assert_equal "Book 1", @index.docs("book").get(id: id1)["_source"]["title"]
    assert_equal "Book 2", @index.docs("book").get(id: id2)["_source"]["title"]
  end

  it "supports the routing parameter on index actions" do
    document = { title: "Book 1" }

    response = @index.bulk do |b|
      b.index document, { routing: "custom", _id: 1,  _type: "book" }
    end

    items = response["items"]

    assert_kind_of Integer, response["took"]
    assert_bulk_index(items[0])
    assert_equal "custom", @index.docs("book").get(id: 1)["_routing"]
  end

  it "supports the routing parameter within params in ES5 and ES8" do
    document = { title: "Book 1" }

    params = { _id: 1, _type: "book" }
    if $client.version_support.es_version_8_plus?
      params[:routing] = "custom"
    else
      params[:_routing] = "custom"
    end

    response = @index.bulk do |b|
      b.index document, params
    end

    items = response["items"]

    assert_kind_of Integer, response["took"]
    assert_bulk_index(items[0])
    assert_equal "custom", @index.docs("book").get(id: 1)["_routing"]
  end

  it "streams bulk responses" do
    ops = [
      [:index, { title: "Book 1" }, document_wrapper("book", { _id: 1, _index: @index.name })],
      [:index, { title: "Book 2" }, document_wrapper("book", { _id: 2, _index: @index.name })],
      [:index, { title: "Book 3" }, document_wrapper("book", { _id: 3, _index: @index.name })],
    ]
    responses = $client.bulk_stream_responses(ops, { action_count: 2 }).to_a

    assert_equal(2, responses.length)
    assert_bulk_index(responses[0]["items"][0])
    assert_bulk_index(responses[0]["items"][1])
    assert_bulk_index(responses[1]["items"][0])
  end

  it "streams bulk items" do
    ops = [
      [:index, { title: "Book 1" }, document_wrapper("book", { _id: 1, _index: @index.name })],
      [:index, { title: "Book 2" }, document_wrapper("book", { _id: 2, _index: @index.name })],
      [:index, { title: "Book 3" }, document_wrapper("book", { _id: 3, _index: @index.name })],
    ]
    items = []
    $client.bulk_stream_items(ops, { action_count: 2 }) { |item| items << item }

    assert_equal(3, items.length)
    assert_bulk_index(items[0])
    assert_bulk_index(items[1])
    assert_bulk_index(items[2])
  end
end
