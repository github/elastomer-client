require 'active_support/notifications'
require 'securerandom'

require File.expand_path('../client', __FILE__) unless defined? Elastomer::Client

module Elastomer

  # So you want to get notifications from your ElasticSearch client? Well,
  # you've come to the right place!
  #
  #   require 'elastomer/notifications'
  #
  # Requiring this module will add ActiveSupport notifications to all
  # ElasticSearch requests. To subscribe to those requests ...
  #
  #   ActiveSupport::Notifications.subscribe('request.client.elastomer') do |name, start_time, end_time, _, payload|
  #     duration = end_time - start_time
  #     $stderr.puts '[%s] %s %s (%.3f)' % [payload[:status], payload[:index], payload[:action], duration]
  #   end
  #
  # The payload contains the following bits of information:
  #
  # * :index  - index name (if any)
  # * :type   - documeht type (if any)
  # * :action - the action being performed
  # * :url    - request URL
  # * :method - request method (:head, :get, :put, :post, :delete)
  # * :status - response status code
  #
  module Notifications

    # The name to subscribe to for notifications
    NAME = 'request.client.elastomer'.freeze

    # Internal: Execute the given block and provide instrumentaiton info to
    # subscribers. The name we use for subscriptions is
    # `request.client.elastomer` and a supplemental payload is provided with
    # more information about the specific ElasticSearch request.
    #
    # path   - The full request path as a String
    # params - The request params Hash
    # block  - The block that will be instrumented
    #
    # Returns the response from the block
    def instrument( path, params )
      action = params[:action]

      if action.nil?
        ary = []
        m = /^([^?]*)/.match path
        m[1].split('?').first.split('/').each do |str|
          if str =~ /^_(.*)$/
            ary.clear
            ary << $1
          else
            ary << str
          end
        end
        action = ary.join '.' unless ary.empty?
      end

      payload = {
        :index  => params[:index],
        :type   => params[:type],
        :url    => "#{@url}#{path}",
        :action => action
      }

      ActiveSupport::Notifications.instrument(NAME, payload) do
        response = yield
        payload[:method] = response.env[:method]
        payload[:status] = response.status
        response
      end
    end
  end

  class Client
    remove_method :instrument
    include ::Elastomer::Notifications
  end
end
