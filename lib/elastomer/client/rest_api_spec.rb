# typed: true
# frozen_string_literal: true

module Elastomer
  class Client

    # Provides access to the versioned REST API specs for Elasticsearch.
    module RestApiSpec

      # Returns an ApiSpec instance for the given Elasticsearcion version. This
      # method will load the ApiSpec version class if it has not already been
      # defined. This prevents bloat by only loading the version specs that are
      # needed.
      #
      # Because of this lazy loading, this method is _not_ thread safe.
      #
      # version - the Elasticsearch version String
      #
      # Returns the requested ApiSpec version if available
      def self.api_spec(version)
        classname = "ApiSpecV#{to_class_version(version)}"
        load_api_spec(version) if !self.const_defined? classname
        self.const_get(classname).new
      end

      # Internal: Load the specific ApiSpec version class for the given version.
      def self.load_api_spec(version)
        path = File.expand_path("../rest_api_spec/api_spec_v#{to_class_version(version)}.rb", __FILE__)
        if File.exist? path
          load path
        else
          raise RuntimeError, "Unsupported REST API spec version: #{version}"
        end
      end

      # Internal: Convert a dotted version String into an underscore format
      # suitable for use in Ruby class names.
      def self.to_class_version(version)
        version.to_s.split(".").slice(0, 2).join("_")
      end
    end
  end
end

require_relative "rest_api_spec/api_spec"
require_relative "rest_api_spec/rest_api"
