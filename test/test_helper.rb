require 'securerandom'
require 'rubygems' unless defined? Gem
require 'bundler'
Bundler.require(:default, :development)

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/vendor/"
  end
end

require 'minitest/spec'
require 'minitest/autorun'

# push the lib folder onto the load path
$LOAD_PATH.unshift 'lib'
require 'elastomer/client'

# we are going to use the same client instance everywhere!
# the client should always be stateless
$client_params = {
  :port => ENV['BOXEN_ELASTICSEARCH_PORT'] || 9200,
  :read_timeout => 2,
  :open_timeout => 1,
  :opaque_id => true
}
$client = Elastomer::Client.new $client_params

# ensure we have an ElasticSearch server to test with
raise "No server available at #{$client.url}" unless $client.available?

puts "Elasticsearch version is #{$client.version}"

# remove any lingering test indices from the cluster
MiniTest::Unit.after_tests do
  $client.cluster.indices.keys.each do |name|
    next unless name =~ /^elastomer-/i
    $client.index(name).delete
  end

  $client.cluster.templates.keys.each do |name|
    next unless name =~ /^elastomer-/i
    $client.template(name).delete
  end
end

# add custom assertions
require File.expand_path('../assertions', __FILE__)

# require 'elastomer/notifications'
# require 'pp'

# ActiveSupport::Notifications.subscribe('request.client.elastomer') do |name, start_time, end_time, transaction_id, payload|
#   $stdout.puts '-'*100
#   #$stdout.puts "-- #{payload[:action].inspect}"
#   pp payload #if payload[:action].nil?
# end

# Wait for an index to be created. Since index creation requests return
# before the index is actually ready to receive documents, one needs to wait
# until the cluster status recovers before proceeding.
#
#   name   - The index name to wait for
#   status - The status to wait for. Defaults to yellow. Yellow is the
#            preferred status for tests, because it waits for at least one
#            shard to be active, but doesn't wait for all replicas. Single
#            node clusters will never achieve green status with the default
#            setting of 1 replica.
#
# Returns the cluster health response.
# Raises Elastomer::Client::TimeoutError if requested status is not achieved
# within 5 seconds.
def wait_for_index(name, status='yellow')
  $client.cluster.health(
    :index           => name,
    :wait_for_status => status,
    :timeout         => '5s'
  )
end

# Elasticsearch 1.0 changed some request formats in a non-backward-compatible
# way. Some tests need to know what version is running to structure requests
# as expected.
#
# Returns true if Elasticsearch version is 1.x.
def es_version_1_x?
  $client.semantic_version >= '1.0.0'
end

# Elasticsearch 1.4 changed the response body for interacting with index
# alaises. If an index does not contain any aliases, then an "alises" key is no
# longer returned in the resopsne.
#
# Reeturns `true` if the response contains an "alises" key.
def es_version_always_returns_aliases?
  $client.semantic_version <= '1.4.0' ||
  $client.semantic_version >= '1.4.3'
end

# ElasticSearch 1.3 added the `search_shards` API endpoint.
def es_version_supports_search_shards?
  $client.semantic_version >= '1.3.0'
end

# Elasticsearch 1.2 removed support for gateway snapshots.
#
# Returns true if Elasticsearch version supports gateway snapshots.
def es_version_supports_gateway_snapshots?
  $client.semantic_version <= '1.2.0'
end

# Elasticsearch 1.6 requires the repo.path setting when creating
# FS repositories.
def es_version_requires_repo_path?
  $client.semantic_version >= '1.6.0'
end

def run_snapshot_tests?
  unless defined? $run_snapshot_tests
    begin
      create_repo("elastomer-client-snapshot-test")
      $run_snapshot_tests = true
    rescue Elastomer::Client::Error => e
      puts "Could not create a snapshot repo. Snapshot tests will be disabled."
      puts "To enable snapshot tests, add a path.repo setting to your elasticsearch.yml file."
      $run_snapshot_tests = false
    ensure
      delete_repo("elastomer-client-snapshot-test")
    end
  end
  $run_snapshot_tests
end

def create_repo(name, settings = {})
  location = File.join(*[ENV['SNAPSHOT_DIR'], name].compact)
  default_settings = {:type => 'fs', :settings => {:location => location}}
  $client.repository(name).create(default_settings.merge(settings))
end

def delete_repo(name)
  repo = $client.repository(name)
  repo.delete if repo.exists?
end

def delete_repo_snapshots(name)
  repo = $client.repository(name)
  if repo.exists?
    response = repo.snapshots.get
    response["snapshots"].each do |snapshot_info|
      repo.snapshot(snapshot_info["snapshot"]).delete
    end
  end
end

def with_tmp_repo(name = SecureRandom.uuid, &block)
  begin
    create_repo(name)
    yield $client.repository(name)
  ensure
    delete_repo_snapshots(name)
    delete_repo(name)
  end
end

def create_snapshot(repo, name = SecureRandom.uuid)
  repo.snapshot(name).create({}, :wait_for_completion => true)
end

def with_tmp_snapshot(name = SecureRandom.uuid, &block)
  with_tmp_repo do |repo|
    create_snapshot(repo, name)
    yield repo.snapshot(name), repo
  end
end
