require File.expand_path("../../test_helper", __FILE__)

describe Elastomer::Client::Scroller do

  before do
    @name  = "elastomer-scroller-test"
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { "index.number_of_shards" => 1, "index.number_of_replicas" => 0 },
        :mappings => {
          :tweet => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :message => { :type => "string", :analyzer => "standard" },
              :author  => { :type => "string", :index => "not_analyzed" },
              :sorter  => { :type => "integer" }
            }
          },
          :book => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => { :type => "string", :analyzer => "standard" },
              :author => { :type => "string", :index => "not_analyzed" },
              :sorter  => { :type => "integer" }
            }
          }
        }

      wait_for_index(@name)
      populate!
    end
  end

  after do
    @index.delete if @index.exists?
  end

  it "scans over all documents in an index" do
    scan = @index.scan '{"query":{"match_all":{}}}', :size => 10

    counts = {"tweet" => 0, "book" => 0}
    scan.each_document { |h| counts[h["_type"]] += 1 }

    assert_equal 50, counts["tweet"]
    assert_equal 25, counts["book"]
  end

  it "restricts the scan to a single document type" do
    scan = @index.scan '{"query":{"match_all":{}}}', :type => "book"

    counts = {"tweet" => 0, "book" => 0}
    scan.each_document { |h| counts[h["_type"]] += 1 }

    assert_equal 0, counts["tweet"]
    assert_equal 25, counts["book"]
  end

  it "limits results by query" do
    scan = @index.scan :query => { :bool => { :should => [
      {:match => {:author => "pea53"}},
      {:match => {:title => "17"}}
    ]}}

    counts = {"tweet" => 0, "book" => 0}
    scan.each_document { |h| counts[h["_type"]] += 1 }

    assert_equal 50, counts["tweet"]
    assert_equal 1, counts["book"]
  end

  it "scrolls and sorts over all documents" do
    scroll = @index.scroll({
      :query => {:match_all => {}},
      :sort => {:sorter => {:order => :asc}}
    }, :type => "tweet")

    tweets = []
    scroll.each_document { |h| tweets << h["_id"].to_i }

    expected = (0...50).to_a.reverse
    assert_equal expected, tweets
  end

  it "propagates URL query strings" do
    scan = @index.scan(nil, { :q => "author:pea53 || title:17" })

    counts = {"tweet" => 0, "book" => 0}
    scan.each_document { |h| counts[h["_type"]] += 1 }

    assert_equal 50, counts["tweet"]
    assert_equal 1, counts["book"]
  end

  def populate!
    h = @index.bulk do |b|
      50.times { |num|
        b.index %Q({"author":"pea53","message":"this is tweet number #{num}","sorter":#{50-num}}), :_id => num, :_type => "tweet"
      }
    end
    h["items"].each {|item| assert_bulk_index(item) }

    h = @index.bulk do |b|
      25.times { |num|
        b.index %Q({"author":"Pratchett","title":"DiscWorld Book #{num}","sorter":#{25-num}}), :_id => num, :_type => "book"
      }
    end
    h["items"].each {|item| assert_bulk_index(item) }
  end
end
