require 'simple_uuid'

module Elastomer
  module Middleware

    #
    #
    class OpaqueId < ::Faraday::Middleware
      X_OPAQUE_ID = 'X-Opaque-Id'.freeze

      #
      #
      def call( env )
        uuid = get_uuid.freeze
        env[:request_headers][X_OPAQUE_ID] = uuid

        @app.call(env).on_complete do |renv|
          if uuid != renv[:response_headers][X_OPAQUE_ID]
            raise ::Elastomer::Client::OpaqueIdError, "conflicting request/response 'X-Opaque-Id' headers"
          end
        end
      end

      # Returns a UUID String in guid format.
      def get_uuid
        SimpleUUID::UUID.new.to_guid
      end

    end  # OpaqueId
  end  # Middleware

  # Error raised when a conflict is detected between the UUID sent in the
  # 'X-Opaque-Id' request header and the one received in the response header.
  Client::OpaqueIdError = Class.new Client::Error

end  # Elastomer

Faraday.register_middleware :request,
  :opaque_id => ::Elastomer::Middleware::OpaqueId
