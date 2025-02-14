# frozen_string_literal: true

require_relative "rest_api_spec/api_spec"
require_relative "rest_api_spec/rest_api"

# These are all eager loaded, which may be wasteful for unused versions but is
# preferable for copy-on-write and to avoid loading at runtime.

require_relative "rest_api_spec/api_spec_v5_6"
require_relative "rest_api_spec/api_spec_v8_7"

module ElastomerClient
  class Client

    # Provides access to the versioned REST API specs for Elasticsearch.
    module RestApiSpec
      API_SPECS = {
        "5_6"  => ApiSpecV5_6.new,
        "8_7"  => ApiSpecV8_7.new,
      }.freeze

      # Returns an ApiSpec instance for the given Elasticsearcion version.
      #
      # version - the Elasticsearch version String
      #
      # Returns the requested ApiSpec version if available
      def self.api_spec(version)
        short_version = version.to_s.split(".").slice(0, 2).join("_")
        API_SPECS.fetch(short_version) do
          raise RuntimeError, "Unsupported REST API spec version: #{version}"
        end
      end
    end
  end
end
