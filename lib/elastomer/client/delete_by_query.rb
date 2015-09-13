module Elastomer
  class Client

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
    def delete_by_query( docs, query, params = nil )
      DeleteByQuery.new(docs, query, params).execute()
    end

    class DeleteByQuery

      def initialize( docs, query, params = nil )
        @docs    = docs
        @query     = query
        @params    = params
        @responses = []
      end

      attr_reader :docs, :query, :params, :responses

      def is_ok( status )
        status.between?(200, 299)
      end

      def categorize ( items )
        {
          "found" => items.count { |i| i["found"] },
          "deleted" => items.count { |i| is_ok(i["status"]) },
          "missing" => items.count { |i| !i["found"] },
          "failed" => items.count { |i| i["found"] && !is_ok(i["status"]) },
        }
      end

      def accumulate( response )
        @responses << response unless response == nil
      end

      def execute()
        # accumulate is called both inside and outside the bulk block in order
        # to capture bulk responses returned from calls to `delete` and the call
        # to `bulk`
        accumulate(@docs.bulk(@params) do |b|
          @docs.scan(@query, @params).each_document do |hit|
            accumulate(b.delete(_id: hit["_id"], _type: hit["_type"], _index: hit["_index"]))
          end
        end)

        # collects the array of responses containing arrays of delete action
        # hashes into an array
        response_items = @responses.flat_map { |r| r["items"].map { |i| i["delete"] } }

        indices = Hash[response_items
          .group_by { |i| i["_index"] } # indexes the delete hashes by index name
          .map { |index, items| [index, categorize(items)] }]

        indices_with_all = indices.merge({ "_all" => indices.values.reduce({}) { |acc, i| acc.merge(i) { |_, n, m| n + m } } })

        {
          "took" => @responses.map { |r| r["took"] }.reduce(:+),
          "_indices" => indices_with_all,
          "failures" => response_items.select { |i| !is_ok(i["status"]) },
        }
      end

    end  # DeleteByQuery
  end  # Client
end  # Elastomer
