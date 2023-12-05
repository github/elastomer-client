# frozen_string_literal: true

require_relative "./test_helper"

describe ElastomerClient::VersionSupport do
  describe "supported versions" do
    it "allows 5.0.0 to 8.x" do
      five_series = ["5.0.0", "5.0.9", "5.2.0", "5.6.9", "5.6.100"]
      seven_series = ["7.0.0", "7.0.9", "7.2.0", "7.17.7", "7.17.100"]
      eight_series = ["8.0.0", "8.6.0"]

      five_series.each do |version|
        assert ElastomerClient::VersionSupport.new(version)
      end

      seven_series.each do |version|
        assert_predicate ElastomerClient::VersionSupport.new(version), :es_version_7_plus?
      end

      eight_series.each do |version|
        assert_predicate ElastomerClient::VersionSupport.new(version), :es_version_7_plus?
        assert_predicate ElastomerClient::VersionSupport.new(version), :es_version_8_plus?
      end
    end
  end

  describe "unsupported versions" do
    it "blow up" do
      too_low = ["0.90", "1.0.1", "2.0.0", "2.2.0"]
      too_high = ["9.0.0"]

      (too_low + too_high).each do |version|
        exception = assert_raises(ArgumentError, "expected #{version} to not be supported") do
          ElastomerClient::VersionSupport.new(version)
        end

        assert_match version, exception.message
        assert_match "is not supported", exception.message
      end
    end
  end
end
