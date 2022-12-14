# frozen_string_literal: true

require_relative "../../test_helper"

describe Elastomer::Client::RestApiSpec::ApiSpec do
  before do
    @api_spec = Elastomer::Client::RestApiSpec.api_spec("5.6.4")
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
    assert_raises(Elastomer::Client::IllegalArgument, "'nope' is not a valid parameter for the 'search' API") {
      params = {q: "*:*", pretty: true, "nope": false}
      @api_spec.validate_params!(api: "search", params: params)
    }
  end
end
