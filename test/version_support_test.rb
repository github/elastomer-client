require_relative './test_helper'

describe Elastomer::VersionSupport do
  describe "supported versions" do
    it "allows 2.3.0 to 5.6" do
      two_three_series = ["2.3.0", "2.3.5", "2.4.0", "2.9.9", "2.9.100"]
      five_series = ["5.0.0", "5.0.9", "5.2.0", "5.6.9", "5.6.100"]

      two_three_series.each do |version|
        assert Elastomer::VersionSupport.new(version).es_version_2_x?
      end

      five_series.each do |version|
        assert Elastomer::VersionSupport.new(version).es_version_5_x?
      end
    end
  end

  describe "unsupported versions" do
    it "blow up" do
      too_low = ["0.90", "1.0.1", "2.0.0", "2.2.0"]
      too_high = ["5.7.0", "6.0.0"]

      (too_low + too_high).each do |version|
        exception = assert_raises(ArgumentError, "expected #{version} to not be supported") do
          Elastomer::VersionSupport.new(version)
        end

        assert_match version, exception.message
        assert_match "is not supported", exception.message
      end
    end
  end

  describe "ES 2.x" do
    let(:version_support) { Elastomer::VersionSupport.new("2.3.5") }

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

    describe "native_delete_by_query?" do
      it "returns false" do
        refute version_support.native_delete_by_query?, "ES 2.X does not have native delete_by_query support"
      end
    end

    describe "#indexing_directives" do
      it "returns a Hash of indexing parameter name to field name" do
        assert_includes(version_support.indexing_directives.to_a, [:consistency, "_consistency"])
      end
    end

    describe "#unsupported_indexing_directives" do
      it "returns a Hash of indexing parameter name to field name" do
        assert_includes(version_support.unsupported_indexing_directives.to_a, [:wait_for_active_shards, "_wait_for_active_shards"])
      end
    end
  end

  describe "ES 5.x" do
    let(:version_support) { Elastomer::VersionSupport.new("5.6.0") }

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

    describe "native_delete_by_query?" do
      it "returns true" do
        assert version_support.native_delete_by_query?, "ES 5.X has native delete_by_query support"
      end
    end

    describe "#indexing_directives" do
      it "returns a Hash of indexing parameter name to field name" do
        assert_includes(version_support.indexing_directives.to_a, [:wait_for_active_shards, "_wait_for_active_shards"])
      end
    end

    describe "#unsupported_indexing_directives" do
      it "returns an Hash of indexing parameter names to field name" do
        assert_includes(version_support.unsupported_indexing_directives.to_a, [:consistency, "_consistency"])
      end
    end
  end
end
