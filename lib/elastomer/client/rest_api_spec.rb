
module Elastomer
  class Client

    # Provides access to the versioned RES API specs for Elasticsearch.
    module RestApiSpec

      #
      # version - the Elasticsearch version String
      #
      # Returns the requested ApiSpec version if available
      def self.api_spec(version)
        classname = "ApiSpecV#{to_class_version(version)}"
        load_api_spec(version) if !self.const_defined? classname
        self.const_get(classname).new
      end

      # Internal:
      #
      def self.load_api_spec(version)
        path = File.expand_path("../rest_api_spec/api_spec_v#{to_class_version(version)}.rb", __FILE__)
        if File.exists? path
          load path
        else
          raise RuntimeError, "Unsupported REST API spec version: #{version}"
        end
      end

      # Internal:
      #
      def self.to_class_version(version)
        version.to_s.split(".").slice(0,2).join("_")
      end

    end
  end
end

require_relative "rest_api_spec/api_spec"
require_relative "rest_api_spec/rest_api"
