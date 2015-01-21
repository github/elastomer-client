module Elastomer
  class Client

    # Create a new Scroller instance for scrolling all results from a `query`
    # via "scan" semantics.
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
    #   scan = client.scan('{"query":{"match_all":{}}}', :index => 'test')
    #   scan.each_document do |document|
    #     document['_id']
    #     document['_source']
    #   end
    #
    # Returns a new Scroller instance
    def scan( query, opts = {} )
      opts = opts.merge(:search_type => 'scan')
      Scroller.new(self, query, opts)
    end

    #
    #
    def scroll( query, opts = {} )
      Scroller.new(self, query, opts)
    end

    #
    #
    def start_scroll( opts = {} )
      opts = opts.merge :action => 'search.start_scroll'
      response = get '{/index}{/type}/_search', opts
      response.body
    end

    # Continue scrolling a query.
    # See http://www.elasticsearch.org/guide/reference/api/search/scroll/
    #
    # scroll_id - The current scroll ID as a String
    # scroll    - The keep alive time of the scrolling request (5 minutes by default)
    #
    # Examples
    #
    #   scroll_id = client.start_scroll('{"query":{"match_all":{}}}', :index => 'test')['_scroll_id']
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
    def continue_scroll( scroll_id, scroll = '5m' )
      response = get '/_search/scroll', :body => scroll_id, :scroll => scroll, :action => 'search.scroll'
      response.body
    end


    class Scroller
      # Create a new scroller that can be used to iterate over all the documents
      # returned by the `query`. The Scroller supports both the 'scan' and the
      # 'scroll' search types.
      #
      # See http://www.elasticsearch.org/guide/reference/api/search/scroll/
      # and the "Scan" section of http://www.elasticsearch.org/guide/reference/api/search/search-type/
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # query  - The query to scan as a Hash or a JSON encoded String
      # opts   - Options Hash
      #   :index       - the name of the index to search
      #   :type        - the document type to search
      #   :scroll      - the keep alive time of the scrolling request (5 minutes by default)
      #   :size        - the number of documents per shard to fetch per scroll
      #   :search_type - set to 'scan' for scan query semantics
      #
      # Examples
      #
      #   scan = Scroller.new(client, {:search_type => 'scan', :query => {:match_all => {}}}, :index => 'test-1')
      #   scan.each_document { |doc|
      #     doc['_id']
      #     doc['_source']
      #   }
      #
      def initialize( client, query, opts = {} )
        @client = client
        @query  = query

        @index       = opts.fetch(:index, nil)
        @type        = opts.fetch(:type, nil)
        @scroll      = opts.fetch(:scroll, '5m')
        @size        = opts.fetch(:size, 50)
        @search_type = opts.fetch(:search_type, nil)

        @scroll_id = nil
        @offset = 0
      end

      attr_reader :client, :query, :index, :type, :scroll, :size, :search_type, :scroll_id

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
      # Returns this Scan instance.
      def each
        loop do
          body = do_scroll

          hits = body['hits']
          break if hits['hits'].empty?

          hits['offset'] = @offset
          @offset += hits['hits'].length

          yield hits
        end

        self
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
      # Returns this Scan instance.
      def each_document( &block )
        each { |hits| hits['hits'].each(&block) }
      end

      # Internal:
      def do_scroll
        if scroll_id.nil?
          body = client.start_scroll(scroll_opts)
          if body['hits']['hits'].empty?
            @scroll_id = body['_scroll_id']
            return do_scroll
          end
        else
          body = client.continue_scroll(scroll_id, scroll)
        end

        @scroll_id = body['_scroll_id']
        body
      end

      # Internal:
      def scroll_opts
        hash = {
          :scroll => scroll,
          :size   => size,
          :index  => index,
          :type   => type,
          :body   => query
        }
        hash[:search_type] = search_type unless search_type.nil?
        hash
      end

    end  # Scroller
  end  # Client
end  # Elastomer
