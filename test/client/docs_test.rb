require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Client::Docs do

  before do
    @name  = "elastomer-docs-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        :mappings => {
          :doc1 => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => $client.version_support.text(analyzer: "standard", term_vector: "with_positions_offsets"),
              :author => $client.version_support.keyword
            }
          },
          :doc2 => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => $client.version_support.text(analyzer: "standard", term_vector: "with_positions_offsets"),
              :author => $client.version_support.keyword
            }
          }
        }

      wait_for_index(@name)
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it "autogenerates IDs for documents" do
    h = @docs.index \
          :_type  => "doc2",
          :title  => "the author of logging",
          :author => "pea53"

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]

    h = @docs.index \
          :_id    => nil,
          :_type  => "doc3",
          :title  => "the author of rubber-band",
          :author => "grantr"

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]

    h = @docs.index \
          :_id    => "",
          :_type  => "doc4",
          :title  => "the author of toml",
          :author => "mojombo"

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]
  end

  it "uses the provided document ID" do
    h = @docs.index \
          :_id    => "42",
          :_type  => "doc2",
          :title  => "the author of logging",
          :author => "pea53"

    assert_created h
    assert_equal "42", h["_id"]
  end

  it "accepts JSON encoded document strings" do
    h = @docs.index \
          '{"author":"pea53", "title":"the author of logging"}',
          :id   => "42",
          :type => "doc2"

    assert_created h
    assert_equal "42", h["_id"]

    h = @docs.index \
          '{"author":"grantr", "title":"the author of rubber-band"}',
          :type => "doc2"

    assert_created h
    assert_match %r/^\S{20,22}$/, h["_id"]
  end

  it "extracts underscore attributes from the document" do
    doc = {
      :_id => "12",
      :_type => "doc2",
      :_routing => "author",
      "_consistency" => "all",
      :title => "The Adventures of Huckleberry Finn",
      :author => "Mark Twain",
      :_unknown => "unknown attribute"
    }

    h = @docs.index doc
    assert_created h
    assert_equal "12", h["_id"]

    refute doc.key?(:_id)
    refute doc.key?(:_type)
    refute doc.key?(:_routing)
    refute doc.key?("_consistency")
    assert doc.key?(:_unknown)
  end

  it "gets documents from the search index" do
    h = @docs.get :id => "1", :type => "doc1"
    refute_found h

    populate!

    h = @docs.get :id => "1", :type => "doc1"
    assert_found h
    assert_equal "mojombo", h["_source"]["author"]
  end

  it "checks if documents exist in the search index" do
    refute @docs.exists?(:id => "1", :type => "doc1")
    populate!
    assert @docs.exists?(:id => "1", :type => "doc1")
  end

  it "checks if documents exist in the search index with .exist?" do
    refute @docs.exist?(:id => "1", :type => "doc1")
    populate!
    assert @docs.exist?(:id => "1", :type => "doc1")
  end

  it "gets multiple documents from the search index" do
    populate!

    h = @docs.multi_get :docs => [
      { :_id => 1, :_type => "doc1" },
      { :_id => 1, :_type => "doc2" }
    ]
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[mojombo pea53], authors

    h = @docs.multi_get({:ids => [2, 1]}, :type => "doc1")
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[defunkt mojombo], authors

    h = @index.docs("doc1").multi_get :ids => [1, 2, 3, 4]
    assert_found h["docs"][0]
    assert_found h["docs"][1]
    refute_found h["docs"][2]
    refute_found h["docs"][3]
  end

  it "gets multiple documents from the search index with .mget" do
    populate!

    h = @docs.mget :docs => [
      { :_id => 1, :_type => "doc1" },
      { :_id => 1, :_type => "doc2" }
    ]
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[mojombo pea53], authors

    h = @docs.mget({:ids => [2, 1]}, :type => "doc1")
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[defunkt mojombo], authors

    h = @index.docs("doc1").mget :ids => [1, 2, 3, 4]
    assert_found h["docs"][0]
    assert_found h["docs"][1]
    refute_found h["docs"][2]
    refute_found h["docs"][3]
  end

  it "deletes documents from the search index" do
    populate!
    @docs = @index.docs("doc2")

    h = @docs.multi_get :ids => [1, 2]
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[pea53 grantr], authors

    h = @docs.delete :id => 1
    assert h["found"], "expected document to be found"
    h = @docs.multi_get :ids => [1, 2]
    refute_found h["docs"][0]
    assert_found h["docs"][1]

    assert_raises(ArgumentError) { @docs.delete :id => nil }
    assert_raises(ArgumentError) { @docs.delete :id => "" }
    assert_raises(ArgumentError) { @docs.delete :id => "\t" }
  end

  it "does not care if you delete a document that is not there" do
    @docs = @index.docs("doc2")
    h = @docs.delete :id => 42

    refute h["found"], "expected document to not be found"
  end

  it "deletes documents by query" do
    populate!
    @docs = @index.docs("doc2")

    h = @docs.multi_get :ids => [1, 2]
    authors = h["docs"].map { |d| d["_source"]["author"] }
    assert_equal %w[pea53 grantr], authors

    h = @docs.delete_by_query(:q => "author:grantr")
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
    @index.refresh
    h = @docs.multi_get :ids => [1, 2]
    assert_found h["docs"][0]
    refute_found h["docs"][1]

    h = @docs.delete_by_query(
      :query => {
        :bool => {
          :filter => {:term => {:author => "pea53"}}
        }
      }
    )
    @index.refresh
    h = @docs.multi_get :ids => [1, 2]
    refute_found h["docs"][0]
    refute_found h["docs"][1]
  end

  it "searches for documents" do
    h = @docs.search :q => "*:*"
    assert_equal 0, h["hits"]["total"]

    populate!

    h = @docs.search :q => "*:*"
    assert_equal 4, h["hits"]["total"]

    h = @docs.search :q => "*:*", :type => "doc1"
    assert_equal 2, h["hits"]["total"]

    h = @docs.search({
      :query => {:match_all => {}},
      :filter => {:term => {:author => "defunkt"}}
    }, :type => %w[doc1 doc2] )
    assert_equal 1, h["hits"]["total"]

    hit = h["hits"]["hits"].first
    assert_equal "the author of resque", hit["_source"]["title"]
  end

  it "supports the shards search API" do
    h = @docs.search_shards(:type => "docs1")

    assert h.key?("nodes"), "response contains \"nodes\" information"
    assert h.key?("shards"), "response contains \"shards\" information"
    assert h["shards"].is_a?(Array), "\"shards\" is an array"
  end

  it "generates QueryParsingError exceptions on bad input when searching" do
    query = {:query => {:query_string => {:query => "OR should fail"}}}
    assert_raises(Elastomer::Client::QueryParsingError) { @docs.search(query, :type => %w[doc1 doc2]) }

    query = {:query => {:foo_is_not_valid => {}}}
    assert_raises(Elastomer::Client::QueryParsingError) { @docs.search(query, :type => %w[doc1 doc2]) }
  end

  it "counts documents" do
    h = @docs.count :q => "*:*"
    assert_equal 0, h["count"]

    populate!

    h = @docs.count :q => "*:*"
    assert_equal 4, h["count"]

    h = @docs.count :q => "*:*", :type => "doc1"
    assert_equal 2, h["count"]

    h = @docs.count :q => "*:*", :type => "doc1,doc2"
    assert_equal 4, h["count"]

    h = @docs.count({
      :query => {
        :bool => {
          :filter => {:term => {:author => "defunkt"}}
        }
      }
    }, :type => %w[doc1 doc2] )
    assert_equal 1, h["count"]
  end

  it "explains scoring" do
    populate!

    h = @docs.explain({
      :query => {
        :match => {
          "author" => "defunkt"
        }
      }
    }, :type => "doc1", :id => 2)
    assert_equal true, h["matched"]

    h = @docs.explain(:type => "doc2", :id => 2, :q => "pea53")
    assert_equal false, h["matched"]
  end

  it "validates queries" do
    populate!

    h = @docs.validate :q => "*:*"
    assert_equal true, h["valid"]

    h = @docs.validate({
      :query => {
        :filtered => {
          :query => {:match_all => {}},
          :filter => {:term => {:author => "defunkt"}}
        }
      }
    }, :type => %w[doc1 doc2])

    if filtered_query_removed?
      refute h["valid"]
    else
      assert h["valid"]
    end

    h = @docs.validate({
      :query => {
        :bool => {
          :filter => {:term => {:author => "defunkt"}}
        }
      }
    }, :type => %w[doc1 doc2])

    assert h["valid"]
  end

  it "updates documents" do
    populate!

    h = @docs.get :id => "1", :type => "doc1"
    assert_found h
    assert_equal "mojombo", h["_source"]["author"]

    @docs.update({
      :_id   => "1",
      :_type => "doc1",
      :doc   => {:author => "TwP"}
    })
    h = @docs.get :id => "1", :type => "doc1"
    assert_found h
    assert_equal "TwP", h["_source"]["author"]

    if $client.version >= "0.90"
      @docs.update({
        :_id   => "42",
        :_type => "doc1",
        :doc   => {
          :author => "TwP",
          :title  => "the ineffable beauty of search"
        },
        :doc_as_upsert => true
      })

      h = @docs.get :id => "42", :type => "doc1"
      assert_found h
      assert_equal "TwP", h["_source"]["author"]
      assert_equal "the ineffable beauty of search", h["_source"]["title"]
    end
  end

  it "supports bulk operations with the same parameters as docs" do
    response = @docs.bulk do |b|
      populate!(b)
    end

    assert_kind_of Integer, response["took"]

    response = @docs.get(:id => 1, :type => "doc1")
    assert_found response
    assert_equal "mojombo", response["_source"]["author"]
  end

  it "provides access to term vector statistics" do
    populate!

    response = @docs.termvector :type => "doc2", :id => 1, :fields => "title"

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[author logging of the], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .termvectors" do
    populate!

    response = @docs.termvectors :type => "doc2", :id => 1, :fields => "title"

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[author logging of the], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .term_vector" do
    populate!

    response = @docs.term_vector :type => "doc2", :id => 1, :fields => "title"

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[author logging of the], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to term vector statistics with .term_vectors" do
    populate!

    response = @docs.term_vectors :type => "doc2", :id => 1, :fields => "title"

    assert response["term_vectors"]["title"]
    assert response["term_vectors"]["title"]["field_statistics"]
    assert response["term_vectors"]["title"]["terms"]
    assert_equal %w[author logging of the], response["term_vectors"]["title"]["terms"].keys
  end

  it "provides access to multi term vector statistics" do
    populate!

    response = @docs.multi_termvectors({:ids => [1, 2]}, :type => "doc2", :fields => "title", :term_statistics => true)
    docs = response["docs"]

    assert docs
    assert_equal(%w[1 2], docs.map { |h| h["_id"] }.sort)
  end

  it "provides access to multi term vector statistics with .multi_term_vectors" do
    populate!

    response = @docs.multi_term_vectors({:ids => [1, 2]}, :type => "doc2", :fields => "title", :term_statistics => true)
    docs = response["docs"]

    assert docs
    assert_equal(%w[1 2], docs.map { |h| h["_id"] }.sort)
  end

  it "percolates a given document" do
    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create :query => { :match => { :author => "pea53" } }
    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create :query => { :match => { :author => "defunkt" } }
    assert response["created"], "Couldn't create the percolator query"

    response = @index.docs("doc1").percolate(:doc => { :author => "pea53" })
    assert_equal 1, response["matches"].length
    assert_equal "1", response["matches"][0]["_id"]
  end

  it "percolates an existing document" do
    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create :query => { :match => { :author => "pea53" } }
    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create :query => { :match => { :author => "defunkt" } }
    assert response["created"], "Couldn't create the percolator query"

    response = @index.docs("doc2").percolate(nil, :id => "1")
    assert_equal 1, response["matches"].length
    assert_equal "1", response["matches"][0]["_id"]
  end

  it "counts the matches for percolating a given document" do
    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create :query => { :match => { :author => "pea53" } }
    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create :query => { :match => { :author => "defunkt" } }
    assert response["created"], "Couldn't create the percolator query"

    count = @index.docs("doc1").percolate_count :doc => { :author => "pea53" }
    assert_equal 1, count
  end

  it "counts the matches for percolating an existing document" do
    populate!

    percolator1 = @index.percolator "1"
    response = percolator1.create :query => { :match => { :author => "pea53" } }
    assert response["created"], "Couldn't create the percolator query"
    percolator2 = @index.percolator "2"
    response = percolator2.create :query => { :match => { :author => "defunkt" } }
    assert response["created"], "Couldn't create the percolator query"

    count = @index.docs("doc2").percolate_count(nil, :id => "1")
    assert_equal 1, count
  end

  it "performs multi percolate queries" do
    @index.percolator("1").create :query => { :match_all => { } }
    @index.percolator("2").create :query => { :match => { :author => "pea53" } }

    h = @index.docs("doc2").multi_percolate do |m|
      m.percolate :author => "pea53"
      m.percolate :author => "grantr"
      m.count({}, { :author => "grantr" })
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
  # rubocop:disable Metrics/MethodLength
  def populate!(docs = @docs)
    docs.index \
      :_id    => 1,
      :_type  => "doc1",
      :title  => "the author of gravatar",
      :author => "mojombo"

    docs.index \
      :_id    => 2,
      :_type  => "doc1",
      :title  => "the author of resque",
      :author => "defunkt"

    docs.index \
      :_id    => 1,
      :_type  => "doc2",
      :title  => "the author of logging",
      :author => "pea53"

    docs.index \
      :_id    => 2,
      :_type  => "doc2",
      :title  => "the author of rubber-band",
      :author => "grantr"

    @index.refresh
  end
  # rubocop:enable Metrics/MethodLength

end
