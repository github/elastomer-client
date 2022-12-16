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
      b.index document_wrapper("book", {_id: 1, author: "Author 1", title: "Book 1"})
      b.index document_wrapper("book", {_id: nil, author: "Author 2", title: "Book 2"})
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

    h = @index.docs("book").get id: 1

    assert_equal "Author 1", h["_source"]["author"]

    h = @index.docs("book").get id: book_id

    assert_equal "Author 2", h["_source"]["author"]

    h = @index.bulk do |b|
      b.index  document_wrapper("book", {_id: "", author: "Author 3", title: "Book 3"})
      b.delete document_wrapper("book", {_id: book_id})
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

    assert_equal "Author 3", h["_source"]["author"]
  end

  it "allows documents to be JSON strings" do
    h = @index.bulk do |b|
      b.index  '{"author":"Author 1", "title":"Book 1"}', document_wrapper("book", {_id: 1})
      b.create '{"author":"Author 2", "title":"Book 2"}', document_wrapper("book", {_id: 2})
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
      b.index '{"author":"Author 3", "title":"Book 3"}', document_wrapper("book", {_id: 3})
      b.delete document_wrapper("book", {_id: 1})
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
    book_title = $client.version_support.es_version_7_plus? ? "A"*52 : "A"*34
    ary << @index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = document_wrapper("book", {_id: num, author: "Author 1", title: book_title})
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = document_wrapper("book", {_id: num+2, author: "Author 1", title: book_title})
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 4, ary.length

      document = document_wrapper("book", {_id: 10, author: "Author 1", title: book_title})
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 5, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_7_plus?
      assert_equal 10, h["hits"]["total"]["value"]
    else
      assert_equal 10, h["hits"]["total"]
    end
  end

  it "executes a bulk API call when an action count is reached" do
    ary = []
    ary << @index.bulk(action_count: 3) do |b|
      2.times { |num|
        document = document_wrapper("book", {_id: num, author: "Author 1", title: "This is book number #{num}"})
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      7.times { |num|
        document = document_wrapper("book", {_id: num+2, author: "Author 1", title: "This is book number #{num+2}"})
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 2, ary.length

      document = document_wrapper("book", {_id: 10, author: "Author 1", title: "This is book number 10"})
      ary << b.index(document)
    end
    ary.compact!

    assert_equal 4, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    @index.refresh
    h = @index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_7_plus?
      assert_equal 10, h["hits"]["total"]["value"]
    else
      assert_equal 10, h["hits"]["total"]
    end
  end

  it "rejects documents that excceed the maximum request size" do
    client = Elastomer::Client.new(**$client_params.merge(max_request_size: 300))
    index  = client.index(@name)

    ary = []
    book_title = $client.version_support.es_version_7_plus? ? "A"*52 : "A"*34
    ary << index.bulk(request_size: 300) do |b|
      2.times { |num|
        document = document_wrapper("book", {_id: num, author: "Author 1", title: book_title})
        ary << b.index(document)
      }
      ary.compact!

      assert_equal 0, ary.length

      document = document_wrapper("book", {_id: 342, author: "Author 1", message: "A"*290})
      assert_raises(Elastomer::Client::RequestSizeError) { b.index(document) }
    end
    ary.compact!

    assert_equal 1, ary.length
    ary.each { |a| a["items"].each { |b| assert_bulk_index(b) } }

    index.refresh
    h = index.docs.search q: "*:*", size: 0

    if $client.version_support.es_version_7_plus?
      assert_equal 2, h["hits"]["total"]["value"]
    else
      assert_equal 2, h["hits"]["total"]
    end
  end

  it "uses :id from parameters and supports symbol and string parameters" do
    response = @index.bulk do |b|
      document1 = { author: "Author 1", title: "Book 1" }
      b.index document1, $client.version_support.es_version_7_plus? ? { id: "foo" } : { id: "foo", type: "book" }

      document2 = { author: "Author 2", title: "Book 2" }
      b.index document2, $client.version_support.es_version_7_plus? ? { "id" => "bar" } : { "id" => "bar", "type" => "book" }
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    assert_equal "foo", items[0]["index"]["_id"]
    assert_equal "Book 1", @index.docs("book").get(id: "foo")["_source"]["title"]

    assert_equal "bar", items[1]["index"]["_id"]
    assert_equal "Book 2", @index.docs("book").get(id: "bar")["_source"]["title"]
  end

  it "doesn't override parameters from the document" do
    document = document_wrapper("book", { _id: 1, author: "Author 1", title: "Book 1" })
    params = { id: 2 }

    response = @index.bulk do |b|
      b.index document, params
    end

    assert_kind_of Integer, response["took"]

    items = response["items"]

    assert_bulk_index(items[0])

    refute_found @index.docs("book").get(id: 1)
    assert_equal "Book 1", @index.docs("book").get(id: 2)["_source"]["title"]
  end

  it "streams bulk responses" do
    ops = [
      [:index, document_wrapper("book", { title: "Book 1" }), { _id: 1, _index: @index.name }],
      [:index, document_wrapper("book", { title: "Book 2" }), { _id: 2, _index: @index.name }],
      [:index, document_wrapper("book", { title: "Book 3" }), { _id: 3, _index: @index.name }]
    ]
    responses = $client.bulk_stream_responses(ops, { action_count: 2 }).to_a

    assert_equal(2, responses.length)
    assert_bulk_index(responses[0]["items"][0])
    assert_bulk_index(responses[0]["items"][1])
    assert_bulk_index(responses[1]["items"][0])
  end

  it "streams bulk items" do
    ops = [
      [:index, document_wrapper("book", { title: "Book 1" }), { _id: 1, _index: @index.name }],
      [:index, document_wrapper("book", { title: "Book 2" }), { _id: 2, _index: @index.name }],
      [:index, document_wrapper("book", { title: "Book 3" }), { _id: 3, _index: @index.name }]
    ]
    items = []
    $client.bulk_stream_items(ops, { action_count: 2 }) { |item| items << item }

    assert_equal(3, items.length)
    assert_bulk_index(items[0])
    assert_bulk_index(items[1])
    assert_bulk_index(items[2])
  end
end
