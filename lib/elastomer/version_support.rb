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
      if version < "2.3" || version >= "8.0"
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
      es_version_5_plus?
    end

    # COMPATIBILITY: Return a boolean indicating if this version supports the
    # `tasks.get` API - https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html
    def supports_tasks_get?
      es_version_5_plus?
    end

    # COMPATIBILITY: Return a boolean indicating if this version supports the
    # `parent_task_id` param in the tasks API - https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html
    def supports_parent_task_id?
      es_version_5_plus?
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
    #
    # ES5 doesn't accept/ignore ambiguous or unexpected req params any more
    alias :strict_request_params? :es_version_5_plus?

    # COMPATIBILITY
    # ES 5.X supports `delete_by_query` natively again.
    alias :native_delete_by_query? :es_version_5_plus?

    # COMPATIBILITY
    # Internal: VersionSupport maintains dynamically-created lists of acceptable and unacceptable
    # request params by ES version. This just shims that list since those params have leading
    # underscores by default. If we end up with >1 such param, let's make a real thing to handle this.
    def fix_op_type!(params = {})
      if es_version_5_plus? && params.key?(:op_type)
        params[:op_type] = "op_type"
      end
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

    # ES 5.X supports GZip-compressed request bodies, but ES 2.4 doesn't?
    def supports_gzip?
      es_version_5_plus?
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
