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
  strict_params: true
}
$client = Elastomer::Client.new(**$client_params)

# ensure we have an Elasticsearch server to test with
raise "No server available at #{$client.url}" unless $client.available?

puts "Elasticsearch version is #{$client.version}"

# COMPATIBILITY
# Returns true if the Elasticsearch cluster defaults to supporting compression.
def supports_compressed_bodies_by_default?
  $client.version_support.es_version_5_plus?
end

# Now that we have the version, re-create the client with compression if supported.
if supports_compressed_bodies_by_default?
  $client = Elastomer::Client.new(**$client_params.merge(compress_body: true))
end

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
# ES 5.6+ returns an error when an alias does not exist for a full or partial match
def fetching_non_existent_alias_returns_error?
  $client.version_support.es_version_5_plus?
end

# COMPATIBILITY
# ES 5.6+ includes a _nodes key in the /_cluster/stats response. Strangely
# enough, this is not documented in the example response:
# https://www.elastic.co/guide/en/elasticsearch/reference/5.6/cluster-stats.html
def cluster_stats_includes_underscore_nodes?
  $client.version_support.es_version_5_plus?
end

# COMPATIBILITY
# ES 2.0 deprecated the `filtered` query type. ES 5.0 removed it entirely.
def filtered_query_removed?
  $client.version_support.es_version_5_plus?
end

# ES 5.6 percolator queries/document submissions require that an appropriate
# percolator type and field within that type are defined on the index mappings
def requires_percolator_mapping?
  $client.version_support.es_version_5_plus?
end

# COMPATIBILITY
# ES 5 removes the `output` option for fields.
# See: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/breaking_50_suggester.html#_simpler_completion_indexing
def supports_suggest_output?
  $client.version_support.es_version_2_x?
end

# COMPATIBILITY
# ES 5+ returns information about the number of cleared scroll IDs
def returns_cleared_scroll_id_info?
  $client.version_support.es_version_5_plus?
end

# COMPATIBILITY
# Return a Hash with an unsupported indexing directive key/value to test fail-fast.
def incompatible_indexing_directive
  if $client.version_support.es_version_2_x?
    {_wait_for_active_shards: 10}
  else
    {_consistency: "all"}
  end
end

# COMPATIBILITY
# Returns true if the Elasticsearch cluster will validate request parameters.
def parameter_validation?
  $client.version_support.es_version_5_plus?
end

# ES 5 supports native _delete_by_query, but the output and semantics are
# different than the plugin which we modeled our delete by query on.
def supports_native_delete_by_query?
  $client.version_support.native_delete_by_query?
end

# COMPATIBILITY
# ES 7 drops mapping types, so don't wrap with a mapping type for ES 7+
def mappings_wrapper(type, body)
  if $client.version_support.es_version_7_plus?
    body
  else
    {
      :_default_ => {
        :dynamic => "strict"
      },
      type => body
    }
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
