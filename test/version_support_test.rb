require_relative './test_helper'

describe Elastomer::VersionSupport do
  describe "ES 2.x" do
    let(:client) do
      client = Elastomer::Client.new(host: "fake.web", port: 8888)

      def client.version
        "2.3.5"
      end

      client
    end
    let(:version_support) { Elastomer::VersionSupport.new(client) }

    describe "#keyword" do
      it "returns non_analyzed string" do
        expected = {
          type: "string",
          index: "not_analyzed",
          store: true
        }
        assert_equal(expected, version_support.keyword(store: true))
      end
    end

    describe "#text" do
      it "returns analyzed string" do
        expected = {
          type: "string",
          term_vector: "with_positions_offsets"
        }
        assert_equal(expected, version_support.text(term_vector: "with_positions_offsets"))
      end
    end

  end

  describe "ES 5.x" do
    let(:client) do
      client = Elastomer::Client.new(host: "fake.web", port: 8888)

      def client.version
        "5.6.0"
      end

      client
    end
    let(:version_support) { Elastomer::VersionSupport.new(client) }

    describe "#keyword" do
      it "returns keyword" do
        expected = {
          type: "keyword",
          store: true
        }
        assert_equal(expected, version_support.keyword(store: true))
      end
    end

    describe "#text" do
      it "returns text" do
        expected = {
          type: "text",
          term_vector: "with_positions_offsets"
        }
        assert_equal(expected, version_support.text(term_vector: "with_positions_offsets"))
      end
    end
  end
end
