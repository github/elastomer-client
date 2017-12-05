module Elastomer
  # VersionSupport holds methods that (a) encapsulate version differences; or
  # (b) give an intention-revealing name to a conditional check.
  class VersionSupport
    attr_reader :version

    # version - an Elasticsearch version string e.g., 2.3.5 or 5.3.0
    #
    # Raises ArgumentError if version is unsupported.
    def initialize(version)
      if version < "2.3" || version >= "5.7"
        raise ArgumentError, "Elasticsearch version #{version} is not supported by elastomer-client"
      end

      @version = version
    end

    # COMPATIBILITY: Return a boolean indicating if this version supports warmers.
    # Warmers were removed in ES 5.0.
    def supports_warmers?
      es_version_2_x?
    end

    # COMPATIBILITY: Return a "text"-type mapping for a field.
    #
    # On ES 2.x, this will be a string field. On ES 5+, it will be a text field.
    def text(**args)
      reject_args!(args, :type, :index)

      if es_version_2_x?
        {type: "string"}.merge(args)
      else
        {type: "text"}.merge(args)
      end
    end

    # COMPATIBILITY: Return a "keyword"-type mapping for a field.
    #
    # On ES 2.x, this will be a string field with not_analyzed=true. On ES 5+,
    # it will be a keyword field.
    def keyword(**args)
      reject_args!(args, :type, :index)

      if es_version_2_x?
        {type: "string", index: "not_analyzed"}.merge(args)
      else
        {type: "keyword"}.merge(args)
      end
    end

    # Elasticsearch 2.0 changed some request formats in a non-backward-compatible
    # way. Some tests need to know what version is running to structure requests
    # as expected.
    #
    # Returns true if Elasticsearch version is 2.x.
    def es_version_2_x?
      version >= "2.0.0" && version <  "3.0.0"
    end

    # Elasticsearch 5.0 changed some request formats in a non-backward-compatible
    # way. Some tests need to know what version is running to structure requests
    # as expected.
    #
    # Returns true if Elasticsearch version is 5.x.
    def es_version_5_x?
      version >= "5.0.0" && version < "6.0.0"
    end

    # Wraps version check and param gen where ES version >= 5.x requires
    # percolator type + field defined in mappings
    def percolator_type
      if es_version_5_x?
        "percolator"
      else
        ".percolator"
      end
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
