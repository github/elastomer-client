module Elastomer
  class Client
    # Execute delete_by_query using the native _delete_by_query API if supported
    # or the application-level implementation.
    #
    # Warning: These implementations have different parameters and return types.
    # If you want to use one or the other consistently, use Elastomer::Client#native_delete_by_query
    # or Elastomer::Client#app_delete_by_query directly.
    def delete_by_query(query, params = {})
      send(version_support.delete_by_query_method, query, params)
    end
  end
end
