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
