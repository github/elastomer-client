module Elastomer
  class Client

    # Create a new Scan instance for scrolling all results from a `query`.
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
    # Returns a new Scan instance
    def scan( query, opts = {} )
      Scan.new self, query, opts
    end

    # Continue scrolling a scan query.
    # See http://www.elasticsearch.org/guide/reference/api/search/scroll/
    #
    # scroll_id - The current scroll ID as a String
    # scroll    - The keep alive time of the scrolling request (5 minutes by default)
    #
    # Examples
    #
    #   scroll_id = client.scan('{"query":{"match_all":{}}}', :index => 'test').scroll_id
    #
    #   h = client.scroll scroll_id   # scroll to get the next set of results
    #   scroll_id = h['_scroll_id']   # and store the scroll_id to use later
    #
    #   h = client.scroll scroll_id   # scroll again to get the next set of results
    #   scroll_id = h['_scroll_id']   # and store the scroll_id to use later
    #
    #   # repeat until the results are empty
    #
    # Returns the response body as a Hash.
    def scroll( scroll_id, scroll = '5m' )
      response = get '/_search/scroll', :body => scroll_id, :scroll => scroll, :action => 'search.scroll'
      response.body
    end


    class Scan
      # Create a new scan client that can be used to iterate over all the
      # documents returned by the `query`.
      #
      # See http://www.elasticsearch.org/guide/reference/api/search/scroll/
      # and the "Scan" section of http://www.elasticsearch.org/guide/reference/api/search/search-type/
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # query  - The query to scan as a Hash or a JSON encoded String
      # opts   - Options Hash
      #   :index  - the name of the index to search
      #   :type   - the document type to search
      #   :scroll - the keep alive time of the scrolling request (5 minutes by default)
      #   :size   - the number of documents per shard to fetch per scroll
      #
      # Examples
      #
      #   scan = Scan.new(client, {:query => {:match_all => {}}}, :index => 'test-1')
      #   scan.each_document { |doc|
      #     doc['_id']
      #     doc['_source']
      #   }
      #
      def initialize( client, query, opts = {} )
        @client = client
        @query  = query

        @index  = opts.fetch(:index, nil)
        @type   = opts.fetch(:type, nil)
        @scroll = opts.fetch(:scroll, '5m')
        @size   = opts.fetch(:size, 50)

        @offset = 0
      end

      attr_reader :client, :query, :index, :type, :scroll, :size

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
          body = client.scroll scroll_id, scroll
          @scroll_id = body['_scroll_id']

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

      # Internal: Returns the current scroll ID as a String.
      def scroll_id
        return @scroll_id if defined? @scroll_id

        response = client.get '{/index}{/type}/_search',
                              :action      => 'search.scan',
                              :search_type => 'scan',
                              :scroll      => scroll,
                              :size        => size,
                              :index       => index,
                              :type        => type,
                              :body        => query

        @scroll_id = response.body['_scroll_id']
      end

    end  # Scan
  end  # Client
end  # Elastomer
