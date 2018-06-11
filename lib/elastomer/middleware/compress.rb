# frozen_string_literal: true
require "stringio"

module Elastomer
  module Middleware
    # Request middleware that compresses request bodies with GZip for supported
    # versions of Elasticsearch.
    #
    # It will only compress when there is a request body that is a String. This
    # middleware should be inserted after JSON serialization.
    class Compress < Faraday::Middleware
      CONTENT_ENCODING = "Content-Encoding"
      GZIP = "gzip"

      attr_reader :compression

      # options - The Hash of "keyword" arguments.
      #           :compression - the compression level (0-9, default Zlib::DEFAULT_COMPRESSION)
      def initialize(app, options = {})
        super(app)
        @compression = options[:compression] || Zlib::DEFAULT_COMPRESSION
      end

      def call(env)
        if body = env[:body]
          if body.is_a?(String)
            output = StringIO.new
            output.set_encoding("BINARY")
            gz = Zlib::GzipWriter.new(output, compression, Zlib::DEFAULT_STRATEGY)
            gz.write(env[:body])
            gz.close
            env[:body] = output.string
            env[:request_headers][CONTENT_ENCODING] = GZIP
          end
        end

        @app.call(env)
      end
    end
  end
end

Faraday::Request.register_middleware(elastomer_compress: ::Elastomer::Middleware::Compress)
