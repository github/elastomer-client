require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Percolator do

  before do
    @index = $client.index "elastomer-percolator-test"
    @index.delete if @index.exists?
    @docs = @index.docs("docs")
  end

  after do
    @index.delete if @index.exists?
  end

  describe "when an index exists" do
    before do
      @index.create(nil)
      wait_for_index(@index_name)
    end

    it 'creates a query' do
      percolator = @index.percolator "1"
      response = percolator.create :query => { :match_all => { } }
      assert response["created"], "Couldn't create the percolator query"
    end

    it 'gets a query' do
      percolator = @index.percolator "1"
      percolator.create :query => { :match_all => { } }
      response = percolator.get
      assert response["found"], "Couldn't find the percolator query"
    end

    it 'deletes a query' do
      percolator = @index.percolator "1"
      percolator.create :query => { :match_all => { } }
      response = percolator.delete
      assert response["found"], "Couldn't find the percolator query"
    end

    it 'checks for the existence of a query' do
      percolator = @index.percolator "1"
      refute percolator.exists?, "Percolator query exists"
      percolator.create :query => { :match_all => { } }
      assert percolator.exists?, "Percolator query does not exist"
    end

    it 'cannot delete all percolators by providing a nil id' do
      assert_raises(ArgumentError) { percolator = @index.percolator nil }
    end
  end
end
