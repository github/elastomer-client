# frozen_string_literal: true

require_relative "../test_helper"

describe "Elastomer::Client::Warmer under ES 5.x" do
  it "cannot be instantiated" do
    if $client.version_support.supports_warmers?
      skip "warmers are still supported in ES #{$client.version}."
    end

    assert_raises(Elastomer::Client::IncompatibleVersionException) do
      Elastomer::Client::Warmer.new($client, "index", "warmer")
    end
  end
end
