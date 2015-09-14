module Elastomer
  class Client

    class DeleteByQuery

      def initialize(client, query, params = nil)
        @client = client
        @query = query
        @params = params
        @response_stats = { 'took' => 0, '_indices' => { '_all' => {} }, 'failures' => [] }
      end

      attr_reader :client, :query, :params, :response_stats

      def is_ok?(status)
        status.between?(200, 299)
      end

      def categorize(item)
        {
          "found" => item["found"] ? 1 : 0,
          "deleted" => is_ok?(item["status"]) ? 1 : 0,
          "missing" => !item["found"] ? 1 : 0,
          "failed" => item["found"] && !is_ok?(item["status"]) ? 1 : 0,
        }
      end

      def accumulate(response)
        unless response == nil
          @response_stats['took'] += response['took']

          response['items'].map { |i| i['delete'] }.each do |i|
            (@response_stats['_indices'][i['_index']] ||= {}).merge!(categorize(i)) { |_, n, m| n + m }
            @response_stats['_indices']['_all'].merge!(categorize(i)) { |_, n, m| n + m }
            @response_stats['failures'] << i unless is_ok? i['status']
          end
        end
      end

      # Delete documents from one or more indices and one or more types based
      # on a query. This method supports both the "request body" query and the
      # "URI request" query. When using the request body semantics, the query
      # hash must contain the :query key. Otherwise we assume a URI request is
      # being made.
      #
      # The return value follows the format returned by the Elasticsearch Delete
      # by Query plugin: https://github.com/elastic/elasticsearch/blob/master/docs/plugins/delete-by-query.asciidoc#response-body
      #
      # Internally, this method uses a combination of scroll and bulk delete
      # instead of the Delete by Query API, which was removed in Elasticsearch
      # 2.0.
      #
      # query  - The query body as a Hash
      # params - Parameters Hash
      #
      # Examples
      #
      #   # request body query
      #   delete_by_query({:query => {:match_all => {}}}, :type => 'tweet')
      #
      #   # same thing but using the URI request method
      #   delete_by_query(:q => '*:*', :type => 'tweet')
      #
      # See http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-delete-by-query.html
      #
      # Returns a Hash of statistics about the delete operations
      def execute()
        # accumulate is called both inside and outside the bulk block in order
        # to capture bulk responses returned from calls to `delete` and the call
        # to `bulk`
        accumulate(@client.bulk(@params) do |b|
          @client.scan(@query, @params).each_document do |hit|
            accumulate(b.delete(_id: hit["_id"], _type: hit["_type"], _index: hit["_index"]))
          end
        end)

        @response_stats
      end

    end  # DeleteByQuery
  end  # Client
end  # Elastomer
