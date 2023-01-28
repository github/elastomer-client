# frozen_string_literal: true

module Elastomer
  # VersionSupport holds methods that (a) encapsulate version differences; or
  # (b) give an intention-revealing name to a conditional check.
  class VersionSupport

    attr_reader :version

    # version - an Elasticsearch version string e.g., 2.3.5 or 5.3.0
    #
    # Raises ArgumentError if version is unsupported.
    def initialize(version)
      if version < "2.3" || version >= "8.7"
        raise ArgumentError, "Elasticsearch version #{version} is not supported by elastomer-client"
      end

      @version = version
    end

    # COMPATIBILITY: Return a boolean indicating if this version supports the
    # `tasks.get` API - https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html
    def supports_tasks_get?
      es_version_5_plus?
    end

    # COMPATIBILITY: return a simple boolean value or legacy {"enabled": true/false}.
    #
    # https://www.elastic.co/guide/en/elasticsearch/reference/5.5/breaking_50_mapping_changes.html#_literal_norms_literal
    def strict_boolean(b)
      if es_version_2_x?
        {enabled: b}
      else
        b
      end
    end

    # COMPATIBILITY: handle _op_type -> op_type request param conversion for put-if-absent bnehavior
    # Returns the (possibly mutated) params hash supplied by the caller.
    #
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#operation-type
    def op_type(params = {})
      if es_version_5_plus? && (params.key?(:_op_type) || params.key?("_op_type"))
        params[:op_type] = params.delete(:_op_type)
      end
      params
    end

    # Elasticsearch changes some request formats in a non-backward-compatible
    # way. Some tests need to know what version is running to structure requests
    # as expected.

    # Returns true if Elasticsearch version is 2.x.
    def es_version_2_x?
      version >= "2.0.0" && version <  "3.0.0"
    end

    # Returns true if Elasticsearch version is 5.x or higher.
    def es_version_5_plus?
      version >= "5.0.0"
    end

    # Returns true if Elasticsearch version is 7.x or higher.
    def es_version_7_plus?
      version >= "7.0.0"
    end

    # Returns true if Elasticsearch version is 8.x or higher.
    def es_version_8_plus?
      version >= "8.0.0"
    end

    # Wraps version check and param gen where ES version >= 5.x requires
    # percolator type + field defined in mappings
    def percolator_type
      if es_version_5_plus?
        "percolator"
      else
        ".percolator"
      end
    end

    # COMPATIBILITY
    # Internal: VersionSupport maintains dynamically-created lists of acceptable and unacceptable
    # request params by ES version. This just shims that list since those params have leading
    # underscores by default. If we end up with >1 such param, let's make a real thing to handle this.
    def fix_op_type!(params = {})
      if es_version_5_plus? && params.key?(:op_type)
        params[:op_type] = "op_type"
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
