# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::NativeDeleteByQuery do
  before do
    @index = $client.index "elastomer-delete-by-query-test"
    @index.delete if @index.exists?
    @docs = @index.docs("docs")
  end

  after do
    @index.delete if @index.exists?
  end

  describe "when an index with documents exists" do
    before do
      @index.create(nil)
      wait_for_index(@index.name)
    end

    it "deletes by query" do
      @docs.index({ _id: 0, name: "mittens" })
      @docs.index({ _id: 1, name: "luna" })

      @index.refresh

      query = {
        query: {
          match: {
            name: "mittens"
          }
        }
      }

      response = @index.native_delete_by_query(query)

      refute_nil response["took"]
      refute(response["timed_out"])
      assert_equal(1, response["batches"])
      assert_equal(1, response["total"])
      assert_equal(1, response["deleted"])
      assert_empty(response["failures"])

      @index.refresh
      response = @docs.multi_get(ids: [0, 1])

      refute_found response.fetch("docs")[0]
      assert_found response.fetch("docs")[1]
    end

    it "fails when internal version is 0" do
      if $client.version_support.es_version_8_plus?
        skip "Concurrency control with internal version is not supported in ES #{$client.version}"
      end
      @docs.index({_id: 0, name: "mittens"})
      # Creating a document with external version 0 also sets the internal version to 0
      # Otherwise you can't index a document with version 0.
      @docs.index({_id: 1, _version: 0, _version_type: "external", name: "mittens"})
      @index.refresh

      query = {
        query: {
          match: {
            name: "mittens"
          }
        }
      }

      assert_raises(ElastomerClient::Client::RequestError) do
        @index.native_delete_by_query(query)
      end
    end

    it "fails when an unknown parameter is provided" do
      assert_raises(ElastomerClient::Client::IllegalArgument) do
        @index.native_delete_by_query({}, foo: "bar")
      end
    end

    it "deletes by query when routing is specified" do
      index = $client.index "elastomer-delete-by-query-routing-test"
      index.delete if index.exists?
      type = "docs"
      # default number of shards in ES8 is 1, so set it to 2 shards so routing to different shards can be tested
      settings = $client.version_support.es_version_8_plus? ? { number_of_shards: 2 } : {}
      index.create({
        settings: settings,
        mappings: mappings_wrapper(type, {
          properties: {
            name: { type: "text", analyzer: "standard" },
          },
          _routing: { required: true }
        })
      })
      wait_for_index(@index.name)
      docs = index.docs(type)

      docs.index({ _id: 0, _routing: "cat", name: "mittens" })
      docs.index({ _id: 1, _routing: "cat", name: "luna" })
      docs.index({ _id: 2, _routing: "dog", name: "mittens" })

      query = {
        query: {
          match: {
            name: "mittens"
          }
        }
      }

      index.refresh
      response = index.native_delete_by_query(query, routing: "cat")

      assert_equal(1, response["deleted"])

      response = docs.multi_get({
        docs: [
          { _id: 0, routing: "cat" },
          { _id: 1, routing: "cat" },
          { _id: 2, routing: "dog" },
        ]
      })

      refute_found response["docs"][0]
      assert_found response["docs"][1]
      assert_found response["docs"][2]

      index.delete if index.exists?
    end
  end
end
