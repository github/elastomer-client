require File.expand_path("../../test_helper", __FILE__)

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
    assert !@index.exists?, "the index should not yet exist"
  end

  it "determines if an index exists with .exist?" do
    assert !@index.exist?, "the index should not yet exist"
  end

  describe "when creating an index" do
    it "creates an index" do
      @index.create({})
      assert @index.exists?, "the index should now exist"
    end

    it "creates an index with settings" do
      @index.create :settings => { :number_of_shards => 3, :number_of_replicas => 0 }
      settings = @index.get_settings[@name]["settings"]

      # COMPATIBILITY
      # ES 1.0 changed the default return format of index settings to always
      # expand nested properties, e.g.
      # {"index.number_of_replicas": "1"} changed to
      # {"index": {"number_of_replicas":"1"}}

      # To support both versions, we check for either return format.
      value = settings["index.number_of_shards"] ||
              settings["index"]["number_of_shards"]
      assert_equal "3", value
      value = settings["index.number_of_replicas"] ||
              settings["index"]["number_of_replicas"]
      assert_equal "0", value
    end

    it "creates an index with settings with .settings" do
      @index.create :settings => { :number_of_shards => 3, :number_of_replicas => 0 }
      settings = @index.settings[@name]["settings"]

      # COMPATIBILITY
      # ES 1.0 changed the default return format of index settings to always
      # expand nested properties, e.g.
      # {"index.number_of_replicas": "1"} changed to
      # {"index": {"number_of_replicas":"1"}}

      # To support both versions, we check for either return format.
      value = settings["index.number_of_shards"] ||
              settings["index"]["number_of_shards"]
      assert_equal "3", value
      value = settings["index.number_of_replicas"] ||
              settings["index"]["number_of_replicas"]
      assert_equal "0", value
    end

    it "adds mappings for document types" do
      @index.create(
        :settings => { :number_of_shards => 1, :number_of_replicas => 0 },
        :mappings => {
          :doco => {
            :_source => { :enabled => false },
            :_all    => { :enabled => false },
            :properties => {
              :title  => { :type => "string", :analyzer => "standard" },
              :author => { :type => "string", :index => "not_analyzed" }
            }
          }
        }
      )

      assert @index.exists?, "the index should now exist"
      assert_mapping_exists @index.get_mapping[@name], "doco"
    end

    it "adds mappings for document types with .mapping" do
      @index.create(
        :settings => { :number_of_shards => 1, :number_of_replicas => 0 },
        :mappings => {
          :doco => {
            :_source => { :enabled => false },
            :_all    => { :enabled => false },
            :properties => {
              :title  => { :type => "string", :analyzer => "standard" },
              :author => { :type => "string", :index => "not_analyzed" }
            }
          }
        }
      )

      assert @index.exists?, "the index should now exist"
      assert_mapping_exists @index.mapping[@name], "doco"
    end
  end

  it "updates index settings" do
    @index.create :settings => { :number_of_shards => 1, :number_of_replicas => 0 }

    @index.update_settings "index.number_of_replicas" => 1
    settings = @index.settings[@name]["settings"]

    # COMPATIBILITY
    # ES 1.0 changed the default return format of index settings to always
    # expand nested properties, e.g.
    # {"index.number_of_replicas": "1"} changed to
    # {"index": {"number_of_replicas":"1"}}

    # To support both versions, we check for either return format.
    value = settings["index.number_of_replicas"] ||
            settings["index"]["number_of_replicas"]
    assert_equal "1", value
  end

  it "updates document mappings" do
    unless es_version_supports_update_mapping_with__all_disabled?
      skip "Mapping Update API is broken in this ES version."
    end

    @index.create(
      :mappings => {
        :doco => {
          :_source => { :enabled => false },
          :_all    => { :enabled => false },
          :properties => {:title  => { :type => "string", :analyzer => "standard" }}
        }
      }
    )

    assert_property_exists @index.mapping[@name], "doco", "title"

    @index.update_mapping "doco", { :doco => { :properties => {
      :author => { :type => "string", :index => "not_analyzed" }
    }}}

    assert_property_exists @index.mapping[@name], "doco", "author"
    assert_property_exists @index.mapping[@name], "doco", "title"

    @index.update_mapping "mux_mool", { :mux_mool => { :properties => {
      :song => { :type => "string", :index => "not_analyzed" }
    }}}

    assert_property_exists @index.mapping[@name], "mux_mool", "song"
  end

  it "updates document mappings with .put_mapping" do
    unless es_version_supports_update_mapping_with__all_disabled?
      skip "Mapping Update API is broken in this ES version."
    end

    @index.create(
      :mappings => {
        :doco => {
          :_source => { :enabled => false },
          :_all    => { :enabled => false },
          :properties => {:title  => { :type => "string", :analyzer => "standard" }}
        }
      }
    )

    assert_property_exists @index.mapping[@name], "doco", "title"

    @index.put_mapping "doco", { :doco => { :properties => {
      :author => { :type => "string", :index => "not_analyzed" }
    }}}

    assert_property_exists @index.mapping[@name], "doco", "author"
    assert_property_exists @index.mapping[@name], "doco", "title"

    @index.put_mapping "mux_mool", { :mux_mool => { :properties => {
      :song => { :type => "string", :index => "not_analyzed" }
    }}}

    assert_property_exists @index.mapping[@name], "mux_mool", "song"
  end

  it "deletes document mappings" do
    @index.create(
      :mappings => {
        :doco => {
          :_source => { :enabled => false },
          :_all    => { :enabled => false },
          :properties => {:title  => { :type => "string", :analyzer => "standard" }}
        }
      }
    )
    assert_mapping_exists @index.mapping[@name], "doco"

    response = @index.delete_mapping "doco"
    assert_acknowledged response

    mapping = @index.get_mapping
    mapping = mapping[@name] if mapping.key? @name
    mapping = mapping["mappings"] if mapping.key? "mappings"

    assert_empty mapping, "no mappings are present"
  end

  it "lists all aliases to the index" do
    @index.create(nil)

    if es_version_always_returns_aliases?
      assert_equal({@name => {"aliases" => {}}}, @index.get_aliases)
    else
      assert_equal({@name => {}}, @index.get_aliases)
    end

    $client.cluster.update_aliases :add => {:index => @name, :alias => "foofaloo"}
    assert_equal({@name => {"aliases" => {"foofaloo" => {}}}}, @index.get_aliases)

    if es_version_1_x?
      assert_equal({@name => {"aliases" => {"foofaloo" => {}}}}, @index.get_alias("f*"))
      assert_equal({}, @index.get_alias("r*"))
    end
  end

  if es_version_1_x?
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
  end

  # COMPATIBILITY ES 1.x removed English stopwords from the default analyzers,
  # so create a custom one with the English stopwords added.
  if es_version_1_x?
    it "analyzes text and returns tokens" do
      tokens = @index.analyze "Just a few words to analyze.", :analyzer => "standard", :index => nil
      tokens = tokens["tokens"].map { |h| h["token"] }
      assert_equal %w[just a few words to analyze], tokens

      @index.create(
        :settings => {
          :number_of_shards => 1,
          :number_of_replicas => 0,
          :analysis => {
            :analyzer => {
              :english_standard => {
                :type => :standard,
                :stopwords => "_english_"
              }
            }
          }
        }
      )
      wait_for_index(@name)

      tokens = @index.analyze "Just a few words to analyze.", :analyzer => "english_standard"
      tokens = tokens["tokens"].map { |h| h["token"] }
      assert_equal %w[just few words analyze], tokens
    end
  else
    it "analyzes text and returns tokens" do
      tokens = @index.analyze "Just a few words to analyze.", :index => nil
      tokens = tokens["tokens"].map { |h| h["token"] }
      assert_equal %w[just few words analyze], tokens

      tokens = @index.analyze "Just a few words to analyze.", :analyzer => "simple", :index => nil
      tokens = tokens["tokens"].map { |h| h["token"] }
      assert_equal %w[just a few words to analyze], tokens
    end
  end

  describe "when an index exists" do
    before do
      @index.create(
        :settings => { :number_of_shards => 1, :number_of_replicas => 0 },
        :mappings => {
          :doco => {
            :_source => { :enabled => false },
            :_all    => { :enabled => false },
            :properties => {
              :title   => { :type => "string", :analyzer => "standard" },
              :author  => { :type => "string", :index => "not_analyzed" },
              :suggest => {
                :type            => "completion",
                :index_analyzer  => "simple",
                :search_analyzer => "simple",
                :payloads        => false
              }
            }
          }
        }
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

    it "optimizes" do
      response = @index.optimize
      assert_equal 0, response["_shards"]["failed"]
    end

    # COMPATIBILITY ES 1.2 removed support for the gateway snapshot API.
    if es_version_supports_gateway_snapshots?
      it "snapshots" do
        response = @index.snapshot
        assert_equal 0, response["_shards"]["failed"]
      end
    end

    if es_version_1_x?
      it "recovery" do
        response = @index.recovery
        assert_includes response, "elastomer-index-test"
      end
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

    it "gets status" do
      response = @index.status
      assert_includes response["indices"], "elastomer-index-test"
    end

    it "gets segments" do
      @index.docs("foo").index("foo" => "bar")
      response = @index.segments
      assert_includes response["indices"], "elastomer-index-test"
    end

    it "deletes by query" do
      @index.docs("foo").index("foo" => "bar")
      @index.refresh
      r = @index.delete_by_query(:q => "*")
      assert_equal({
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
        }
      }, r["_indices"])
    end

    it "creates a Percolator" do
      id = "1"
      percolator = @index.percolator id
      assert_equal id, percolator.id
    end

    it "performs multi percolate queries" do
      @index.docs.index \
        :_id    => 1,
        :_type  => "doco",
        :title  => "the author of logging",
        :author => "pea53"

      @index.docs.index \
        :_id    => 2,
        :_type  => "doco",
        :title  => "the author of rubber-band",
        :author => "grantr"

      @index.percolator("1").create :query => { :match_all => { } }
      @index.percolator("2").create :query => { :match => { :author => "pea53" } }

      h = @index.multi_percolate(:type => "doco") do |m|
        m.percolate :author => "pea53"
        m.percolate :author => "grantr"
        m.count({}, { :author => "grantr" })
      end

      response1, response2, response3 = h["responses"]
      assert_equal ["1", "2"], response1["matches"].map { |match| match["_id"] }.sort
      assert_equal ["1"], response2["matches"].map { |match| match["_id"] }.sort
      assert_equal 1, response3["total"]
    end

    it "performs suggestion queries" do
      @index.docs.index \
        :_id     => 1,
        :_type   => "doco",
        :title   => "the magnificent",
        :author  => "greg",
        :suggest => {:input => %w[Greg greg], :output => "Greg", :weight => 2}

      @index.docs.index \
        :_id    => 2,
        :_type  => "doco",
        :title  => "the author of rubber-band",
        :author => "grant",
        :suggest => {:input => %w[Grant grant], :output => "Grant", :weight => 1}

      @index.refresh
      response = @index.suggest({:name => {:text => "gr", :completion => {:field => :suggest}}})

      assert response.key?("name")
      hash = response["name"].first
      assert_equal "gr", hash["text"]

      options = hash["options"]
      assert_equal 2, options.length
      assert_equal "Greg", options.first["text"]
      assert_equal "Grant", options.last["text"]
    end
  end
end
