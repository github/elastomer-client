
module Elastomer::Client::RestApiSpec

  # This is the superclass for the version specific API Spec classes that will
  # be generated using the `script/generate-rest-api-spec` script. Each version
  # of Elasticsarch we support will have it's own ApiSpec class that will
  # validate the API request aprams for that particular version.
  class ApiSpec

    attr_reader :rest_apis
    attr_reader :common_params

    def initialize
      @rest_apis ||= {}
      @common_params ||= {}
      @common_params_set = Set.new(@common_params.keys)
    end

    # Given an API descriptor name and a set of request parameters, select those
    # params that are accepted by the API endpoint.
    #
    # api  - the api descriptor name as a String
    # from - the Hash containing the request params
    #
    # Returns a new Hash containing the valid params for the api
    def select_params(api:, from:)
      rest_api = get(api)
      return from if rest_api.nil?
      rest_api.select_params(from: from)
    end

    # Given an API descriptor name and a single request parameter, returns
    # `true` if the parameter is valid for the given API. This method always
    # returns `true` if the API is unknown.
    #
    # api   - the api descriptor name as a String
    # param - the request parameter name as a String
    #
    # Returns `true` if the param is valid for the API.
    def valid_param?(api:, param:)
      rest_api = get(api)
      return true if rest_api.nil?
      rest_api.valid_param?(param)
    end

    # Given an API descriptor name and a set of request path parts, select those
    # parts that are accepted by the API endpoint.
    #
    # api  - the api descriptor name as a String
    # from - the Hash containing the path parts
    #
    # Returns a new Hash containing the valid path parts for the api
    def select_parts(api:, from:)
      rest_api = get(api)
      return from if rest_api.nil?
      rest_api.select_parts(from: from)
    end

    # Given an API descriptor name and a single path part, returns `true` if the
    # path part is valid for the given API. This method always returns `true` if
    # the API is unknown.
    #
    # api  - the api descriptor name as a String
    # part - the path part name as a String
    #
    # Returns `true` if the path part is valid for the API.
    def valid_part?(api:, part:)
      rest_api = get(api)
      return true if rest_api.nil?
      rest_api.valid_part?(part)
    end

    # Select the common request parameters from the given params.
    #
    # from - the Hash containing the request params
    #
    # Returns a new Hash containing the valid common request params
    def select_common_params(from:)
      return from if @common_params.empty?
      from.select {|k,v| @common_params_set.include?(k.to_s)}
    end

    # Internal: Retrieve the `RestApi` descriptor for the given named `api`. If
    # an unkonwn `api` is passed in, then `nil` is returned.
    #
    # api - the api descriptor name as a String
    #
    # Returns a RestApi instance or nil.
    def get(api)
      rest_apis[api]
    end
  end
end
