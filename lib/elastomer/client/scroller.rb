# frozen_string_literal: true

module Elastomer
  class Client

    # Create a new Scroller instance for scrolling all results from a `query`.
    #
    # query  - The query to scroll as a Hash or a JSON encoded String
    # opts   - Options Hash
    #   :index  - the name of the index to search
    #   :type   - the document type to search
    #   :scroll - the keep alive time of the scrolling request (5 minutes by default)
    #   :size   - the number of documents per shard to fetch per scroll
    #
    # Examples
    #
    #   scroll = client.scroll('{"query":{"match_all":{}}}', index: 'test')
    #   scroll.each_document do |document|
    #     document['_id']
    #     document['_source']
    #   end
    #
    # Returns a new Scroller instance
    def scroll(query, opts = {})
      Scroller.new(self, query, opts)
    end

    # Create a new Scroller instance for scrolling all results from a `query`
    # via "scan" semantics by sorting by _doc.
    #
    # query  - The query to scan as a Hash or a JSON encoded String
    # opts   - Options Hash
    #   :index  - the name of the index to search
    #   :type   - the document type to search
    #   :scroll - the keep alive time of the scrolling request (5 minutes by default)
    #   :size   - the number of documents per shard to fetch per scroll
    #
    # Examples
    #
    #   scan = client.scan('{"query":{"match_all":{}}}', index: 'test')
    #   scan.each_document do |document|
    #     document['_id']
    #     document['_source']
    #   end
    #
    # Returns a new Scroller instance
    def scan(query, opts = {})
      Scroller.new(self, add_sort_by_doc(query), opts)
    end

    # Begin scrolling a query.
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
    #
    # opts   - Options Hash
    #   :body        - the query to scroll as a Hash or JSON encoded String
    #   :index       - the name of the index to search
    #   :type        - the document type to search
    #   :scroll      - the keep alive time of the scrolling request (5 minutes by default)
    #   :size        - the number of documents per shard to fetch per scroll
    #   :search_type - set to 'scan' for scan semantics  # DEPRECATED in ES 2.1.0 - use a Scroll query sorted by _doc: https://www.elastic.co/guide/en/elasticsearch/reference/2.3/search-request-search-type.html#scan
    #
    # Examples
    #
    #   h = client.start_scroll(body: '{"query":{"match_all":{}},"sort":{"created":"desc"}}', index: 'test')
    #   scroll_id = h['_scroll_id']
    #   h['hits']['hits'].each { |doc| ... }
    #
    #   h = client.continue_scroll(scroll_id)
    #   scroll_id = h['_scroll_id']
    #   h['hits']['hits'].each { |doc| ... }
    #
    #   # repeat until there are no more hits
    #
    # Returns the response body as a Hash.
    def start_scroll(opts = {})
      opts = opts.merge action: "search.start_scroll", rest_api: "search"
      opts.delete(:type) if version_support.es_version_8_plus?
      response = get "{/index}{/type}/_search", opts
      response.body
    end

    # Continue scrolling a query.
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
    #
    # scroll_id - The current scroll ID as a String
    # scroll    - The keep alive time of the scrolling request (5 minutes by default)
    #
    # Examples
    #
    #   scroll_id = client.start_scroll(body: '{"query":{"match_all":{}}}', index: 'test')['_scroll_id']
    #
    #   h = client.continue_scroll scroll_id   # scroll to get the next set of results
    #   scroll_id = h['_scroll_id']            # and store the scroll_id to use later
    #
    #   h = client.continue_scroll scroll_id   # scroll again to get the next set of results
    #   scroll_id = h['_scroll_id']            # and store the scroll_id to use later
    #
    #   # repeat until the results are empty
    #
    # Returns the response body as a Hash.
    def continue_scroll(scroll_id, scroll = "5m")
      response = get "/_search/scroll", body: {scroll_id: scroll_id}, scroll: scroll, action: "search.scroll", rest_api: "scroll"
      response.body
    rescue RequestError => err
      if err.error && err.error["caused_by"]["type"] == "search_context_missing_exception"
        raise SearchContextMissing, "No search context found for scroll ID #{scroll_id.inspect}"
      else
        raise err
      end
    end

    # Delete one or more scroll IDs.
    # see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html#_clear_scroll_api
    #
    # scroll_id - One or more scroll IDs
    #
    # Returns the response body as a Hash.
    def clear_scroll(scroll_ids)
      response = delete "/_search/scroll", body: {scroll_id: Array(scroll_ids)}, action: "search.clear_scroll", rest_api: "clear_scroll"
      response.body
    end

    # Internal: Add sort by doc to query.
    #
    # Raises an exception if the query contains a sort already.
    # Returns the query as a hash
    def add_sort_by_doc(query)
      if query.nil?
        query = {}
      elsif query.is_a? String
        query = MultiJson.load(query)
      end

      if query.has_key? :sort
        raise ArgumentError, "Query cannot contain a sort (found sort '#{query[:sort]}' in query: #{query})"
      end

      query.merge(sort: [:_doc])
    end

    DEFAULT_OPTS = {
      index:   nil,
      type:    nil,
      scroll:  "5m",
      size:    50,
    }.freeze

    class Scroller
      # Create a new scroller that can be used to iterate over all the documents
      # returned by the `query`. The Scroller supports both the 'scan' and the
      # 'scroll' search types.
      #
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
      # and https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-search-type.html#scan
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # query  - The query to scroll as a Hash or a JSON encoded String
      # opts   - Options Hash
      #   :index       - the name of the index to search
      #   :type        - the document type to search
      #   :scroll      - the keep alive time of the scrolling request (5 minutes by default)
      #   :size        - the number of documents per shard to fetch per scroll
      #   :search_type - set to 'scan' for scan semantics  # DEPRECATED in ES 2.1.0 - use a Scroll query sorted by _doc: https://www.elastic.co/guide/en/elasticsearch/reference/2.3/search-request-search-type.html#scan
      #
      # Examples
      #
      #   scan = Scroller.new(client, {query: {match_all: {}}}, index: 'test-1')
      #   scan.each_document { |doc|
      #     doc['_id']
      #     doc['_source']
      #   }
      #
      def initialize(client, query, opts = {})
        @client = client

        @opts = DEFAULT_OPTS.merge({ body: query }).merge(opts)

        @scroll_id = nil
        @offset = 0
      end

      attr_reader :client, :query, :scroll_id

      # Iterate over all the search results from the scan query.
      #
      # block  - The block will be called for each set of matching documents
      #          returned from executing the scan query.
      #
      # Yields a hits Hash containing the 'total' number of hits, current
      # 'offset' into that total, and the Array of 'hits' document Hashes.
      #
      # Examples
      #
      #   scan.each do |hits|
      #     hits['total']
      #     hits['offset']
      #     hits['hits'].each { |document| ... }
      #   end
      #
      # Returns this Scroller instance.
      def each
        loop do
          body = do_scroll

          hits = body["hits"]
          break if hits["hits"].empty?

          hits["offset"] = @offset
          @offset += hits["hits"].length

          yield hits
        end

        self
      ensure
        clear!
      end

      # Iterate over each document from the scan query. This method is just a
      # convenience wrapper around the `each` method; it iterates the Array of
      # documents and passes them one by one to the block.
      #
      # block  - The block will be called for each document returned from
      #          executing the scan query.
      #
      # Yields a document Hash.
      #
      # Examples
      #
      #   scan.each_document do |document|
      #     document['_id']
      #     document['_source']
      #   end
      #
      # Returns this Scroller instance.
      def each_document(&block)
        each { |hits| hits["hits"].each(&block) }
      end

      # Terminate the scroll query. This will remove the search context from the
      # cluster and no further documents can be returned by this Scroller
      # instance.
      #
      # Returns nil if the `scroll_id` is not valid; returns the response body if
      # the `scroll_id` was cleared.
      def clear!
        return if scroll_id.nil?
        client.clear_scroll(scroll_id)
      rescue ::Elastomer::Client::IllegalArgument
        nil
      end

      # Internal: Perform the actual scroll requests. This method wil call out
      # to the `Client#start_scroll` and `Client#continue_scroll` methods while
      # keeping track of the `scroll_id` internally.
      #
      # Returns the response body as a Hash.
      def do_scroll
        if scroll_id.nil?
          body = client.start_scroll(@opts)
          if body["hits"]["hits"].empty?
            @scroll_id = body["_scroll_id"]
            return do_scroll
          end
        else
          body = client.continue_scroll(scroll_id, @opts[:scroll])
        end

        @scroll_id = body["_scroll_id"]
        body
      end

    end  # Scroller
  end  # Client
end  # Elastomer
