module Elastomer
  class Client

    # Execute an array of percolate actions in bulk. Results are returned in an
    # array in the order the actions were sent.
    #
    # The `multi_percolate` method can be used in two ways. Without a block
    # the method will perform an API call, and it requires a bulk request
    # body and optional request parameters.
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html#_multi_percolate_api
    #
    # body   - Request body as a String (required if a block is not given)
    # params - Optional request parameters as a Hash
    # block  - Passed to a MultiPercolate instance which assembles the
    #          percolate actions into a single request.
    #
    # Examples
    #
    #   # index and type in request body
    #   multi_percolate(request_body)
    #
    #   # index in URI
    #   multi_percolate(request_body, :index => 'default-index')
    #
    #   # block form
    #   multi_percolate(:index => 'default-index') do |m|
    #     m.percolate({ :author => "pea53" }, { :type => 'default-type' })
    #     m.count({ :author => "pea53" }, { :type => 'type2' })
    #     ...
    #   end
    #
    # Returns the response body as a Hash
    def multi_percolate(body = nil, params = nil)
      if block_given?
        params, body = (body || {}), nil
        yield mpercolate_obj = MultiPercolate.new(self, params)
        mpercolate_obj.call
      else
        raise 'multi_percolate request body cannot be nil' if body.nil?
        params ||= {}

        response = self.post '{/index}{/type}/_mpercolate', params.merge(:body => body)
        response.body
      end
    end
    alias_method :mpercolate, :multi_percolate

    # The MultiPercolate class is a helper for accumulating and submitting
    # multi_percolate API requests. Instances of the MultiPercolate class
    # accumulate percolate actions and then issue a single API request to
    # Elasticsearch, which runs all accumulated percolate actions in parallel
    # and returns each result hash aggregated into an array of result
    # hashes.
    #
    # Instead of instantiating this class directly, use
    # the block form of Client#multi_percolate.
    #
    class MultiPercolate

      # Create a new MultiPercolate instance for accumulating percolate actions
      # and submitting them all as a single request.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # params - Parameters Hash to pass to the Client#multi_percolate method
      def initialize(client, params = {})
        @client  = client
        @params  = params

        @actions = []
      end

      attr_reader :client

      # Add a percolate action to the multi percolate request. This percolate
      # action will not be executed until the multi_percolate API call is made.
      #
      # header - A Hash of the index and type, if not provided in the params
      # doc    - A Hash of the document
      #
      # Returns this MultiPercolate instance.
      def percolate(doc, header = {})
        add_to_actions(:percolate => header)
        add_to_actions(:doc => doc)
      end

      # Add a percolate acount action to the multi percolate request. This
      # percolate count action will not be executed until the multi_percolate
      # API call is made.
      #
      # header - A Hash of the index and type, if not provided in the params
      # doc    - A Hash of the document
      #
      # Returns this MultiPercolate instance.
      def count(header, doc)
        add_to_actions(:count => header)
        add_to_actions(:doc => doc)
      end

      # Execute the multi_percolate call with the accumulated percolate actions.
      # If the accumulated actions list is empty then no action is taken.
      #
      # Returns the response body Hash.
      def call
        return if @actions.empty?

        body = @actions.join("\n") + "\n"
        client.multi_percolate(body, @params)
      ensure
        @actions.clear
      end

      # Internal: Add an action to the pending request. Actions can be
      # either headers or bodies. The first action must be a percolate header,
      # followed by a body, then alternating headers and bodies.
      #
      # action - the Hash (header or body) to add to the pending request
      #
      # Returns this MultiPercolate instance.
      def add_to_actions(action)
        action = MultiJson.dump action
        @actions << action
        self
      end
    end
  end
end
