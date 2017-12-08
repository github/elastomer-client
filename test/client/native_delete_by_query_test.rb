require_relative "../test_helper"

describe Elastomer::Client::NativeDeleteByQuery do
  before do
    @index = $client.index "elastomer-delete-by-query-test"
    @index.delete if @index.exists?
    @docs = @index.docs("docs")
  end

  after do
    @index.delete if @index.exists?
  end

  if supports_native_delete_by_query?
    describe "when an index with documents exists" do
      before do
        @index.create(nil)
        wait_for_index(@index.name)
      end

      it "deletes by query" do
        @docs.index({ :_id => 0, :name => "mittens" })
        @docs.index({ :_id => 1, :name => "luna" })

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
        assert_equal(false, response["timed_out"])
        assert_equal(1, response["batches"])
        assert_equal(1, response["total"])
        assert_equal(1, response["deleted"])
        assert_empty(response["failures"])

        @index.refresh
        response = @docs.multi_get(:ids => [0, 1])
        refute_found response.fetch("docs")[0]
        assert_found response.fetch("docs")[1]
      end

      it "fails when internal version is 0" do
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

        assert_raises(Elastomer::Client::RequestError) do
          @index.native_delete_by_query(query)
        end
      end

      it "fails when an unknown parameter is provided" do
        assert_raises(Elastomer::Client::IllegalArgument) do
          @index.native_delete_by_query({}, foo: "bar")
        end
      end

      it "deletes by query when routing is specified" do
        index = $client.index "elastomer-delete-by-query-routing-test"
        index.delete if index.exists?
        type = "docs"
        index.create({mappings: { type => { _routing: { required: true } } } })
        wait_for_index(@index.name)
        docs = index.docs(type)

        docs.index({ :_id => 0, :_routing => "cat", :name => "mittens" })
        docs.index({ :_id => 1, :_routing => "cat", :name => "luna" })
        docs.index({ :_id => 2, :_routing => "dog", :name => "mittens" })

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
          :docs => [
            { :_id => 0, :_routing => "cat" },
            { :_id => 1, :_routing => "cat" },
            { :_id => 2, :_routing => "dog" },
          ]
        })
        refute_found response["docs"][0]
        assert_found response["docs"][1]
        assert_found response["docs"][2]

        index.delete if index.exists?
      end
    end
  else
    describe "when native _delete_by_query is not supported" do
      it "raises an error" do
        assert_raises(Elastomer::Client::IncompatibleVersionException) do
          @index.native_delete_by_query({query: {match_all: {}}})
        end
      end
    end
  end
end
