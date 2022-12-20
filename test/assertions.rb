# frozen_string_literal: true

module Minitest::Assertions
  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute with a 'created' attribute
  # in index responses. Check for either one so we are compatible
  # with 0.90 and 1.0.
  def assert_created(response)
    assert ($client.version_support.es_version_7_plus? ? response["result"] == "created" : response["created"]) || response["ok"], "document was not created"
  end

  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute with an 'acknowledged' attribute
  # in many responses. Check for either one so we are compatible
  # with 0.90 and 1.0.
  def assert_acknowledged(response)
    assert response["acknowledged"] || response["ok"], "document was not acknowledged"
  end

  #COMPATIBILITY
  # ES 1.0 replaced the 'exists' attribute with a 'found' attribute in the
  # get document response. Check for either one so we are compatible
  # with 0.90 and 1.0.
  def assert_found(response)
    assert response["found"] || response["exists"], "document was not found"
  end

  def refute_found(response)
    refute response["found"] || response["exists"], "document was unexpectedly found"
  end

  def assert_bulk_index(item, message = "bulk index did not succeed")
    status = item["index"]["status"]

    assert_equal(201, status, message)
  end

  def assert_bulk_create(item, message = "bulk create did not succeed")
    status = item["create"]["status"]

    assert_equal(201, status, message)
  end

  def assert_bulk_delete(item, message = "bulk delete did not succeed")
    status = item["delete"]["status"]

    assert_equal(200, status, message)
  end

  #COMPATIBILITY
  # ES 1.0 nests mappings in a "mappings" element under the index name, e.g.
  # mapping["test-index"]["mappings"]["doco"]
  # ES 0.90 doesn't have the "mappings" element:
  # mapping["test-index"]["doco"]
  def assert_mapping_exists(response, type, message = "mapping expected to exist, but doesn't")
    mapping =
      if response.has_key?("mappings")
        response["mappings"][type]
      else
        response[type]
      end

    refute_nil mapping, message
  end

  def assert_property_exists(response, type, property, message = "property expected to exist, but doesn't")
    mapping =
      if response.has_key?("mappings")
        response["mappings"][type]
      else
        response[type]
      end

    assert mapping["properties"].has_key?(property), message # rubocop:disable Minitest/AssertWithExpectedArgument
  end
end
