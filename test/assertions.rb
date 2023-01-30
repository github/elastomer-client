# frozen_string_literal: true

module Minitest::Assertions
  # COMPATIBILITY
  # ES 7+ response uses "result" instead of "created"
  def assert_created(response)
    assert $client.version_support.es_version_7_plus? ? response["result"] == "created" : response["created"], "document was not created"
  end

  def assert_acknowledged(response)
    assert response["acknowledged"], "document was not acknowledged"
  end

  def assert_found(response)
    assert response["found"], "document was not found"
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

  # COMPATIBILITY
  # ES 7+ no longer supports types
  def assert_mapping_exists(response, type, message = "mapping expected to exist, but doesn't")
    mapping =
      if $client.version_support.es_version_7_plus?
        response["mappings"]
      else
        response["mappings"][type]
      end

    refute_nil mapping, message
  end

  # COMPATIBILITY
  # ES 7+ no longer supports types
  def assert_property_exists(response, type, property, message = "property expected to exist, but doesn't")
    mapping =
      if response.has_key?("mappings")
        if $client.version_support.es_version_7_plus?
          response["mappings"]
        else
          response["mappings"][type]
        end
      else
        response[type]
      end

    assert mapping["properties"].has_key?(property), message
  end
end
