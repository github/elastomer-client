require 'rubygems' unless defined? Gem
require 'bundler/setup'

require 'minitest/spec'
require 'minitest/autorun'

# push the lib folder onto the load path
$LOAD_PATH.unshift 'lib'
require 'elastomer'

# we are going to use the same client instance everywhere!
# the client should always be stateless
$client_params = {
  :port => ENV['GH_ELASTICSEARCH_PORT'] || 9200,
  :open_timeout => 1,
  :read_timeout => 1
}
$client = Elastomer::Client.new $client_params

# ensure we have an ElasticSearch server to test with
raise "No server available at #{$client.url}" unless $client.available?

