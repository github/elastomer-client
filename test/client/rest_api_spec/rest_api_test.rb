# typed: true
# frozen_string_literal: true

require_relative "../../test_helper"

describe Elastomer::Client::RestApiSpec::RestApi do
  before do
    @rest_api = Elastomer::Client::RestApiSpec::RestApi.new \
        documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-state.html",
        methods: ["GET"],
        body: nil,
        url: {
          path: "/_cluster/state",
          paths: ["/_cluster/state", "/_cluster/state/{metric}", "/_cluster/state/{metric}/{index}"],
          parts: {
            "index" => {"type"=>"list", "description"=>"A comma-separated list of index names; use `_all` or empty string to perform the operation on all indices"},
            "metric" => {"type"=>"list", "options"=>["_all", "blocks", "metadata", "nodes", "routing_table", "routing_nodes", "master_node", "version"], "description"=>"Limit the information returned to the specified metrics"},
          },
          params: {
            "local" => {"type"=>"boolean", "description"=>"Return local information, do not retrieve the state from master node (default: false)"},
            "master_timeout" => {"type"=>"time", "description"=>"Specify timeout for connection to master"},
            "flat_settings" => {"type"=>"boolean", "description"=>"Return settings in flat format (default: false)"},
            "ignore_unavailable" => {"type"=>"boolean", "description"=>"Whether specified concrete indices should be ignored when unavailable (missing or closed)"},
            "allow_no_indices" => {"type"=>"boolean", "description"=>"Whether to ignore if a wildcard indices expression resolves into no concrete indices. (This includes `_all` string or when no indices have been specified)"},
            "expand_wildcards" => {"type"=>"enum", "options"=>["open", "closed", "none", "all"], "default"=>"open", "description"=>"Whether to expand wildcard expression to concrete indices that are open, closed or both."},
          }
        }
  end

  it "selects valid path parts" do
    hash = {
      :index => "test",
      "metric" => "os",
      :nope => "not selected"
    }
    selected = @rest_api.select_parts(from: hash)

    refute selected.key?(:nope)
    assert selected.key?(:index)
    assert selected.key?("metric")
  end

  it "identifies valid parts" do
    assert @rest_api.valid_part? :index
    assert @rest_api.valid_part? "metric"
    refute @rest_api.valid_part? :nope
  end

  it "selects valid request params" do
    hash = {
      :local => true,
      "flat_settings" => true,
      :expand_wildcards => "all",
      :nope => "not selected"
    }
    selected = @rest_api.select_params(from: hash)

    refute selected.key?(:nope)
    assert selected.key?(:local)
    assert selected.key?("flat_settings")
    assert selected.key?(:expand_wildcards)
  end

  it "identifies valid params" do
    assert @rest_api.valid_param? :local
    assert @rest_api.valid_param? "flat_settings"
    refute @rest_api.valid_param? :nope
  end

  it "accesses the documentation url" do
    assert_equal "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-state.html", @rest_api.documentation
  end

  it "exposes the HTTP methods as an Array" do
    assert_equal %w[GET], @rest_api.methods
  end

  it "accesses the body settings" do
    assert_nil @rest_api.body
  end

  describe "accessing the url" do
    it "accesses the path" do
      assert_equal "/_cluster/state", @rest_api.url.path
    end

    it "exposes the paths as an Array" do
      assert_equal %w[/_cluster/state /_cluster/state/{metric} /_cluster/state/{metric}/{index}], @rest_api.url.paths
    end

    it "accesses the path parts" do
      assert_equal %w[index metric], @rest_api.url.parts.keys
    end

    it "accesses the request params" do
      assert_equal %w[local master_timeout flat_settings ignore_unavailable allow_no_indices expand_wildcards], @rest_api.url.params.keys
    end
  end
end
