module Elastomer
  class Client

    class DeleteByQuery

      def initialize( client, query, params = nil )
        @client    = client
        @query     = query
        @params    = params
        @responses = []
      end

      attr_reader :client, :query, :params, :responses

      def is_ok( status )
        status.between?(200, 299)
      end

      def categorize( items )
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
        accumulate(@client.bulk(@params) do |b|
          @client.scan(@query, @params).each_document do |hit|
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
