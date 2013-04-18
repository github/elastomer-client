require 'json' unless defined? ::JSON

module Elastomer
  class Client

    def scan( query, opts = {} )
      Scan.new self, query, opts
    end

    class Index
      #
      #
      def scan( query, opts = {} )
        opts = {:index => name}.merge opts
        client.scan query, opts
      end
    end

    class Docs
      #
      #
      def scan( query, opts = {} )
        opts = {:index => name, :type => type}.merge opts
        client.scan query, opts
      end
    end  # Docs


    class Scan

      #
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

      #
      #
      def scroll_id
        return @scroll_id if defined? @scroll_id

        response = client.get '{/index}{/type}/_search',
                              :search_type => 'scan',
                              :scroll      => scroll,
                              :size        => size,
                              :index       => index,
                              :type        => type

        @scroll_id = response.body['_scroll_id']
      end

      #
      #
      def each
        loop do
          response = client.get '/_search/scroll', :scroll => scroll, :body => scroll_id
          @scroll_id = response.body['_scroll_id']

          hits = response.body['hits']
          break if hits['hits'].empty?

          hits['offset'] = @offset
          @offset += hits['hits'].length

          yield hits
        end

        self
      end

      #
      #
      def each_document( &block )
        each { |hits| hits['hits'].each(&block) }
      end

    end  # Scan
  end  # Client
end  # Elastomer
