# frozen_string_literal: true

module Elastomer
  module Middleware

    # Request middleware that raises an exception if the request body exceeds a
    # `max_request_size`.
    class LimitSize < Faraday::Middleware

      def initialize(app = nil, options = {})
        super(app)
        @max_request_size = options.fetch(:max_request_size)
      end

      attr_reader :max_request_size

      def call(env)
        if body = env[:body]
          if body.is_a?(String) && body.bytesize > max_request_size
            raise ::Elastomer::Client::RequestSizeError,
              "Request of size `#{body.bytesize}` exceeds the maximum requst size: #{max_request_size}"
          end
        end
        @app.call(env)
      end

    end
  end
end

Faraday::Request.register_middleware \
  limit_size: Elastomer::Middleware::LimitSize
