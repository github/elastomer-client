# frozen_string_literal: true

module ElastomerClient
  class Client
    module ServerlessHelper
      UNSUPPORTED_INDEX_SETTINGS = %w[
        number_of_shards
        number_of_replicas
        auto_expand_replicas
        number_of_routing_shards
        max_terms_count
        queries.cache.enabled
        translog.durability
        translog.sync_interval
      ].freeze

      def filter_params_for_serverless(action, payload)
        raise ArgumentError, "unknown index action: #{action.inspect}" unless action == :create

        settings_key = [:settings, "settings"].find { |key| payload[key].is_a?(Hash) }
        return payload unless settings_key

        payload.merge(settings_key => strip_unsupported_serverless_settings(payload[settings_key]))
      end

      private

      def strip_unsupported_serverless_settings(settings, prefix = nil)
        settings.each_with_object({}) do |(key, value), filtered|
          path = [prefix, key].compact.join(".").delete_prefix("index.")
          next if UNSUPPORTED_INDEX_SETTINGS.include?(path)

          if value.is_a?(Hash) && !value.empty?
            value = strip_unsupported_serverless_settings(value, path)
            next if value.empty?
          end
          filtered[key] = value
        end
      end
    end
  end
end
