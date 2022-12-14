# frozen_string_literal: true

require_relative "../test_helper"

describe Elastomer::Client::AppDeleteByQuery do

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
      response = @index.app_delete_by_query(nil, q: "name:mittens")
      assert_equal({
        "_all" => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
        @index.name => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
      }, response["_indices"])

      @index.refresh
      response = @docs.multi_get ids: [0, 1]
      refute_found response["docs"][0]
      assert_found response["docs"][1]
    end

    it "respects action_count" do
      @docs.index({ _id: 0, name: "mittens" })
      @docs.index({ _id: 1, name: "luna" })
      @index.refresh

      response = @index.app_delete_by_query(nil, action_count: 1)

      assert_requested(:post, /_bulk/, times: 2)

      assert_equal({
        "_all" => {
          "found" => 2,
          "deleted" => 2,
          "missing" => 0,
          "failed" => 0,
        },
        @index.name => {
          "found" => 2,
          "deleted" => 2,
          "missing" => 0,
          "failed" => 0,
        },
      }, response["_indices"])

      @index.refresh
      response = @docs.multi_get ids: [0, 1]
      refute_found response["docs"][0]
      refute_found response["docs"][1]
    end

    it "counts missing documents" do
      @docs.index({ _id: 0 })

      stub_request(:post, /_bulk/).
        to_return(lambda do |request|
          {
            body: MultiJson.dump({
              "took" => 0,
              "errors" => false,
              "items" => [{
                "delete" => {
                  "_index" => @index.name,
                  "_type" => @docs.name,
                  "_id" => 0,
                  "_version" => 1,
                  "status" => 404,
                  "found" => false } }] }) }
        end)

      @index.refresh
      response = @index.app_delete_by_query(nil, action_count: 1)
      assert_equal({
        "_all" => {
          "found" => 0,
          "deleted" => 0,
          "missing" => 1,
          "failed" => 0,
        },
        @index.name => {
          "found" => 0,
          "deleted" => 0,
          "missing" => 1,
          "failed" => 0,
        },
      }, response["_indices"])
    end

    it "counts failed operations" do
      @docs.index({ _id: 0 })

      stub_request(:post, /_bulk/).
        to_return(lambda do |request|
          {
            body: MultiJson.dump({
              "took" => 0,
              "errors" => false,
              "items" => [{
                "delete" => {
                  "_index" => @index.name,
                  "_type" => @docs.name,
                  "_id" => 0,
                  "status" => 409,
                  "error" => "VersionConflictEngineException" } }] }) }
        end)

      @index.refresh
      response = @index.app_delete_by_query(nil, action_count: 1)
      assert_equal({
        "_all" => {
          "found" => 1,
          "deleted" => 0,
          "missing" => 0,
          "failed" => 1,
        },
        @index.name => {
          "found" => 1,
          "deleted" => 0,
          "missing" => 0,
          "failed" => 1,
        },
      }, response["_indices"])
    end

    it "deletes by query when routing is specified" do
      index = $client.index "elastomer-delete-by-query-routing-test"
      index.delete if index.exists?
      type = "docs"
      index.create({ mappings: { type => { _routing: { required: true } } } })
      wait_for_index(@index.name)
      docs = index.docs(type)

      docs.index({ _id: 0, _routing: "cat", name: "mittens" })
      docs.index({ _id: 1, _routing: "cat", name: "luna" })

      index.refresh
      response = index.app_delete_by_query(nil, q: "name:mittens")
      assert_equal({
        "_all" => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
        index.name => {
          "found" => 1,
          "deleted" => 1,
          "missing" => 0,
          "failed" => 0,
        },
      }, response["_indices"])

      index.refresh
      response = docs.multi_get({
        docs: [
          { _id: 0, _routing: "cat" },
          { _id: 1, _routing: "cat" },
        ]
      })
      refute_found response["docs"][0]
      assert_found response["docs"][1]

      index.delete if index.exists?
    end
  end
end
