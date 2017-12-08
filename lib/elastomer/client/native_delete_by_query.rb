module Elastomer
  class Client
    def native_delete_by_query(query, parameters = {})
      NativeDeleteByQuery.new(self, query, parameters).execute
    end

    class NativeDeleteByQuery
      attr_reader :client, :query, :parameters

      PARAMETERS = %i[
        index
        type
        conflicts
        routing
        scroll_size
        refresh
        wait_for_completion
        wait_for_active_shards
        timeout
      ].to_set.freeze

      def initialize(client, query, parameters)
        unless client.version_support.native_delete_by_query?
          raise IncompatibleVersionException, "Elasticsearch '#{client.version}' does not support _delete_by_query"
        end

        parameters.keys.each do |key|
          unless PARAMETERS.include?(key) || PARAMETERS.include?(key.to_sym)
            raise IllegalArgument, "'#{key}' is not a valid _delete_by_query parameter"
          end
        end

        @client = client
        @query = query
        @parameters = parameters

      end

      def execute
        # TODO: Require index parameter. type is optional.
        response = client.post("/{index}{/type}/_delete_by_query", parameters.merge(body: query))
        response.body
      end
    end
  end
end
