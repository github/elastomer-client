module Elastomer
  class Client

    # Delete documents from one or more indices and one or more types based
    # on a query.
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
    #   delete_by_query(nil, { :q => '*:*', :type => 'tweet' })
    #
    # See http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-delete-by-query.html
    #
    # Returns a Hash of statistics about the delete operations
    def delete_by_query(query, params = {})
      DeleteByQuery.new(self, query, params).execute
    end

    class DeleteByQuery

      def initialize(client, query, params = {})
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
        unless response.nil?
          @response_stats['took'] += response['took']

          response['items'].each do |item|
            item = item['delete']
            (@response_stats['_indices'][item['_index']] ||= {}).merge!(categorize(item)) { |_, n, m| n + m }
            @response_stats['_indices']['_all'].merge!(categorize(item)) { |_, n, m| n + m }
            @response_stats['failures'] << item unless is_ok? item['status']
          end
        end
      end

      def execute()
        # accumulate is called both inside and outside the bulk block in order
        # to capture bulk responses returned from calls to `delete` and the call
        # to `bulk`
        accumulate(@client.bulk(@params) do |bulk|
          @client.scan(@query, @params).each_document do |hit|
            accumulate(bulk.delete(_id: hit["_id"], _type: hit["_type"], _index: hit["_index"]))
          end
        end)

        @response_stats
      end

    end  # DeleteByQuery
  end  # Client
end  # Elastomer
