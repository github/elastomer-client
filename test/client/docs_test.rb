# frozen_string_literal: true

require_relative "../test_helper"

describe Elastomer::Client::Docs do

  before do
    @name  = "elastomer-docs-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: $client.version_support.text(analyzer: "standard", term_vector: "with_positions_offsets"),
            author: $client.version_support.keyword
          }
        }, true)

      # COMPATIBILITY
      if !$client.version_support.es_version_7_plus? && requires_percolator_mapping?
        @index.update_mapping("percolator", { properties: { query: { type: "percolator"}}})
      end

      wait_for_index(@name)
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it "raises error when writing same document twice" do
    document = document_wrapper("book", {
      _id: "documentid",
      _op_type: "create",
      title: "Book by Author1",
      author: "Author1"
    })
    h = @docs.index document.dup

    assert_created h

    assert_raises(Elastomer::Client::DocumentAlreadyExistsError) do
      @docs.index document.dup
    end
  end

  it "autogenerates IDs for documents" do
    h = @docs.index \
      document_wrapper("book", {
        _id: nil,
        title: "Book1 by author 1",
        author: "Author1"
      })

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]

    h = @docs.index \
      document_wrapper("book", {
        _id: nil,
        title: "Book2 by author 2",
        author: "Author2"
      })

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]
  end

  it "uses the provided document ID" do
    h = @docs.index \
      document_wrapper("book", {
        _id: 42,
        title: "Book1 by author 1",
        author: "Author1"
      })

    assert_created h
    assert_equal "42", h["_id"]
  end

  it "accepts JSON encoded document strings" do
    if $client.version_support.es_version_7_plus?
      h = @docs.index \
        '{"author":"Author1", "title":"Book1 by author 1"}',
        id: 42
    else
      h = @docs.index \
        '{"author":"Author1", "title":"Book1 by author 1"}',
        id: 42,
        type: "book"
    end

    assert_created h
    assert_equal "42", h["_id"]
  end

  describe "indexing directive fields" do
    before do
      # Since we set dynamic: strict, adding the above doc to the index throws an error, so update the index to allow dynamic mapping
      if !$client.version_support.es_version_7_plus?
        @index.update_mapping "book", { book: { dynamic: "true" } }
      end
    end

    after do
      # Since we set dynamic: strict, adding the above doc to the index throws an error, so update the index to allow dynamic mapping
      if !$client.version_support.es_version_7_plus?
        @index.update_mapping "book", { book: { dynamic: "strict" } }
      end
    end

    it "indexes fields that are not recognized as indexing directives" do
      doc = document_wrapper("book", {
        _id: "12",
        title: "Book1",
        author: "Author1",
        _unknown_1: "unknown attribute 1",
        "_unknown_2": "unknown attribute 2"
      })

      h = @docs.index(doc)

      assert_created h
      assert_equal "12", h["_id"]

      indexed_doc = $client.version_support.es_version_7_plus? ? @docs.get(id: "12") : @docs.get(type: "book", id: "12")
      expected = {
        "title" => "Book1",
        "author" => "Author1",
        "_unknown_1" => "unknown attribute 1",
        "_unknown_2" => "unknown attribute 2"
      }

      assert_equal expected, indexed_doc["_source"]
    end

    it "extracts indexing directives from the document" do
      doc = document_wrapper("book", {
        _id: "12",
        _routing: "author",
        title: "Book1",
        author: "Author1"
      })

      h = @docs.index(doc)

      assert_created h
      assert_equal "12", h["_id"]

      # Special keys are removed from the document hash
      refute doc.key?(:_id)
      refute doc.key?("_type")
      refute doc.key?(:_routing)

      indexed_doc = $client.version_support.es_version_7_plus? ? @docs.get(id: "12") : @docs.get(type: "book", id: "12")
      expected = {
        "title" => "Book1",
        "author" => "Author1"
      }

      assert_equal expected, indexed_doc["_source"]
    end

    # COMPATIBILITY: Fail fast on known indexing directives that aren't for this version of ES
    it "raises an exception when a known indexing directive from an unsupported version is used" do
      # Symbol keys
      doc = document_wrapper("book", {
        _id: "12",
        title: "Book1"
      }).merge(incompatible_indexing_directive)

      assert_raises(Elastomer::Client::IllegalArgument) do
        @docs.index(doc)
      end

      # String keys
      doc = document_wrapper("book", {
        "_id" => "12",
        "title" => "Book1"
      }).merge(incompatible_indexing_directive.stringify_keys)

      assert_raises(Elastomer::Client::IllegalArgument) do
        @docs.index(doc)
      end
    end
  end

  it "gets documents from the search index" do
    h = $client.version_support.es_version_7_plus? ? @docs.get(id: "1") : @docs.get(id: "1", type: "book")

    refute_found h

    populate!

    h = $client.version_support.es_version_7_plus? ? @docs.get(id: "1") : @docs.get(id: "1", type: "book")

    assert_found h
    assert_equal "Author1", h["_source"]["author"]
  end

  it "checks if documents exist in the search index" do
    refute $client.version_support.es_version_7_plus? ? @docs.exists?(id: "1") : @docs.exists?(id: "1", type: "book")
    populate!

    assert $client.version_support.es_version_7_plus? ? @docs.exists?(id: "1") : @docs.exists?(id: "1", type: "book")
  end

  it "checks if documents exist in the search index with .exist?" do
    refute $client.version_support.es_version_7_plus? ? @docs.exist?(id: "1") : @docs.exist?(id: "1", type: "book")
    populate!

    assert $client.version_support.es_version_7_plus? ? @docs.exist?(id: "1") : @docs.exist?(id: "1", type: "book")
  end

  it "gets multiple documents from the search index" do
    populate!

    h = @docs.multi_get docs: [
      document_wrapper("book", { _id: 1 }),
      document_wrapper("book", { _id: 2 })
    ]
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author1 Author2], authors

    h = $client.version_support.es_version_7_plus? ? @docs.multi_get({ids: [2, 1]}) : @docs.multi_get({ids: [2, 1]}, type: "book")
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author2 Author1], authors

    h = @index.docs("book").multi_get ids: [1, 2, 3, 4]

    assert_found h["docs"][0]
    assert_found h["docs"][1]
    refute_found h["docs"][2]
    refute_found h["docs"][3]
  end

  it "gets multiple documents from the search index with .mget" do
    populate!

    h = @docs.mget docs: [
      document_wrapper("book", { _id: 1 }),
      document_wrapper("book", { _id: 2 })
    ]
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author1 Author2], authors

    h = @docs.mget({ids: [2, 1]})
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author2 Author1], authors

    h = @index.docs("book").mget ids: [1, 2, 3, 4]

    assert_found h["docs"][0]
    assert_found h["docs"][1]
    refute_found h["docs"][2]
    refute_found h["docs"][3]
  end

  it "deletes documents from the search index" do
    populate!
    @docs = @index.docs("book")

    h = @docs.multi_get ids: [1, 2]
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author1 Author2], authors

    h = @docs.delete id: 1

    if $client.version_support.es_version_7_plus?
      assert h["result"], "deleted"
    else
      assert h["found"], "expected document to be found"
    end

    h = @docs.multi_get ids: [1, 2]

    refute_found h["docs"][0]
    assert_found h["docs"][1]

    assert_raises(ArgumentError) { @docs.delete id: nil }
    assert_raises(ArgumentError) { @docs.delete id: "" }
    assert_raises(ArgumentError) { @docs.delete id: "\t" }
  end

  it "does not care if you delete a document that is not there" do
    @docs = @index.docs("book")
    h = @docs.delete id: 42

    refute h["found"], "expected document to not be found"
  end

  it "deletes documents by query" do
    populate!
    @docs = @index.docs("book")

    h = @docs.multi_get ids: [1, 2]
    authors = h["docs"].map { |d| d["_source"]["author"] }

    assert_equal %w[Author1 Author2], authors

    h = @docs.delete_by_query(q: "author:Author2")

    if supports_native_delete_by_query?
      assert_equal(1, h["deleted"])
    else
      assert_equal(h["_indices"], {
        "_all" => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
        @name => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
      })
    end

    @index.refresh
    h = @docs.multi_get ids: [1, 2]

    assert_found h["docs"][0]
    refute_found h["docs"][1]

    h = @docs.delete_by_query(
      query: {
        bool: {
          filter: {term: {author: "Author1"}}
        }
      }
    )
    @index.refresh
    h = @docs.multi_get ids: [1, 2]

    refute_found h["docs"][0]
    refute_found h["docs"][1]
  end

  it "searches for documents" do
    h = @docs.search q: "*:*"

    if $client.version_support.es_version_7_plus?
      assert_equal 0, h["hits"]["total"]["value"]
    else
      assert_equal 0, h["hits"]["total"]
    end

    populate!

    h = @docs.search q: "*:*"

    if $client.version_support.es_version_7_plus?
      assert_equal 2, h["hits"]["total"]["value"]
    else
      assert_equal 2, h["hits"]["total"]
    end

    if !$client.version_support.es_version_7_plus?
      h = @docs.search q: "*:*", type: "book"

      assert_equal 2, h["hits"]["total"]
    end

    h = @docs.search({
      query: {match_all: {}},
      post_filter: {term: {author: "Author1"}}
    })

    if $client.version_support.es_version_7_plus?
      assert_equal 1, h["hits"]["total"]["value"]
    else
      assert_equal 1, h["hits"]["total"]
    end

    hit = h["hits"]["hits"].first

    assert_equal "Book1 by author 1", hit["_source"]["title"]
  end

  it "supports the shards search API" do
    # We add the type param to all requests (type is _doc for ES 7)
    # But the shards endpoint has to be used without the type param to return the shard data for ES 7
    h = @docs.search_shards(params={}, remove_type_param = $client.version_support.es_version_7_plus?)

    assert h.key?("nodes"), "response contains \"nodes\" information"
    assert h.key?("shards"), "response contains \"shards\" information"
    assert h["shards"].is_a?(Array), "\"shards\" is an array"
  end

  it "generates QueryParsingError exceptions on bad input when searching" do
    query = {query: {query_string: {query: "OR should fail"}}}
    assert_raises(Elastomer::Client::QueryParsingError) { @docs.search(query) }

    query = {query: {foo_is_not_valid: {}}}
    assert_raises(Elastomer::Client::QueryParsingError) { @docs.search(query) }
  end

  it "counts documents" do
    h = @docs.count q: "*:*"

    assert_equal 0, h["count"]

    populate!

    h = @docs.count q: "*:*"

    assert_equal 2, h["count"]

    if !$client.version_support.es_version_7_plus?
      h = @docs.count(q: "*:*", type: "book")

      assert_equal 2, h["count"]
    end

    h = @docs.count({
      query: {
        bool: {
          filter: {term: {author: "Author1"}}
        }
      }
    })

    assert_equal 1, h["count"]
  end

  it "explains scoring" do
    populate!

    h = $client.version_support.es_version_7_plus? ?
      @docs.explain({
        query: {
          match: {
            "author" => "Author1"
          }
        }
      }, id: 1)
      : @docs.explain({
        query: {
          match: {
            "author" => "Author1"
          }
        }
      }, id: 1, type: "book")

    assert h["matched"]

    h = $client.version_support.es_version_7_plus? ? @docs.explain(id: 2, q: "Author1") : @docs.explain(type: "book", id: 2, q: "Author1")

    refute h["matched"]
  end

  it "validates queries" do
    populate!

    h = @docs.validate q: "*:*"

    assert h["valid"]

    h = @docs.validate({
      query: {
        filtered: {
          query: {match_all: {}},
          filter: {term: {author: "Author2"}}
        }
      }
    })

    if filtered_query_removed?
      refute h["valid"]
    else
      assert h["valid"]
    end

    h = @docs.validate({
      query: {
        bool: {
          filter: {term: {author: "Author2"}}
        }
      }
    })

    assert h["valid"]
  end

  it "updates documents" do
    populate!

    h = $client.version_support.es_version_7_plus? ? @docs.get(id: "1") : @docs.get(id: "1", type: "book")

    assert_found h
    assert_equal "Author1", h["_source"]["author"]

    @docs.update(document_wrapper("book", {
      _id: "1",
      doc: {author: "Author1.1"}
    }))
    h = $client.version_support.es_version_7_plus? ? @docs.get(id: "1") : @docs.get(id: "1", type: "book")

    assert_found h
    assert_equal "Author1.1", h["_source"]["author"]

    if $client.version >= "0.90"
      @docs.update(document_wrapper("book", {
        _id: "42",
        doc: {
          author: "Author42",
          title: "Book42"
        },
        doc_as_upsert: true
      }))

      h = $client.version_support.es_version_7_plus? ? @docs.get(id: "42") : @docs.get(id: "42", type: "book")

      assert_found h
      assert_equal "Author42", h["_source"]["author"]
      assert_equal "Book42", h["_source"]["title"]
    end
  end

  it "supports bulk operations with the same parameters as docs" do
    response = @docs.bulk do |b|
      populate!(b)
    end

    assert_kind_of Integer, response["took"]

    response = $client.version_support.es_version_7_plus? ? @docs.get(id: 1) : @docs.get(id: 1, type: "book")

    assert_found response
    assert_equal "Author1", response["_source"]["author"]
  end

  it "provides access to term vector statistics" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.termvector(id: 1, fields: "title") : @docs.termvector(type: "book", id: 1, fields: "title")

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[1 author book1 by], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .termvectors" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.termvectors(id: 1, fields: "title") : @docs.termvectors(type: "book", id: 1, fields: "title")

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[1 author book1 by], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .term_vector" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.term_vector(id: 1, fields: "title") : @docs.term_vector(type: "book", id: 1, fields: "title")

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[1 author book1 by], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .term_vectors" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.term_vectors(id: 1, fields: "title") : @docs.term_vectors(type: "book", id: 1, fields: "title")

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[1 author book1 by], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to multi term vector statistics" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.multi_termvectors({ids: [1, 2]}, fields: "title", term_statistics: true) : @docs.multi_termvectors({ids: [1, 2]}, type: "book", fields: "title", term_statistics: true)
    docs = response["docs"]

    assert docs
    assert_equal(%w[1 2], docs.map { |h| h["_id"] }.sort)
  end

  it "provides access to multi term vector statistics with .multi_term_vectors" do
    populate!

    response = $client.version_support.es_version_7_plus? ? @docs.multi_term_vectors({ids: [1, 2]}, fields: "title", term_statistics: true) : @docs.multi_term_vectors({ids: [1, 2]}, type: "book", fields: "title", term_statistics: true)
    docs = response["docs"]

    assert docs
    assert_equal(%w[1 2], docs.map { |h| h["_id"] }.sort)
  end

  it "percolates a given document" do
    if $client.version_support.es_version_7_plus?
      skip "Percolate not supported in ES version #{$client.version}"
    end

    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create query: { match: { author: "Author1" } }

    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create query: { match: { author: "Author2" } }

    assert response["created"], "Couldn't create the percolator query"
    @index.refresh

    response = @index.docs("book").percolate(doc: { author: "Author1" })

    assert_equal 1, response["matches"].length
    assert_equal "1", response["matches"][0]["_id"]
  end

  it "percolates an existing document" do
    if $client.version_support.es_version_7_plus?
      skip "Percolate not supported in ES version #{$client.version}"
    end

    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create query: { match: { author: "Author1" } }

    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create query: { match: { author: "Author2" } }

    assert response["created"], "Couldn't create the percolator query"
    @index.refresh

    response = @index.docs("book").percolate(nil, id: "1")

    assert_equal 1, response["matches"].length
    assert_equal "1", response["matches"][0]["_id"]
  end

  it "counts the matches for percolating a given document" do
    if $client.version_support.es_version_7_plus?
      skip "Percolate not supported in ES version #{$client.version}"
    end

    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create query: { match: { author: "Author1" } }

    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create query: { match: { author: "Author2" } }

    assert response["created"], "Couldn't create the percolator query"
    @index.refresh

    count = @index.docs("book").percolate_count doc: { author: "Author1" }

    assert_equal 1, count
  end

  it "counts the matches for percolating an existing document" do
    if $client.version_support.es_version_7_plus?
      skip "Percolate not supported in ES version #{$client.version}"
    end

    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create query: { match: { author: "Author1" } }

    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create query: { match: { author: "Author2" } }

    assert response["created"], "Couldn't create the percolator query"
    @index.refresh

    count = @index.docs("book").percolate_count(nil, id: "1")

    assert_equal 1, count
  end

  it "performs multi percolate queries" do
    if $client.version_support.es_version_7_plus?
      skip "Multi percolate not supported in ES version #{$client.version}"
    end

    @index.percolator("1").create query: { match_all: { } }
    @index.percolator("2").create query: { match: { author: "Author1" } }
    @index.refresh

    h = @index.docs("book").multi_percolate do |m|
      m.percolate author: "Author1"
      m.percolate author: "Author2"
      m.count({}, { author: "Author2" })
    end

    response1, response2, response3 = h["responses"]

    assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
    assert_equal ["1"], response2["matches"].map { |match| match["_id"] }.sort
    assert_equal 1, response3["total"]
  end

  # Create/index multiple documents.
  #
  # docs - An instance of Elastomer::Client::Docs or Elastomer::Client::Bulk. If
  #        nil uses the @docs instance variable.
  def populate!(docs = @docs)
    docs.index \
      document_wrapper("book", {
        _id: 1,
        title: "Book1 by author 1",
        author: "Author1"
      })

    docs.index \
      document_wrapper("book", {
        _id: 2,
        title: "Book2 by author 2",
        author: "Author2"
      })

    @index.refresh
  end
  # rubocop:enable Metrics/MethodLength

end
