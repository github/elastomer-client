module Minitest::Assertions
  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute with a 'created' attribute
  # in index responses. Check for either one so we are compatible
  # with 0.90 and 1.0.
  def assert_created(response)
    assert response["created"] || response["ok"], "document was not created"
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

  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute in the bulk response item with a
  # 'status' attribute. Here we check for either one for compatibility
  # with 0.90 and 1.0.
  def assert_bulk_index(item, message = "bulk index did not succeed")
    ok     = item["index"]["ok"]
    status = item["index"]["status"]
    assert ok == true || status == 201, message
  end

  def assert_bulk_create(item, message = "bulk create did not succeed")
    ok     = item["create"]["ok"]
    status = item["create"]["status"]
    assert ok == true || status == 201, message
  end

  def assert_bulk_delete(item, message = "bulk delete did not succeed")
    ok     = item["delete"]["ok"]
    status = item["delete"]["status"]
    assert ok == true || status == 200, message
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
    assert mapping["properties"].has_key?(property), message
  end
end
