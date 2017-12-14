require "active_support/notifications"
require "securerandom"
require "elastomer/client"

module Elastomer

  # So you want to get notifications from your Elasticsearch client? Well,
  # you've come to the right place!
  #
  #   require 'elastomer/notifications'
  #
  # Requiring this module will add ActiveSupport notifications to all
  # Elasticsearch requests. To subscribe to those requests ...
  #
  #   ActiveSupport::Notifications.subscribe('request.client.elastomer') do |name, start_time, end_time, _, payload|
  #     duration = end_time - start_time
  #     $stderr.puts '[%s] %s %s (%.3f)' % [payload[:status], payload[:index], payload[:action], duration]
  #   end
  #
  # The payload contains the following bits of information:
  #
  # * :index  - index name (if any)
  # * :type   - document type (if any)
  # * :action - the action being performed
  # * :url    - request URL
  # * :method - request method (:head, :get, :put, :post, :delete)
  # * :status - response status code
  #
  # If you want to use your own notifications service then you will need to
  # let Elastomer know by setting the `service` here in the Notifications
  # module. The service should adhere to the ActiveSupport::Notifications
  # specification.
  #
  #   Elastomer::Notifications.service = your_own_service
  #
  module Notifications

    class << self
      attr_accessor :service
    end

    # The name to subscribe to for notifications
    NAME = "request.client.elastomer".freeze

    # Internal: Execute the given block and provide instrumentation info to
    # subscribers. The name we use for subscriptions is
    # `request.client.elastomer` and a supplemental payload is provided with
    # more information about the specific Elasticsearch request.
    #
    # path   - The full request path as a String
    # body   - The request body as a String or `nil`
    # params - The request params Hash
    # block  - The block that will be instrumented
    #
    # Returns the response from the block
    def instrument( path, body, params )
      payload = {
        :index        => params[:index],
        :type         => params[:type],
        :action       => params[:action],
        :context      => params[:context],
        :retries      => params[:retries],
        :request_body => body,
        :body         => body   # for backwards compatibility
      }

      ::Elastomer::Notifications.service.instrument(NAME, payload) do
        response = yield
        payload[:url]           = response.env[:url]
        payload[:method]        = response.env[:method]
        payload[:status]        = response.status
        payload[:response_body] = response.body
        response
      end
    end
  end

  # use ActiveSupport::Notifications as the default instrumentation service
  Notifications.service = ActiveSupport::Notifications

  # inject our instrument method into the Client class
  class Client
    remove_method :instrument
    include ::Elastomer::Notifications
  end
end
