require "forwardable"

module Elastomer::Client::RestApiSpec
  class RestApi
    extend Forwardable

    attr_reader :documentation
    attr_reader :methods
    attr_reader :url
    attr_reader :body

    def_delegators :@url,
        :select_parts, :select_params

    def initialize(documentation:, methods:, url:, body: nil)
      @documentation = documentation
      @methods = Array(methods)
      @url = Url.new(url)
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
        from.select {|k,v| @parts_set.include?(k.to_s)}
      end

      def select_params(from:)
        from.select {|k,v| @params_set.include?(k.to_s)}
      end
    end
  end
end
