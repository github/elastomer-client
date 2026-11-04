# frozen_string_literal: true

require_relative "../../test_helper"

describe ElastomerClient::Client::RestApiSpec::ApiSpec do
  before do
    @api_spec = ElastomerClient::Client::RestApiSpec.api_spec("5.6.4")
  end

  it "selects valid path parts" do
    parts  = {:index => "test", "type" => "doc", :foo => "bar"}
    result = @api_spec.select_parts(api: "search", from: parts)

    assert_equal({:index => "test", "type" => "doc"}, result)
  end

  it "identifies valid path parts" do
    assert @api_spec.valid_part?(api: "search", part: "index")
    assert @api_spec.valid_part?(api: "search", part: :type)
    refute @api_spec.valid_part?(api: "search", part: :id)
  end

  it "selects valid request params" do
    params = {:explain => true, "preference" => "local", :nope => "invalid"}
    result = @api_spec.select_params(api: "search", from: params)

    assert_equal({:explain => true, "preference" => "local"}, result)
  end

  it "identifies valid request params" do
    assert @api_spec.valid_param?(api: "search", param: "explain")
    assert @api_spec.valid_param?(api: "search", param: :preference)
    assert @api_spec.valid_param?(api: "search", param: :routing)
    refute @api_spec.valid_param?(api: "search", param: "pretty")
  end

  it "selects common request params" do
    params = {:pretty => true, "human" => true, :nope => "invalid"}
    result = @api_spec.select_common_params(from: params)

    assert_equal({:pretty => true, "human" => true}, result)
  end

  it "identifies common request params" do
    assert @api_spec.valid_common_param?("pretty")
    assert @api_spec.valid_common_param?(:human)
    assert @api_spec.valid_common_param?(:source)
    refute @api_spec.valid_common_param?("nope")
  end

  it "validates request params" do
    params = {q: "*:*", pretty: true, "nope": false}
    assert_raises(ElastomerClient::Client::IllegalArgument, "'nope' is not a valid parameter for the 'search' API") {
      @api_spec.validate_params!(api: "search", params:)
    }
  end

  it "selects the REST API spec for each supported Elasticsearch major version" do
    {"8.18.0" => "8_18", "8.19.3" => "8_19", "9.0.0" => "9_0"}.each do |version, class_version|
      client = ElastomerClient::Client.new(es_version: version)

      assert_equal "ElastomerClient::Client::RestApiSpec::ApiSpecV#{class_version}", client.api_spec.class.name
    end
  end

  it "keeps removed alias parameters in ES8 but excludes them from ES9" do
    eight = ElastomerClient::Client::RestApiSpec.api_spec("8.19.3")
    nine = ElastomerClient::Client::RestApiSpec.api_spec("9.0.0")

    %w[indices.get_alias indices.exists_alias cat.aliases].each do |api|
      assert eight.valid_param?(api:, param: :local)
      refute nine.valid_param?(api:, param: :local)
      assert_empty(nine.select_params(api:, from: {local: true}))
      assert_raises(ElastomerClient::Client::IllegalArgument) {
        nine.validate_params!(api:, params: {local: true})
      }
    end
  end

  it "keeps removed endpoints in ES8 but excludes them from ES9" do
    eight = ElastomerClient::Client::RestApiSpec.api_spec("8.19.3")
    nine = ElastomerClient::Client::RestApiSpec.api_spec("9.0.0")

    %w[indices.unfreeze knn_search].each do |api|
      refute_nil eight.get(api)
      assert_nil nine.get(api)
    end
  end
end
