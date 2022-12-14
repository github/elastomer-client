require_relative "./test_helper"

describe Elastomer::VersionSupport do
  describe "supported versions" do
    it "allows 2.3.0 to 5.6" do
      two_three_series = ["2.3.0", "2.3.5", "2.4.0", "2.9.9", "2.9.100"]
      five_series = ["5.0.0", "5.0.9", "5.2.0", "5.6.9", "5.6.100"]
      seven_series = ["7.0.0", "7.0.9", "7.2.0", "7.17.7", "7.17.100"]

      two_three_series.each do |version|
        assert Elastomer::VersionSupport.new(version).es_version_2_x?
      end

      five_series.each do |version|
        assert Elastomer::VersionSupport.new(version).es_version_5_plus?
      end

      seven_series.each do |version|
        assert Elastomer::VersionSupport.new(version).es_version_5_plus?
        assert Elastomer::VersionSupport.new(version).es_version_7_plus?
      end
    end
  end

  describe "unsupported versions" do
    it "blow up" do
      too_low = ["0.90", "1.0.1", "2.0.0", "2.2.0"]
      too_high = ["8.0.0", "9.0.0"]

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

    describe "#op_type_param" do
      it "converts the supplied params key _op_type to op_type, if present" do
        assert_equal(version_support.op_type(_op_type: "create"), {op_type: "create"})
      end
    end
  end
end
