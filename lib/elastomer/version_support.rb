module Elastomer
  class VersionSupport
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # COMPATIBILITY: Return a "text"-type mapping for a field.
    #
    # On ES 2.x, this will be a string field. On ES 5+, it will be a text field.
    def text(**args)
      reject_args!(args, :type, :index)

      if client.es_version_2_x?
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

      if client.es_version_2_x?
        {type: "string", index: "not_analyzed"}.merge(args)
      else
        {type: "keyword"}.merge(args)
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
