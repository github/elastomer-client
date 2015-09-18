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
    # Returns a Hash of statistics about the delete operations, for example:
    #
    #   {
    #     "took" : 639,
    #     "_indices" : {
    #       "_all" : {
    #         "found" : 5901,
    #         "deleted" : 5901,
    #         "missing" : 0,
    #         "failed" : 0
    #       },
    #       "twitter" : {
    #         "found" : 5901,
    #         "deleted" : 5901,
    #         "missing" : 0,
    #         "failed" : 0
    #       }
    #     },
    #     "failures" : [ ]
    #   }
    def delete_by_query(query, params = {})
      DeleteByQuery.new(self, query, params).execute
    end

    class DeleteByQuery

      # Create a new DeleteByQuery command for deleting documents matching a
      # query
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # query  - The query used to find documents to delete
      # params - Other URL parameters
      def initialize(client, query, params = {})
        @client = client
        @query = query
        @params = params
        @response_stats = { 'took' => 0, '_indices' => { '_all' => {} }, 'failures' => [] }
      end

      attr_reader :client, :query, :params, :response_stats

      # Internal: Determine whether or not an HTTP status code is in the range
      # 200 to 299
      #
      # status - HTTP status code
      #
      # Returns a boolean
      def is_ok?(status)
        status.between?(200, 299)
      end

      # Internal: Tally the contributions of an item to the found, deleted,
      # missing, and failed counts for the summary statistics
      #
      # item - An element of the items array from a bulk response
      #
      # Returns a Hash of counts for each category
      def categorize(item)
        {
          "found" => item["found"] || item["status"] == 409 ? 1 : 0,
          "deleted" => is_ok?(item["status"]) ? 1 : 0,
          "missing" => !item["found"]  && !item.key?("error") ? 1 : 0,
          "failed" => item.key?("error") ? 1 : 0,
        }
      end

      # Internal: Combine a response item with the existing statistics
      #
      # item - A bulk response item
      def accumulate(item)
        item = item["delete"]
        (@response_stats['_indices'][item['_index']] ||= {}).merge!(categorize(item)) { |_, n, m| n + m }
        @response_stats['_indices']['_all'].merge!(categorize(item)) { |_, n, m| n + m }
        @response_stats['failures'] << item unless is_ok? item['status']
      end

      # Perform the Delete by Query action
      #
      # Returns a Hash of statistics about the bulk operation
      def execute
        ops = Enumerator.new do |yielder|
          @client.scan(@query, @params).each_document do |hit|
            yielder.yield([:delete, { _id: hit["_id"], _type: hit["_type"], _index: hit["_index"] }])
          end
        end

        stats = @client.bulk_stream_items(ops, @params) { |item| accumulate(item) }
        @response_stats['took'] = stats['took']
        @response_stats
      end

    end  # DeleteByQuery
  end  # Client
end  # Elastomer
