module Minitest::Assertions
  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute with a 'created' attribute
  # in index responses. Check for either one so we are compatible
  # with 0.90 and 1.0.
  def assert_created(response)
    assert response['created'] || response['ok'], 'document was not created'
  end

  #COMPATIBILITY
  # ES 1.0 replaced the 'ok' attribute in the bulk response item with a
  # 'status' attribute. Here we check for either one for compatibility
  # with 0.90 and 1.0.
  def assert_bulk_index(item, message='bulk index did not succeed')
    ok     = item['index']['ok']
    status = item['index']['status']
    assert ok == true || status == 201, message
  end

  def assert_bulk_create(item, message='bulk create did not succeed')
    ok     = item['create']['ok']
    status = item['create']['status']
    assert ok == true || status == 201, message
  end

  def assert_bulk_delete(item, message='bulk delete did not succeed')
    ok     = item['delete']['ok']
    status = item['delete']['status']
    assert ok == true || status == 200, message
  end
end
