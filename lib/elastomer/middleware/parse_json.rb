module Elastomer
  module Middleware

    # Parse response bodies as JSON.
    class ParseJson < Faraday::Middleware
      CONTENT_TYPE = "Content-Type".freeze
      MIME_TYPE    = "application/json".freeze

      def call(environment)
        @app.call(environment).on_complete do |env|
          if process_response?(env)
            env[:body] = parse env[:body]
          end
        end
      end

      # Parse the response body.
      def parse(body)
        MultiJson.load(body) if body.respond_to?(:to_str) && !body.strip.empty?
      rescue StandardError, SyntaxError => e
        raise Faraday::Error::ParsingError, e
      end

      def process_response?(env)
        type = response_type(env)
        type.empty? || type == MIME_TYPE
      end

      def response_type(env)
        type = env[:response_headers][CONTENT_TYPE].to_s
        type = type.split(";", 2).first if type.index(";")
        type
      end
    end
  end
end

Faraday::Response.register_middleware \
  parse_json: Elastomer::Middleware::ParseJson
