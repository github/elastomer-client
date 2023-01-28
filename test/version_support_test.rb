# frozen_string_literal: true

require_relative "./test_helper"

describe Elastomer::VersionSupport do
  describe "supported versions" do
    it "allows 2.3.0 to 8.6.0" do
      two_three_series = ["2.3.0", "2.3.5", "2.4.0", "2.9.9", "2.9.100"]
      five_series = ["5.0.0", "5.0.9", "5.2.0", "5.6.9", "5.6.100"]
      seven_series = ["7.0.0", "7.0.9", "7.2.0", "7.17.7", "7.17.100"]
      eight_series = ["8.0.0", "8.6.0"]

      two_three_series.each do |version|
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_2_x?
      end

      five_series.each do |version|
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_5_plus?
      end

      seven_series.each do |version|
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_5_plus?
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_7_plus?
      end

      eight_series.each do |version|
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_5_plus?
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_7_plus?
        assert_predicate Elastomer::VersionSupport.new(version), :es_version_8_plus?
      end
    end
  end

  describe "unsupported versions" do
    it "blow up" do
      too_low = ["0.90", "1.0.1", "2.0.0", "2.2.0"]
      too_high = ["9.0.0"]

      (too_low + too_high).each do |version|
        exception = assert_raises(ArgumentError, "expected #{version} to not be supported") do
          Elastomer::VersionSupport.new(version)
        end

        assert_match version, exception.message
        assert_match "is not supported", exception.message
      end
    end
  end

  describe "ES 5.x" do
    let(:version_support) { Elastomer::VersionSupport.new("5.6.0") }

    describe "#op_type_param" do
      it "converts the supplied params key _op_type to op_type, if present" do
        assert_equal({op_type: "create"}, version_support.op_type(_op_type: "create"))
      end
    end
  end
end
