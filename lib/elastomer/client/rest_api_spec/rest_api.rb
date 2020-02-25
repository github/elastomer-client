require "forwardable"

module Elastomer::Client::RestApiSpec
  class RestApi
    extend Forwardable

    attr_reader :documentation
    attr_reader :methods
    attr_reader :url
    attr_reader :body

    def_delegators :@url,
        :select_parts, :select_params, :valid_part?, :valid_param?

    def initialize(documentation:, methods:, url:, body: nil)
      @documentation = documentation
      @methods = Array(methods)
      @url = Url.new(**url)
      @body = body
    end

    def body?
      !body.nil?
    end

    class Url
      attr_reader :path
      attr_reader :paths
      attr_reader :parts
      attr_reader :params

      def initialize(path:, paths: [], parts: {}, params: {})
        @path = path
        @paths = Array(paths)
        @parts = parts
        @params = params

        @parts_set  = Set.new(@parts.keys)
        @params_set = Set.new(@params.keys)
      end

      def select_parts(from:)
        from.select {|k,v| valid_part?(k)}
      end

      def valid_part?(part)
        @parts_set.include?(part.to_s)
      end

      def select_params(from:)
        from.select {|k,v| valid_param?(k)}
      end

      def valid_param?(param)
        @params_set.include?(param.to_s)
      end
    end
  end
end
