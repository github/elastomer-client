module Elastomer
  class Client

    # Execute an array of searches in bulk. Results are returned in an
    # array in the order the queries were sent.
    #
    # The `multi_search` method can be used in two ways. Without a block
    # the method will perform an API call, and it requires a bulk request
    # body and optional request parameters.
    #
    # See http://www.elasticsearch.org/guide/reference/api/multi-search/
    #
    # body   - Request body as a String (required if a block is not given)
    # params - Optional request parameters as a Hash
    # block  - Passed to a MultiSearch instance which assembles the searches
    #          into a single request.
    #
    # Examples
    #
    #   # index and type in request body
    #   multi_search(request_body)
    #
    #   # index in URI
    #   multi_search(request_body, :index => 'default-index')
    #
    #   # block form
    #   multi_search(:index => 'default-index') do |m|
    #     m.search({:query => {:match_all => {}}, :search_type => :count)
    #     m.search({:query => {:field => {"foo" => "bar"}}}, :type => 'default-type')
    #     ...
    #   end
    #
    # Returns the response body as a Hash
    def multi_search(body = nil, params = nil)
      if block_given?
        params, body = (body || {}), nil
        yield msearch_obj = MultiSearch.new(self, params)
        msearch_obj.call
      else
        raise 'multi_search request body cannot be nil' if body.nil?
        params ||= {}

        response = self.post '{/index}{/type}/_msearch', params.merge(:body => body)
        response.body
      end
    end
    alias :msearch :multi_search

    class MultiSearch

      def initialize(client, params = {})
        @client  = client
        @params  = params

        @actions = []
      end

      attr_reader :client

      def search(query, params = {})
        add_to_actions(params)
        add_to_actions(query)

        self
      end

      def call
        return if @actions.empty?

        body = @actions.join("\n") + "\n"
        response = client.multi_search(body, @params)
      ensure
        @actions.clear
      end

      def add_to_actions(action)
        action = ::JSON.dump action
        @actions << action
      end
    end
  end
end
