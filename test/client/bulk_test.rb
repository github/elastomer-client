# frozen_string_literal: true

require_relative "../test_helper"
require "json"

describe Elastomer::Client::Bulk do

  before do
    @name  = "elastomer-bulk-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: $client.version_support.text(analyzer: "standard"),
            author: $client.version_support.keyword
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
      {index: maybe_type("book", {_id:"1", _index:"elastomer-bulk-test"})}.to_json,
      '{"author":"One", "title":"Book 1"}',
      {index: maybe_type("book", {_id:"2", _index:"elastomer-bulk-test"})}.to_json,
      '{"author":"Two", "title":"Book 2"}',
      nil
    ]
    body = body.join "\n"
    h = $client.bulk body

    assert_bulk_index(h["items"][0])
    assert_bulk_index(h["items"][1])

    @index.refresh

    h = @index.docs("book").get id: 1

    assert_equal "One", h["_source"]["author"]

    h = @index.docs("book").get :id: 2

    assert_equal "Two", h["_source"]["author"]


    body = [
      {index: maybe_type("book", {_id:"3"})}.to_json,
      '{"author":"Three", "title":"Book 3"}',
      {delete: maybe_type("book", {_id: "1"})}.to_json,
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

    assert_equal "Three", h["_source"]["author"]
  end

  it "supports a nice block syntax" do
    h = @index.bulk do |b|
      b.index _id: 1,   _type: "tweet", author: "pea53", message: "just a test tweet"
      b.index _id: nil, _type: "book", author: "John Scalzi", title: "Old Mans War"
    end
    items = h["items"]

    assert_kind_of Integer, h["took"]

    assert_equal 2, h["items"].length

    if bulk_index_returns_create_for_new_documents?
      assert_bulk_index h["items"].first
      assert_bulk_create h["items"].last
      book_id = items.last["create"]["_id"]
    else
      assert_bulk_index h["items"].first
      assert_bulk_index h["items"].last
      book_id = items.last["index"]["_id"]
    end

    assert_match %r/^\S{20,22}$/, book_id

    @index.refresh

    h = @index.docs("tweet").get id: 1

    assert_equal "pea53", h["_source"]["author"]

    h = @index.docs("book").get id: book_id

    assert_equal "John Scalzi", h["_source"]["author"]


    h = @index.bulk do |b|
      b.index  _id: "", _type: "book", author: "Tolkien", title: "The Silmarillion"
      b.delete _id: book_id, _type: "book"
    end
    items = h["items"]

    assert_equal 2, h["items"].length

    if bulk_index_returns_create_for_new_documents?
      assert_bulk_create h["items"].first, "expected to create a book"
      assert_bulk_delete h["items"].last, "expected to delete a book"

      book_id2 = items.first["create"]["_id"]
    else
      assert_bulk_index h["items"].first, "expected to create a book"
      assert_bulk_delete h["items"].last, "expected to delete a book"

      book_id2 = items.first["index"]["_id"]
    end

    assert_match %r/^\S{20,22}$/, book_id2

    @index.refresh

    h = @index.docs("book").get id: book_id

    refute h["exists"], "was not successfully deleted"

    h = @index.docs("book").get id: book_id2

    assert_equal "Tolkien", h["_source"]["author"]
  end

  it "allows documents to be JSON strings" do
    h = @index.bulk do |b|
      b.index  '{"author":"pea53", "message":"just a test tweet"}', _id: 1, _type: "tweet"
      b.create '{"author":"John Scalzi", "title":"Old Mans War"}',  _id: 1, _type: "book"
    end

    assert_kind_of Integer, h["took"]

    assert_bulk_index h["items"].first
    assert_bulk_create h["items"].last

    @index.refresh

    h = @index.docs("tweet").get id: 1

    assert_equal "pea53", h["_source"]["author"]

    h = @index.docs("book").get id: 1

    assert_equal "John Scalzi", h["_source"]["author"]

    h = @index.bulk do |b|
      b.index '{"author":"Tolkien", "title":"The Silmarillion"}', _id: 2, _type: "book"
      b.delete _id: 1, _type: "book"
    end

    assert_bulk_index h["items"].first, "expected to index a book"
    assert_bulk_delete h["items"].last, "expected to delete a book"

    @index.refresh

    h = @index.docs("book").get id: 1

    refute h["exists"], "was not successfully deleted"

    h = @index.docs("book").get id: 2

    assert_equal "Tolkien", h["_source"]["author"]
  end

  it "executes a bulk API call when a request size is reached" do
    ary = []
    ary << @index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = {_id: num, _type: "tweet", author: "pea53", message: "tweet #{num} is a 100 character request"}
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = {_id: num+2, _type: "tweet", author: "pea53", message: "tweet #{num+2} is a 100 character request"}
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 4, ary.length

      document = {_id: 10, _type: "tweet", author: "pea53", message: "tweet 10 is a 102 character request"}
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 5, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    assert_equal 10, h["hits"]["total"]
  end

  it "executes a bulk API call when an action count is reached" do
    ary = []
    ary << @index.bulk(action_count: 3) do |b|
      2.times { |num|
        document = {_id: num, _type: "tweet", author: "pea53", message: "this is tweet number #{num}"}
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = {_id: num+2, _type: "tweet", author: "pea53", message: "this is tweet number #{num+2}"}
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 2, ary.length

      document = {_id: 10, _type: "tweet", author: "pea53", message: "this is tweet number 10"}
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 4, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    assert_equal 10, h["hits"]["total"]
  end

  it "rejects documents that excceed the maximum request size" do
    client = Elastomer::Client.new(**$client_params.merge(max_request_size: 300))
    index  = client.index(@name)

    ary = []
    ary << index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = {_id: num, _type: "tweet", author: "pea53", message: "tweet #{num} is a 100 character request"}
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      document = {_id: 342, _type: "tweet", author: "pea53", message: "a"*290}
      assert_raises(Elastomer::Client::RequestSizeError) { b.index(document) }
    end
    ary.compact!

    assert_equal 1, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    index.refresh
    h = index.docs.search q: "*:*", size: 0

    assert_equal 2, h["hits"]["total"]
  end

  it "uses :id from parameters" do
    response = @index.bulk do |b|
      document = { _type: "tweet", author: "pea53", message: "just a test tweet" }
      params = { id: "foo" }

      b.index document, params
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    assert_equal "foo", items[0]["index"]["_id"]
  end

  it "supports symbol and string parameters" do
    response = @index.bulk do |b|
      doc1 = { author: "pea53", message: "a tweet about foo" }
      b.index doc1, { id: "foo", type: "tweet" }

      doc2 = { author: "pea53", message: "a tweet about bar" }
      b.index doc2, { "id" => "bar", "type" => "tweet" }
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])
    assert_bulk_index(items[1])

    assert_equal "a tweet about foo", @index.docs("tweet").get(id: "foo")["_source"]["message"]
    assert_equal "a tweet about bar", @index.docs("tweet").get(id: "bar")["_source"]["message"]
  end

  it "doesn't override parameters from the document" do
    document = { _id: 1, _type: "tweet", author: "pea53", message: "just a test tweet" }
    params = { id: 2 }

    response = @index.bulk do |b|
      b.index document, params
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    refute_found @index.docs("tweet").get(id: 1)
    assert_equal "just a test tweet", @index.docs("tweet").get(id: 2)["_source"]["message"]
  end

  it "doesn't upgrade non-prefixed keys to parameters" do
    document = { id: 1, type: "book", version: 5, author: "pea53", message: "just a test tweet" }
    params = { id: 2, type: "tweet" }

    response = @index.bulk do |b|
      b.index document, params
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    assert_equal "2", items[0]["index"]["_id"]
    assert_equal "tweet", items[0]["index"]["_type"]
    assert_equal 1, items[0]["index"]["_version"]
  end

  it "streams bulk responses" do
    ops = [
      [:index, { message: "tweet 1" }, { _id: 1, _type: "book", _index: @index.name }],
      [:index, { message: "tweet 2" }, { _id: 2, _type: "book", _index: @index.name }],
      [:index, { message: "tweet 3" }, { _id: 3, _type: "book", _index: @index.name }]
    ]
    responses = $client.bulk_stream_responses(ops, { action_count: 2 }).to_a

    assert_equal(2, responses.length)
    assert_bulk_index(responses[0]["items"][0])
    assert_bulk_index(responses[0]["items"][1])
    assert_bulk_index(responses[1]["items"][0])
  end

  it "streams bulk items" do
    ops = [
      [:index, { message: "tweet 1" }, { _id: 1, _type: "book", _index: @index.name }],
      [:index, { message: "tweet 2" }, { _id: 2, _type: "book", _index: @index.name }],
      [:index, { message: "tweet 3" }, { _id: 3, _type: "book", _index: @index.name }]
    ]
    items = []
    $client.bulk_stream_items(ops, { action_count: 2 }) { |item| items << item }

    assert_equal(3, items.length)
    assert_bulk_index(items[0])
    assert_bulk_index(items[1])
    assert_bulk_index(items[2])
  end
end
