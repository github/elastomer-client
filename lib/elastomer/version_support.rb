module Elastomer
  # VersionSupport holds methods that (a) encapsulate version differences; or
  # (b) give an intention-revealing name to a conditional check.
  class VersionSupport
    COMMON_INDEXING_PARAMETER_NAMES = %i[
      index
      type
      id
      version
      version_type
      op_type
      routing
      parent
      refresh
    ].freeze
    ES_2_X_INDEXING_PARAMETER_NAMES = %i[consistency ttl timestamp].freeze
    ES_5_X_INDEXING_PARAMETER_NAMES = %i[wait_for_active_shards].freeze
    KNOWN_INDEXING_PARAMETER_NAMES =
      (COMMON_INDEXING_PARAMETER_NAMES + ES_2_X_INDEXING_PARAMETER_NAMES + ES_5_X_INDEXING_PARAMETER_NAMES).freeze

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

    # COMPATIBILITY: The Tasks API is evolving quickly; features, and request/response
    # structure can differ across ES versions
    def tasks_new_response_format?
      es_version_5_x?
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

    # COMPATIBILITY
    # ES 2.x reports query parsing exceptions as query_parse_exception whereas
    # ES 5.x reports them as query_shard_exception or parsing_exception
    # depending on when the error occurs.
    #
    # Returns an Array of Strings to match.
    def query_parse_exception
      if es_version_2_x?
        ["query_parsing_exception"]
      else
        ["query_shard_exception", "parsing_exception"]
      end
    end

    # COMPATIBILITY
    # ES 5.X supports `delete_by_query` natively again.
    alias :native_delete_by_query? :es_version_5_x?

    # COMPATIBILITY
    # Return a Hash of indexing request parameters that are valid for this
    # version of Elasticsearch.
    def indexing_directives
      return @indexing_directives if defined?(@indexing_directives)

      @indexing_directives = indexing_parameter_names.each_with_object({}) do |key, h|
        h[key] = "_#{key}"
      end
      @indexing_directives.freeze
    end

    # COMPATIBILITY
    # Return a Hash of indexing request parameters that are known to
    # elastomer-client, but not supported by the current version of
    # Elasticsearch.
    def unsupported_indexing_directives
      return @unsupported_indexing_directives if defined?(@unsupported_indexing_directives)

      unsupported_keys = KNOWN_INDEXING_PARAMETER_NAMES - indexing_parameter_names

      @unsupported_indexing_directives = unsupported_keys.each_with_object({}) do |key, h|
        h[key] = "_#{key}"
      end
      @unsupported_indexing_directives.freeze
    end

    # COMPATIBILITY
    # Return a symbol representing the best supported delete_by_query
    # implementation for this version of Elasticsearch.
    def delete_by_query_method
      if es_version_2_x?
        :app_delete_by_query
      else
        :native_delete_by_query
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

    def indexing_parameter_names
      if es_version_2_x?
        COMMON_INDEXING_PARAMETER_NAMES + ES_2_X_INDEXING_PARAMETER_NAMES
      else
        COMMON_INDEXING_PARAMETER_NAMES + ES_5_X_INDEXING_PARAMETER_NAMES
      end
    end
  end
end
