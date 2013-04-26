module Elastomer
  class Client

    # Executes an array of searches in bulk and returns the results in
    # an array.
    #
    # See http://www.elasticsearch.org/guide/reference/api/multi-search/
    #
    # Examples
    #
    #   # index and type in request body
    #   multi_search(request_body)
    #
    #  # index in URI
    #  multi_search(request_body, :index => 'default-index')
    #
    #
    # Returns the response body as a Hash
    def multi_search(body = nil, params = nil)
      if block_given?
      else
        raise 'multi_search request body cannot be nil' if body.nil?
        params ||= {}

        response = self.post '{/index}{/type}/_msearch', params.merge(:body => body)
        response.body
      end
    end
    alias :msearch :multi_search

    class MultiSearch
    end
  end
end
