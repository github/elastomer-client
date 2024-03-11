# frozen_string_literal: true

require_relative "../test_helper"

describe ElastomerClient::Client::UpdateByQuery do
  before do
    @index = $client.index "elastomer-update-by-query-test"
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

    it "updates by query" do
      @docs.index({ _id: 0, name: "mittens" })
      @docs.index({ _id: 1, name: "luna" })

      @index.refresh

      query = {
        query: {
          match: {
            name: "mittens"
          }
        },
        script: {
          source: "ctx._source.name = 'mittens updated'"
        }
      }

      response = @index.update_by_query(query)

      refute_nil response["took"]
      refute(response["timed_out"])
      assert_equal(1, response["batches"])
      assert_equal(1, response["total"])
      assert_equal(1, response["updated"])
      assert_empty(response["failures"])

      @index.refresh
      response = @docs.multi_get(ids: [0, 1])

      assert_equal "mittens updated", response.fetch("docs")[0]["_source"]["name"]
      assert_equal "luna", response.fetch("docs")[1]["_source"]["name"]
    end

    it "fails when internal version is 0" do
      if $client.version_support.es_version_7_plus?
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
        @index.update_by_query(query)
      end
    end

    it "fails when an unknown parameter is provided" do
      assert_raises(ElastomerClient::Client::IllegalArgument) do
        @index.update_by_query({}, foo: "bar")
      end
    end

    it "updates by query when routing is specified" do
      index = $client.index "elastomer-update-by-query-routing-test"
      index.delete if index.exists?
      type = "docs"
      # default number of shards in ES8 is 1, so set it to 2 shards so routing to different shards can be tested
      settings = $client.version_support.es_version_7_plus? ? { number_of_shards: 2 } : {}
      index.create({
        settings:,
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
        },
        script: {
          source: "ctx._source.name = 'mittens updated'"
        }
      }

      index.refresh
      response = index.update_by_query(query, routing: "cat")

      assert_equal(1, response["updated"])

      response = docs.multi_get({
        docs: [
          { _id: 0, routing: "cat" },
          { _id: 1, routing: "cat" },
          { _id: 2, routing: "dog" },
        ]
      })

      assert_equal "mittens updated", response.fetch("docs")[0]["_source"]["name"]
      assert_equal "luna", response.fetch("docs")[1]["_source"]["name"]
      assert_equal "mittens", response.fetch("docs")[2]["_source"]["name"]

      index.delete if index.exists?
    end
  end
end
