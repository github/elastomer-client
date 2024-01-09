module ElastomerClient
  module Middleware
    class MockResponse < Faraday::Middleware
      def initialize(app, &block)
        super(app)
        @response_block = block
      end

      def call(env)
        env.clear_body if env.needs_body?

        env.status = 200
        env.response_headers = ::Faraday::Utils::Headers.new
        env.response_headers["Fake"] = "yes"
        env.response = ::Faraday::Response.new

        @response_block&.call(env)

        env.response.finish(env) unless env.parallel?

        env.response
      end
    end
  end
end

Faraday::Request.register_middleware \
  mock_response: ElastomerClient::Middleware::MockResponse