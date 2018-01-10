
module Elastomer::Client::RestApiSpec

  class ApiSpec

    attr_reader :rest_apis

    def initialize
      @rest_apis ||= {}
      @common_params ||= {}
      @common_params_set = Set.new(@common_params.keys)
    end

    def get(api:)
      rest_apis[api]
    end

    def select_params(api:, params:)
      rest_api = get(api)
      return params if rest_api.nil?
      rest_api.select_params(params)
    end

    def select_parts(api:, params:)
      rest_api = get(api)
      return params if rest_api.nil?
      rest_api.select_parts(params)
    end

    def select_common_params(params:)
      params.select {|k,v| @common_params_set.include?(k.to_s)}
    end
  end
end
