# frozen_string_literal: true

require_relative "../test_helper"

describe Elastomer::Client::Index do

  before do
    @name  = "elastomer-index-test"
    @index = $client.index @name
    @index.delete if @index.exists?
  end

  after do
    @index.delete if @index.exists?
  end

  it "does not require an index name" do
    index = $client.index

    assert_nil index.name
  end

  it "determines if an index exists" do
    refute_predicate @index, :exists?, "the index should not yet exist"
  end

  it "determines if an index exists with .exist?" do
    refute_predicate @index, :exist?, "the index should not yet exist"
  end

  describe "when creating an index" do
    it "creates an index" do
      @index.create({})

      assert_predicate @index, :exists?, "the index should now exist"
    end

    it "creates an index with settings" do
      @index.create settings: { number_of_shards: 3, number_of_replicas: 0 }
      settings = @index.get_settings[@name]["settings"]

      assert_equal "3", settings["index"]["number_of_shards"]
      assert_equal "0", settings["index"]["number_of_replicas"]
    end

    it "creates an index with settings with .settings" do
      @index.create settings: { number_of_shards: 3, number_of_replicas: 0 }
      settings = @index.settings[@name]["settings"]

      assert_equal "3", settings["index"]["number_of_shards"]
      assert_equal "0", settings["index"]["number_of_replicas"]
    end

    it "adds mappings for document types" do
      @index.create(
        settings: { number_of_shards: 1, number_of_replicas: 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: false },
          properties: {
            title: { type: "text", analyzer: "standard" },
            author: { type: "keyword" }
          }
        }, true)
      )

      assert_predicate @index, :exists?, "the index should now exist"
      assert_mapping_exists @index.get_mapping[@name], "book"
    end

    it "adds mappings for document types with .mapping" do
      @index.create(
        settings: { number_of_shards: 1, number_of_replicas: 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: false },
          properties: {
            title: { type: "text", analyzer: "standard" },
            author: { type: "keyword" }
          }
        }, true)
      )

      assert_predicate @index, :exists?, "the index should now exist"
      assert_mapping_exists @index.mapping[@name], "book"
    end
  end

  it "updates index settings" do
    @index.create settings: { number_of_shards: 1, number_of_replicas: 0 }

    @index.update_settings "index.number_of_replicas" => 1
    settings = @index.settings[@name]["settings"]

    assert_equal "1", settings["index"]["number_of_replicas"]
  end

  it "updates document mappings" do
    @index.create(
      mappings: mappings_wrapper("book", {
        _source: { enabled: false },
          properties: { title: { type: "text", analyzer: "standard" } }
      }, true)
    )

    assert_property_exists @index.mapping[@name], "book", "title"

    if $client.version_support.es_version_7_plus?
      @index.update_mapping "_doc", { properties: {
        author: { type: "keyword" }
      }}
    else
      @index.update_mapping "book", { book: { properties: {
        author: { type: "keyword" }
      }}}
    end

    assert_property_exists @index.mapping[@name], "book", "author"
    assert_property_exists @index.mapping[@name], "book", "title"

    # ES7 removes mapping types so test adding a new mapping type only for versions < 7
    if !$client.version_support.es_version_7_plus?
      @index.update_mapping "mux_mool", { mux_mool: { properties: {
        song: { type: "keyword" }
      }}}

      assert_property_exists @index.mapping[@name], "mux_mool", "song"
    end
  end

  it "updates document mappings with .put_mapping" do
    @index.create(
      mappings: mappings_wrapper("book", {
        _source: { enabled: false },
          properties: { title: { type: "text", analyzer: "standard" } }
      }, true)
    )

    assert_property_exists @index.mapping[@name], "book", "title"

    if $client.version_support.es_version_7_plus?
      @index.put_mapping "_doc", { properties: {
        author: { type: "keyword" }
      }}
    else
      @index.put_mapping "book", { book: { properties: {
        author: { type: "keyword" }
      }}}
    end

    assert_property_exists @index.mapping[@name], "book", "author"
    assert_property_exists @index.mapping[@name], "book", "title"

    # ES7 removes mapping types so test adding a new mapping type only for versions < 7
    if !$client.version_support.es_version_7_plus?
      @index.put_mapping "mux_mool", { mux_mool: { properties: {
        song: { type: "keyword" }
      }}}

      assert_property_exists @index.mapping[@name], "mux_mool", "song"
    end
  end

  it "lists all aliases to the index" do
    @index.create(nil)

    assert_equal({@name => {"aliases" => {}}}, @index.get_aliases)

    $client.cluster.update_aliases add: {index: @name, alias: "foofaloo"}
    $client.cluster.update_aliases add: {index: @name, alias: "bar"}

    assert_equal({@name => {"aliases" => {"foofaloo" => {}, "bar" => {}}}}, @index.get_aliases)

    assert_equal({@name => {"aliases" => {"foofaloo" => {}}}}, @index.get_alias("f*"))
    assert_equal({@name => {"aliases" => {"foofaloo" => {}, "bar" => {}}}}, @index.get_alias("*"))

    exception = assert_raises(Elastomer::Client::RequestError) do
      @index.get_alias("not-there")
    end

    assert_equal("alias [not-there] missing", exception.message)
    assert_equal(404, exception.status)

    # In ES 7, when you use wildcards, an error is not raised if no match is found
    if $client.version_support.es_version_7_plus?
      assert_empty(@index.get_alias("not*"))
    else
      exception = assert_raises(Elastomer::Client::RequestError) do
        @index.get_alias("not*")
      end

      assert_equal("alias [not*] missing", exception.message)
      assert_equal(404, exception.status)
    end
  end

  it "adds and deletes aliases to the index" do
    @index.create(nil)

    assert_empty @index.get_alias("*")

    @index.add_alias "gondolin"
    aliases = @index.get_alias("*")

    assert_equal %w[gondolin], aliases[@name]["aliases"].keys.sort

    @index.add_alias "gondor"
    aliases = @index.get_alias("*")

    assert_equal %w[gondolin gondor], aliases[@name]["aliases"].keys.sort

    @index.delete_alias "gon*"

    assert_empty @index.get_alias("*")
  end

  it "analyzes text and returns tokens" do
    tokens = @index.analyze({text: "Just a few words to analyze.", analyzer: "standard"}, index: nil)
    tokens = tokens["tokens"].map { |h| h["token"] }

    assert_equal %w[just a few words to analyze], tokens

    @index.create(
      settings: {
        number_of_shards: 1,
        number_of_replicas: 0,
        analysis: {
          analyzer: {
            english_standard: {
              type: :standard,
              stopwords: "_english_"
            }
          }
        }
      }
    )
    wait_for_index(@name)

    tokens = @index.analyze({text: "Just a few words to analyze.", analyzer: "english_standard"})
    tokens = tokens["tokens"].map { |h| h["token"] }

    assert_equal %w[just few words analyze], tokens
  end

  it "accepts a type param and does not throw an error for ES7" do
    if !$client.version_support.es_version_7_plus?
      skip "This test is only needed for ES 7 onwards"
    end

    @index.create(
      mappings: mappings_wrapper("book", {
        _source: { enabled: false },
          properties: { title: { type: "text", analyzer: "standard" } }
      }, true)
    )

    assert_property_exists @index.mapping(type: "book")[@name], "book", "title"

    @index.update_mapping "book", { properties: {
      author: { type: "keyword" }
    }}

    assert_property_exists @index.mapping(type: "book")[@name], "book", "author"
    assert_property_exists @index.mapping(type: "book")[@name], "book", "title"
  end

  describe "when an index does not exist" do
    it "raises an IndexNotFoundError on delete" do
      index = $client.index("index-that-does-not-exist")
      assert_raises(Elastomer::Client::IndexNotFoundError) { index.delete }
    end
  end

  describe "when an index exists" do
    before do
      suggest = {
        type: "completion",
        analyzer: "simple",
        search_analyzer: "simple",
      }

      @index.create(
        settings: { number_of_shards: 1, number_of_replicas: 0 },
        mappings: mappings_wrapper("book", {
          _source: { enabled: true },
          properties: {
            title: { type: "text", analyzer: "standard" },
            author: { type: "keyword" },
            suggest: suggest
          }
        }, true)
      )
      wait_for_index(@name)
    end

    #TODO assert this only hits the desired index
    it "deletes" do
      response = @index.delete

      assert_acknowledged response
    end

    it "opens" do
      response = @index.open

      assert_acknowledged response
    end

    it "closes" do
      response = @index.close

      assert_acknowledged response
    end

    it "refreshes" do
      response = @index.refresh

      assert_equal 0, response["_shards"]["failed"]
    end

    it "flushes" do
      response = @index.flush

      assert_equal 0, response["_shards"]["failed"]
    end

    it "force merges" do
      response = @index.forcemerge

      assert_equal 0, response["_shards"]["failed"]
    end

    it "optimizes through force merge" do
      assert_equal @index.method(:forcemerge),  @index.method(:optimize)
    end

    it "recovery" do
      response = @index.recovery

      assert_includes response, "elastomer-index-test"
    end

    it "clears caches" do
      response = @index.clear_cache

      assert_equal 0, response["_shards"]["failed"]
    end

    it "gets stats" do
      response = @index.stats
      if response.key? "indices"
        assert_includes response["indices"], "elastomer-index-test"
      else
        assert_includes response["_all"]["indices"], "elastomer-index-test"
      end
    end

    it "gets segments" do
      response = @index.segments

      assert_includes response["indices"], "elastomer-index-test"
    end

    it "deletes by query" do
      @index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
      @index.refresh
      r = @index.delete_by_query(q: "*")

      assert_equal(1, r["deleted"])
    end

    it "updates by query" do
      @index.docs.index(document_wrapper("book", { _id: 1, title: "Book 1" }))
      @index.refresh
      r = @index.update_by_query(
        query: { match_all: {}},
        script: { source: "ctx._source.title = 'Book 2'" }
      )

      @index.refresh
      updated = @index.docs.get(id: 1, type: "book")

      assert_equal(1, r["updated"])
      assert_equal("Book 2", updated["_source"]["title"])

      r = @index.update_by_query({
        query: { match_all: {}},
        script: { source: "ctx._source.title = 'Book 3'" }
      }, conflicts: "proceed")

      @index.refresh
      updated = @index.docs.get(id: 1, type: "book")

      assert_equal(1, r["updated"])
      assert_equal("Book 3", updated["_source"]["title"])
    end

    it "creates a Percolator" do
      id = "1"
      percolator = @index.percolator id

      assert_equal id, percolator.id
    end

    it "performs multi percolate queries" do
      # The _percolate endpoint is removed from ES 7, and replaced with percolate queries via _search and _msearch
      if !$client.version_support.es_version_7_plus?
        @index.update_mapping("percolator", { properties: { query: { type: "percolator" } } })

        @index.docs.index \
          document_wrapper("book", {
            _id: 1,
            title: "Book 1 by author 1",
            author: "Author 1"
          })

        @index.docs.index \
          document_wrapper("book", {
            _id: 2,
            title: "Book 2 by author 2",
            author: "Author 2"
          })

        @index.percolator("1").create query: { match_all: { } }
        @index.percolator("2").create query: { match: { author: "Author 1" } }
        @index.refresh

        h = @index.multi_percolate(type: "book") do |m|
          m.percolate author: "Author 1"
          m.percolate author: "Author 2"
          m.count({ author: "Author 2" }, {})
        end

        response1, response2, response3 = h["responses"]

        assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
        assert_equal ["1"], response2["matches"].map { |match| match["_id"] }.sort
        assert_equal 1, response3["total"]
      end
    end

    it "performs suggestion queries" do
      # The _suggest endpoint is removed from ES 7, suggest functionality is now via _search
      if !$client.version_support.es_version_7_plus?
        @index.docs.index \
          document_wrapper("book", {
            _id: 1,
            title: "the magnificent",
            author: "greg",
            suggest: {input: "greg", weight: 2}
          })

        @index.docs.index \
          document_wrapper("book", {
            _id: 2,
            title: "the author of rubber-band",
            author: "grant",
            suggest: {input: "grant", weight: 1}
          })
        @index.refresh
        response = @index.suggest({name: {text: "gr", completion: {field: :suggest}}})

        assert response.key?("name")
        hash = response["name"].first

        assert_equal "gr", hash["text"]

        options = hash["options"]

        assert_equal 2, options.length
        assert_equal "greg", options.first["text"]
        assert_equal "grant", options.last["text"]
      end
    end

    it "handles output parameter of field" do
      document = document_wrapper("book", {
        _id:     1,
        title:   "the magnificent",
        author:  "greg",
        suggest: {input: %w[Greg greg], output: "Greg", weight: 2}
      })

      # Indexing the document fails when `output` is provided
      exception = assert_raises(Elastomer::Client::RequestError) do
        @index.docs.index(document)
      end

      assert_equal(400, exception.status)
      assert_match(/\[output\]/, exception.message)
    end
  end
end
