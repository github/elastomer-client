# frozen_string_literal: true
require "stringio"
require "zlib"

module Elastomer
  module Middleware
    # Request middleware that compresses request bodies with GZip for supported
    # versions of Elasticsearch.
    #
    # It will only compress when there is a request body that is a String. This
    # middleware should be inserted after JSON serialization.
    #
    # The check for whether or not this is supported is lazy because you can't
    # get a VersionSupport without fetching the ES version from the server,
    # which requires a connection.
    class Compress < Faraday::Middleware
      CONTENT_ENCODING = "Content-Encoding"
      GZIP = "gzip"

      attr_reader :lazy_supports_gzip

      # options - The Hash of "keyword" arguments.
      #           :lazy_supports_gzip - a lambda that returns true or false.
      def initialize(app, options = {})
        super(app)
        @lazy_supports_gzip = options.fetch(:lazy_supports_gzip)
      end

      def es_supports_gzip?
        @es_supports_gzip ||= lazy_supports_gzip.call
      end

      def call(env)
        if body = env[:body] && es_supports_gzip?
          if body.is_a?(String)
            output = StringIO.new
            output.set_encoding("BINARY")
            gz = Zlib::GzipWriter.new(output, Zlib::DEFAULT_COMPRESSION, Zlib::DEFAULT_STRATEGY)
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
