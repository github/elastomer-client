# frozen_string_literal: true

module Elastomer
  # VersionSupport holds methods that (a) encapsulate version differences; or
  # (b) give an intention-revealing name to a conditional check.
  class VersionSupport

    attr_reader :version

    # version - an Elasticsearch version string e.g., 5.6.6 or 7.17.8
    #
    # Raises ArgumentError if version is unsupported.
    def initialize(version)
      if version < "5.0" || version >= "8.7"
        raise ArgumentError, "Elasticsearch version #{version} is not supported by elastomer-client"
      end

      @version = version
    end

    # Elasticsearch changes some request formats in a non-backward-compatible
    # way. Some tests need to know what version is running to structure requests
    # as expected.

    # Returns true if Elasticsearch version is 7.x or higher.
    def es_version_7_plus?
      version >= "7.0.0"
    end

    # Returns true if Elasticsearch version is 8.x or higher.
    def es_version_8_plus?
      version >= "8.0.0"
    end

    private

    # Internal: Helper to reject arguments that shouldn't be passed because
    # merging them in would defeat the purpose of a compatibility layer.
    def reject_args!(args, *names)
      names.each do |name|
        if args.include?(name.to_s) || args.include?(name.to_sym)
          raise ArgumentError, "Argument '#{name}' is not allowed"
        end
      end
    end

  end
end
