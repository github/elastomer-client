module Elastomer
  module Middleware
    # Request middleware that encodes the body as JSON.
    #
    # Processes only requests with matching Content-type or those without a type.
    # If a request doesn't have a type but has a body, it sets the Content-type
    # to JSON MIME-type.
    #
    # Doesn't try to encode bodies that already are in string form.
    class EncodeJson < Faraday::Middleware
      CONTENT_TYPE = "Content-Type".freeze
      MIME_TYPE    = "application/json".freeze

      def call(env)
        match_content_type(env) do |data|
          env[:body] = encode data
        end
        @app.call env
      end

      def encode(data)
        MultiJson.dump data
      end

      def match_content_type(env)
        add_content_type!(env)
        if process_request?(env)
          yield env[:body] unless env[:body].respond_to?(:to_str)
        end
      end

      def process_request?(env)
        type = request_type(env)
        has_body?(env) && (type.empty? || type == MIME_TYPE)
      end

      def has_body?(env)
        (body = env[:body]) && !(body.respond_to?(:to_str) && body.empty?)
      end

      def request_type(env)
        type = env[:request_headers][CONTENT_TYPE].to_s
        type = type.split(";", 2).first if type.index(";")
        type
      end

      def add_content_type!(env)
        method = env[:method]
        if method == :put || method == :post || has_body?(env)
          env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
        end
      end
    end
  end
end

Faraday::Request.register_middleware \
  encode_json: Elastomer::Middleware::EncodeJson
