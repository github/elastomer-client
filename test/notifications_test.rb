require File.expand_path('../test_helper', __FILE__)
require 'elastomer/notifications'

describe Elastomer::Notifications do
  before do
    @name = 'elastomer-notifications-test'
    @index = $client.index @name
    @index.delete if @index.exists?
    @events = []
    @subscriber = ActiveSupport::Notifications.subscribe do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  after do
    ActiveSupport::Notifications.unsubscribe(@subscriber)
    @index.delete if @index.exists?
  end

  it "instruments timeouts" do
    $client.stub :connection, lambda { raise Faraday::Error::TimeoutError } do
      assert_raises(Elastomer::Client::TimeoutError) { $client.info }
      event = @events.detect { |e| e.payload[:action] == 'cluster.info' }
      exception = event.payload[:exception]
      assert_equal 'Elastomer::Error::TimeoutError', exception[0]
      assert_match 'timeout', exception[1]
    end
  end
end
