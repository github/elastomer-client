require File.expand_path("../../test_helper", __FILE__)

describe "Elastomer::Client::Warmer under ES 5.x" do
  it "cannot be instantiated" do
    if es_version_2_x?
      skip "warmers are still supported in ES 2.x."
    elsif es_version_5_x?
      exception = assert_raises(Elastomer::Client::IncompatibleVersionException) do
        Elastomer::Client::Warmer.new($client, "index", "warmer")
      end
    else
      fail "Unknown elasticsearch version"
    end
  end
end
