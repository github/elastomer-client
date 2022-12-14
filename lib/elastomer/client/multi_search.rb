# frozen_string_literal: true

module Elastomer
  class Client

    # Execute an array of searches in bulk. Results are returned in an
    # array in the order the queries were sent.
    #
    # The `multi_search` method can be used in two ways. Without a block
    # the method will perform an API call, and it requires a bulk request
    # body and optional request parameters.
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html
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
    #   multi_search(request_body, index: 'default-index')
    #
    #   # block form
    #   multi_search(index: 'default-index') do |m|
    #     m.search({query: {match_all: {}}, size: 0)
    #     m.search({query: {field: {"foo" => "bar"}}}, type: 'default-type')
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
        raise "multi_search request body cannot be nil" if body.nil?
        params ||= {}

        response = self.post "{/index}{/type}/_msearch", params.merge(body: body, action: "msearch", rest_api: "msearch")
        response.body
      end
    end
    alias_method :msearch, :multi_search

    # The MultiSearch class is a helper for accumulating and submitting
    # multi_search API requests. Instances of the MultiSearch class
    # accumulate searches and then issue a single API request to
    # Elasticsearch, which runs all accumulated searches in parallel
    # and returns each result hash aggregated into an array of result
    # hashes.
    #
    # Instead of instantiating this class directly, use
    # the block form of Client#multi_search.
    #
    class MultiSearch

      # Create a new MultiSearch instance for accumulating searches and
      # submitting them all as a single request.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # params - Parameters Hash to pass to the Client#multi_search method
      def initialize(client, params = {})
        @client  = client
        @params  = params

        @actions = []
      end

      attr_reader :client

      # Add a search to the multi search request. This search will not
      # be executed until the multi_search API call is made.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Returns this MultiSearch instance.
      def search(query, params = {})
        add_to_actions(params)
        add_to_actions(query)
      end

      # Execute the multi_search call with the accumulated searches. If
      # the accumulated actions list is empty then no action is taken.
      #
      # Returns the response body Hash.
      def call
        return if @actions.empty?

        body = @actions.join("\n") + "\n"
        client.multi_search(body, @params)
      ensure
        @actions.clear
      end

      # Internal: Add an action to the pending request. Actions can be
      # either search params or query bodies. The first action must be
      # a search params hash, followed by a query body, then alternating
      # params and queries.
      #
      # action - the Hash (params or query) to add to the pending request
      #
      # Returns this MultiSearch instance.
      def add_to_actions(action)
        action = MultiJson.dump action
        @actions << action
        self
      end
    end
  end
end
