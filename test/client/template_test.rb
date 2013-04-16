require File.expand_path('../../test_helper', __FILE__)

describe Elastomer::Client::Cluster do

  before do
    @name = 'elastomer-template-test'
    @template = $client.template @name
  end

  after do
    @template.delete if @template.exists?
  end

  it 'creates a template' do
    assert !@template.exists?, 'the template should not exist'

    @template.create({
      :template => 'test-elastomer*',
      :settings => { :number_of_shards => 3 },
      :mappings => {
        :doco => { :_source => { :enabled => false }}
      }
    })

    assert @template.exists?, ' we now have a cluster-test template'

    template = @template.get
    assert_equal [@name], template.keys
    assert_equal 'test-elastomer*', template[@name]['template']
    assert_equal '3', template[@name]['settings']['index.number_of_shards']
  end

end
