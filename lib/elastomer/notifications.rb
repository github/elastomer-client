require 'active_support/notifications'
require 'securerandom'

require File.expand_path('../client', __FILE__) unless defined? Elastomer::Client

module Elastomer
  module Notifications
    # Internal:
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

      ActiveSupport::Notifications.instrument('request.client.elastomer', payload) do
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
