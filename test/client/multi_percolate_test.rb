require_relative "../test_helper"

describe Elastomer::Client::MultiPercolate do

  before do
    @name  = "elastomer-mpercolate-test"
    @index = $client.index(@name)

    unless @index.exists?
      base_mappings_settings = {
        settings: { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        mappings: {
          doc1: {
            _source: { enabled: true }, _all: { enabled: false },
            properties: {
              title: $client.version_support.text(analyzer: "standard"),
              author: $client.version_support.keyword
            }
          },
          doc2: {
            _source: { enabled: true }, _all: { enabled: false },
            properties: {
              title: $client.version_support.text(analyzer: "standard"),
              author: $client.version_support.keyword
            }
          }
        }
      }

      # COMPATIBILITY
      if requires_percolator_mapping?
        base_mappings_settings[:mappings][:percolator] = { properties: { query: { type: "percolator" } } }
      end

      @index.create base_mappings_settings
      wait_for_index(@name)
    end

    @docs = @index.docs
  end

  after do
    @index.delete if @index.exists?
  end

  it "performs multi percolate queries" do
    populate!

    body = [
      '{"percolate" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "pea53"}}',
      '{"percolate" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "grantr"}}',
      '{"count" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "grantr"}}',
      nil
    ]
    body = body.join "\n"
    h = $client.multi_percolate body
    response1, response2, response3 = h["responses"]
    assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
    assert_equal ["1", "3"], response2["matches"].map { |match| match["_id"] }.sort
    assert_equal 2, response3["total"]
  end

  it "performs multi percolate queries with .mpercolate" do
    populate!

    body = [
      '{"percolate" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "pea53"}}',
      '{"percolate" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "grantr"}}',
      '{"count" : {"index": "elastomer-mpercolate-test", "type": "doc2"}}',
      '{"doc": {"author": "grantr"}}',
      nil
    ]
    body = body.join "\n"
    h = $client.mpercolate body
    response1, response2, response3 = h["responses"]
    assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
    assert_equal ["1", "3"], response2["matches"].map { |match| match["_id"] }.sort
    assert_equal 2, response3["total"]
  end

  it "supports a nice block syntax" do
    populate!

    h = $client.multi_percolate(index: @name, type: "doc2") do |m|
      m.percolate author: "pea53"
      m.percolate author: "grantr"
      m.count({ author: "grantr" })
    end

    response1, response2, response3 = h["responses"]
    assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
    assert_equal ["1", "3"], response2["matches"].map { |match| match["_id"] }.sort
    assert_equal 2, response3["total"]
  end

  def populate!
    @docs.index \
      _id: 1,
      _type: "doc1",
      title: "the author of gravatar",
      author: "mojombo"

    @docs.index \
      _id: 2,
      _type: "doc1",
      title: "the author of resque",
      author: "defunkt"

    @docs.index \
      _id: 1,
      _type: "doc2",
      title: "the author of logging",
      author: "pea53"

    @docs.index \
      _id: 2,
      _type: "doc2",
      title: "the author of rubber-band",
      author: "grantr"

    percolator1 = @index.percolator "1"
    percolator1.create query: { match_all: { } }
    percolator2 = @index.percolator "2"
    percolator2.create query: { match: { author: "pea53" } }
    percolator2 = @index.percolator "3"
    percolator2.create query: { match: { author: "grantr" } }

    @index.refresh
  end
  # rubocop:enable Metrics/MethodLength
end
