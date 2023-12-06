# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::Cluster do

  before do
    @name = "elastomer-template-test"
    @template = $client.template @name
  end

  after do
    @template.delete if @template.exists?
  end

  it "lists templates in the cluster" do
    if $client.version_support.es_version_8_plus?
      @template.create({index_patterns: ["test-elastomer*"]})
    else
      @template.create({template: "test-elastomer*"})
    end
    templates = $client.cluster.templates

    refute_empty templates, "expected to see a template"
  end

  it "creates a template" do
    refute_predicate @template, :exists?, "the template should not exist"

    if $client.version_support.es_version_8_plus?
      template_config = {index_patterns: ["test-elastomer*"]}
    else
      template_config = {template: "test-elastomer*"}
    end

    template_config.merge!({
      settings: { number_of_shards: 3 },
      mappings: mappings_wrapper("book", {
        _source: { enabled: false }
      })
    })

    @template.create(template_config)

    assert_predicate @template, :exists?, " we now have a cluster-test template"

    template = @template.get

    assert_equal [@name], template.keys

    if $client.version_support.es_version_8_plus?
      assert_equal "test-elastomer*", template[@name]["index_patterns"][0]
    else
      assert_equal "test-elastomer*", template[@name]["template"]
    end

    assert_equal "3", template[@name]["settings"]["index"]["number_of_shards"]
  end
end
