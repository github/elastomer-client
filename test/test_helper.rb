# frozen_string_literal: true

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
require "minitest/focus"

# used in a couple test files, makes them available for all
require "active_support/core_ext/enumerable"
require "active_support/core_ext/hash"

# push the lib folder onto the load path
$LOAD_PATH.unshift "lib"
require "elastomer/client"

# we are going to use the same client instance everywhere!
# the client should always be stateless
$client_params = {
  port: ENV.fetch("ES_PORT", 9200),
  read_timeout: 10,
  open_timeout: 1,
  opaque_id: false,
  strict_params: true,
  compress_body: true
}
$client = ElastomerClient::Client.new(**$client_params)

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
# Raises ElastomerClient::Client::TimeoutError if requested status is not achieved
# within 5 seconds.
def wait_for_index(name, status = "yellow")
  $client.cluster.health(
    index: name,
    wait_for_status: status,
    timeout: "5s"
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
    rescue ElastomerClient::Client::Error
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
  default_settings = {type: "fs", settings: {location: location}}
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
  repo.snapshot(name).create({}, wait_for_completion: true)
end

def with_tmp_snapshot(name = SecureRandom.uuid, &block)
  with_tmp_repo do |repo|
    create_snapshot(repo, name)
    yield repo.snapshot(name), repo
  end
end

# Just some busy work in the background for tasks API to detect in test cases
#
# Returns the thread and index references so caller can join the thread and delete
# the index after the checks are performed
def populate_background_index!(name)
  # make an index with a new client (in this thread, to avoid query check race after)
  name.freeze
  index = $client.dup.index(name)
  docs = index.docs("widget")

  # do some busy work in background thread to generate bulk-indexing tasks we
  # can query at the caller. return the thread ref so caller can join on it
  Thread.new do
    100.times.each do |i|
      docs.bulk do |d|
        (1..500).each do |j|
          d.index \
            foo: "foo_#{i}_#{j}",
            bar: "bar_#{i}_#{j}",
            baz: "baz_#{i}_#{j}"
        end
      end
      index.refresh
    end
  end
end

# when populate_background_index! is running, this query returns healthcheck tasks
# that are long-running enough to be queried again for verification in test cases
def query_long_running_tasks
  Kernel.sleep(0.01)
  target_tasks = []
  100.times.each do
    target_tasks = @tasks.get["nodes"]
      .map { |k, v| v["tasks"] }
      .flatten.map { |ts| ts.select { |k, v| /bulk/ =~ v["action"] } }
      .flatten.reject { |t| t.empty? }
    break if target_tasks.size > 0
  end

  target_tasks
end

# The methods below are to support intention-revealing names about version
# differences in the tests. If necessary for general operation they can be moved
# into ElastomerClient::VersionSupport.

# COMPATIBILITY
# ES 7 drops mapping types, so don't wrap with a mapping type for ES 7+
def mappings_wrapper(type, body, disable_all = false)
  if $client.version_support.es_version_7_plus?
    body
  else
    mapping = {
      _default_: {
        dynamic: "strict"
      }
    }
    mapping[type] = body
    if disable_all then mapping[type]["_all"] = { "enabled": false } end
    mapping
  end
end

# COMPATIBILITY
# ES 7 drops mapping types, so append type to the document only if ES version < 7
def document_wrapper(type, body)
  if $client.version_support.es_version_7_plus?
    body
  else
    body.merge({_type: type})
  end
end
