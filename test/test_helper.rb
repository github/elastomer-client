require "rubygems" unless defined? Gem
require "bundler"
Bundler.require(:default, :development)

require "webmock/minitest"
WebMock.allow_net_connect!

require "securerandom"

if ENV["COVERAGE"] == "true"
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/vendor/"
  end
end

require "minitest/spec"
require "minitest/autorun"

# push the lib folder onto the load path
$LOAD_PATH.unshift "lib"
require "elastomer/client"

# we are going to use the same client instance everywhere!
# the client should always be stateless
$client_params = {
  :port => ENV.fetch("ES_PORT", 9200),
  :read_timeout => 10,
  :open_timeout => 1,
  :opaque_id => false
}
$client = Elastomer::Client.new $client_params

# ensure we have an Elasticsearch server to test with
raise "No server available at #{$client.url}" unless $client.available?

puts "Elasticsearch version is #{$client.version}"

# remove any lingering test indices from the cluster
MiniTest.after_run do
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
require File.expand_path("../assertions", __FILE__)

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
def wait_for_index(name, status="yellow")
  $client.cluster.health(
    :index           => name,
    :wait_for_status => status,
    :timeout         => "5s"
  )
end

def default_index_settings
  {settings: {index: {number_of_shards: 1, number_of_replicas: 0}}}
end

def run_snapshot_tests?
  unless defined? $run_snapshot_tests
    begin
      create_repo("elastomer-client-snapshot-test")
      $run_snapshot_tests = true
    rescue Elastomer::Client::Error
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
  location = File.join(*[ENV["SNAPSHOT_DIR"], name].compact)
  default_settings = {:type => "fs", :settings => {:location => location}}
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

# The methods below are to support intention-revealing names about version
# differences in the tests. If necessary for general operation they can be moved
# into Elastomer::VersionSupport.

# COMPATIBILITY
# ES 5.x returns `index` bulk request as `index` responses whether or not the
# document was created or updated. ES 2.x returns a `create` response if it was
# created.
def bulk_index_returns_create_for_new_documents?
  $client.version_support.es_version_2_x?
end

# COMPATIBILITY
# ES 5.x drops support for index-time payloads
def index_time_payloads?
  $client.version_support.es_version_2_x?
end

# COMPATIBILITY
# ES 2.x returns an empty result when an alias does not exist for a full or partial match
# ES 5.6 returns an error when an alias does not exist for a full or partial match
def fetching_non_existent_alias_returns_error?
  $client.version_support.es_version_5_x?
end

# COMPATIBILITY
# ES 5.6 includes a _nodes key in the /_cluster/stats response. Strangely
# enough, this is not documented in the example response:
# https://www.elastic.co/guide/en/elasticsearch/reference/5.6/cluster-stats.html
def cluster_stats_includes_underscore_nodes?
  $client.version_support.es_version_5_x?
end

# COMPATIBILITY
# ES 5.6 percolator queries/document submissions require that an appropriate
# percolator type and field within that type are defined on the index mappings
def requires_percolator_mapping?
  $client.version_support.es_version_5_x?
end

