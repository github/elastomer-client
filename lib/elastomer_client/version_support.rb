# frozen_string_literal: true

require "rubygems/version"

module ElastomerClient
  class VersionSupport

    attr_reader :version

    # version - an Elasticsearch version string e.g., 5.6.6 or 8.7.0
    #
    # Raises ArgumentError if version is unsupported.
    def initialize(version)
      comparable_version = Gem::Version.new(version)
      if comparable_version < Gem::Version.new("5.0") || comparable_version >= Gem::Version.new("10.0")
        raise ArgumentError, "Elasticsearch version #{version} is not supported by elastomer-client"
      end

      @version = version
    end

    # Returns true if Elasticsearch version is 8.x or higher.
    def es_version_8_plus?
      version >= "8.0.0"
    end

    def es_version_9_plus?
      Gem::Version.new(version) >= Gem::Version.new("9.0")
    end
  end
end
