require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Warmer do
  before do
    @name  = 'elastomer-warmer-test'
    @index = $client.index(@name)

    unless @index.exists?
      @index.create(
        :settings => { 'index.number_of_shards' => 1, 'index.number_of_replicas' => 0 },
        :mappings => {
          :tweet => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :message => { :type => 'string', :analyzer => 'standard' },
              :author  => { :type => 'string', :index => 'not_analyzed' }
            }
          }
        }
      )
      $client.cluster.health(
        :index           => @name,
        :wait_for_status => 'green',
        :timeout         => '5s'
      )
    end
  end

  after do
    @index.delete if @index.exists?
  end

  it 'creates warmers' do
    h = @index.warmer('test1').create(:query => { :match_all => {}})
    assert_equal true, h["ok"]
  end

  it 'deletes warmers' do
    @index.warmer('test1').create(:query => { :match_all => {}})

    h = @index.warmer('test1').delete
    assert_equal true, h["ok"]
  end

  it 'gets warmers' do
    body = { "query" => {"match_all" => {}}}
    @index.warmer('test1').create(body)

    h = @index.warmer('test1').get
    assert_equal body, h[@name]["warmers"]["test1"]["source"]
  end
end
