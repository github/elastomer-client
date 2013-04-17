require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Bulk do

  before do
    @name  = 'elastomer-bulk-test'
    @index = $client.index(@name)

    unless @index.exists?
      @index.create \
        :settings => { 'index.number_of_shards' => 1, 'index.number_of_replicas' => 0 },
        :mappings => {
          :tweet => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :message => { :type => 'string', :analyzer => 'standard' },
              :author  => { :type => 'string', :index => 'not_analyzed' }
            }
          },
          :book => {
            :_source => { :enabled => true }, :_all => { :enabled => false },
            :properties => {
              :title  => { :type => 'string', :analyzer => 'standard' },
              :author => { :type => 'string', :index => 'not_analyzed' }
            }
          }
        }

      $client.cluster.health \
        :index           => @name,
        :wait_for_status => 'green',
        :timeout         => '5s'
    end
  end

  after do
    @index.delete if @index.exists?
  end


end
