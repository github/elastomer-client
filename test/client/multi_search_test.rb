require_relative "../test_helper"

describe Elastomer::Client::MultiSearch do

  before do
    @name  = "elastomer-msearch-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        :mappings => {
          :doc1 => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => $client.version_support.text(analyzer: "standard"),
              :author => $client.version_support.keyword
            }
          },
          :doc2 => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => $client.version_support.text(analyzer: "standard"),
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

  it "performs multisearches" do
    populate!

    body = [
      '{"index" : "elastomer-msearch-test", "size" : 0}',
      '{"query" : {"match_all" : {}}}',
      '{"index" : "elastomer-msearch-test", "type": "doc2"}',
      '{"query" : {"match": {"author" : "grantr"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.multi_search body
    response1, response2 = h["responses"]
    assert_equal 4, response1["hits"]["total"]
    assert_equal 1, response2["hits"]["total"]
    assert_equal "2", response2["hits"]["hits"][0]["_id"]

    body = [
      "{}",
      '{"query" : {"match": {"author" : "grantr"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.multi_search body, :index => @name
    response1 = h["responses"].first
    assert_equal 1, response1["hits"]["total"]
    assert_equal "2", response1["hits"]["hits"][0]["_id"]
  end

  it "performs multisearches with .msearch" do
    populate!

    body = [
      '{"index" : "elastomer-msearch-test", "size" : 0}',
      '{"query" : {"match_all" : {}}}',
      '{"index" : "elastomer-msearch-test", "type": "doc2"}',
      '{"query" : {"match": {"author" : "grantr"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.msearch body
    response1, response2 = h["responses"]
    assert_equal 4, response1["hits"]["total"]
    assert_equal 1, response2["hits"]["total"]
    assert_equal "2", response2["hits"]["hits"][0]["_id"]

    body = [
      "{}",
      '{"query" : {"match": {"author" : "grantr"}}}',
      nil
    ]
    body = body.join "\n"
    h = $client.msearch body, :index => @name
    response1 = h["responses"].first
    assert_equal 1, response1["hits"]["total"]
    assert_equal "2", response1["hits"]["hits"][0]["_id"]
  end

  it "supports a nice block syntax" do
    populate!

    h = $client.multi_search do |m|
      m.search({:query => { :match_all => {}}}, :index => @name, :size => 0)
      m.search({:query => { :match => { "title" => "author" }}}, :index => @name, :type => "doc2")
    end

    response1, response2 = h["responses"]

    assert_equal 4, response1["hits"]["total"]
    assert_equal 2, response2["hits"]["total"]

    h = @index.multi_search do |m|
      m.search({:query => { :match_all => {}}}, :size => 0)
      m.search({:query => { :match => { "title" => "author" }}}, :type => "doc2")
    end

    response1, response2 = h["responses"]

    assert_equal 4, response1["hits"]["total"]
    assert_equal 2, response2["hits"]["total"]

    h = @index.docs("doc1").multi_search do |m|
      m.search({:query => { :match_all => {}}}, :size => 0)
      m.search({:query => { :match => { "title" => "logging" }}}, :type => "doc2")
    end

    response1, response2 = h["responses"]

    assert_equal 2, response1["hits"]["total"]
    assert_equal 1, response2["hits"]["total"]
  end

  # rubocop:disable Metrics/MethodLength
  def populate!
    @docs.index \
      :_id    => 1,
      :_type  => "doc1",
      :title  => "the author of gravatar",
      :author => "mojombo"

    @docs.index \
      :_id    => 2,
      :_type  => "doc1",
      :title  => "the author of resque",
      :author => "defunkt"

    @docs.index \
      :_id    => 1,
      :_type  => "doc2",
      :title  => "the author of logging",
      :author => "pea53"

    @docs.index \
      :_id    => 2,
      :_type  => "doc2",
      :title  => "the author of rubber-band",
      :author => "grantr"

    @index.refresh
  end
  # rubocop:enable Metrics/MethodLength
end
