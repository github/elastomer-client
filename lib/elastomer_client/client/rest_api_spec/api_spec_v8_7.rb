# frozen_string_literal: true
# Generated REST API spec file - DO NOT EDIT!
# Date: 2023-11-30
# ES version: 8.7

module ElastomerClient::Client::RestApiSpec
  class ApiSpecV8_7 < ApiSpec
    def initialize
      @rest_apis = {
        "_internal.delete_desired_nodes" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-desired-nodes.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_internal/desired_nodes",
            paths: ["/_internal/desired_nodes"],
          }
        ),
        "_internal.get_desired_balance" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-desired-balance.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_internal/desired_balance",
            paths: ["/_internal/desired_balance"],
          }
        ),
        "_internal.get_desired_nodes" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-desired-nodes.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_internal/desired_nodes/_latest",
            paths: ["/_internal/desired_nodes/_latest"],
          }
        ),
        "_internal.prevalidate_node_removal" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/prevalidate-node-removal-api.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_internal/prevalidate_node_removal",
            paths: ["/_internal/prevalidate_node_removal"],
            params: [
              "names",
              "ids",
              "external_ids",
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "_internal.update_desired_nodes" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/update-desired-nodes.html",
          methods: ["PUT"],
          body: {"description"=>"the specification of the desired nodes", "required"=>true},
          url: {
            path: "/_internal/desired_nodes/{history_id}/{version}",
            paths: ["/_internal/desired_nodes/{history_id}/{version}"],
            parts: [
              "history_id",
              "version",
            ],
            params: [
              "dry_run",
            ]
          }
        ),
        "async_search.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/async-search.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_async_search/{id}",
            paths: ["/_async_search/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "async_search.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/async-search.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_async_search/{id}",
            paths: ["/_async_search/{id}"],
            parts: [
              "id",
            ],
            params: [
              "wait_for_completion_timeout",
              "keep_alive",
              "typed_keys",
            ]
          }
        ),
        "async_search.status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/async-search.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_async_search/status/{id}",
            paths: ["/_async_search/status/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "async_search.submit" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/async-search.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/_async_search",
            paths: ["/_async_search", "/{index}/_async_search"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_completion_timeout",
              "keep_on_completion",
              "keep_alive",
              "batched_reduce_size",
              "request_cache",
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "explain",
              "stored_fields",
              "docvalue_fields",
              "from",
              "ignore_unavailable",
              "ignore_throttled",
              "allow_no_indices",
              "expand_wildcards",
              "lenient",
              "preference",
              "q",
              "routing",
              "search_type",
              "size",
              "sort",
              "_source",
              "_source_excludes",
              "_source_includes",
              "terminate_after",
              "stats",
              "suggest_field",
              "suggest_mode",
              "suggest_size",
              "suggest_text",
              "timeout",
              "track_scores",
              "track_total_hits",
              "allow_partial_search_results",
              "typed_keys",
              "version",
              "seq_no_primary_term",
              "max_concurrent_shard_requests",
            ]
          }
        ),
        "autoscaling.delete_autoscaling_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/autoscaling-delete-autoscaling-policy.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_autoscaling/policy/{name}",
            paths: ["/_autoscaling/policy/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "autoscaling.get_autoscaling_capacity" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/autoscaling-get-autoscaling-capacity.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_autoscaling/capacity",
            paths: ["/_autoscaling/capacity"],
          }
        ),
        "autoscaling.get_autoscaling_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/autoscaling-get-autoscaling-policy.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_autoscaling/policy/{name}",
            paths: ["/_autoscaling/policy/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "autoscaling.put_autoscaling_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/autoscaling-put-autoscaling-policy.html",
          methods: ["PUT"],
          body: {"description"=>"the specification of the autoscaling policy", "required"=>true},
          url: {
            path: "/_autoscaling/policy/{name}",
            paths: ["/_autoscaling/policy/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "bulk" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-bulk.html",
          methods: ["POST", "PUT"],
          body: {"description"=>"The operation definition and data (action-data pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_bulk",
            paths: ["/_bulk", "/{index}/_bulk"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "refresh",
              "routing",
              "timeout",
              "type",
              "_source",
              "_source_excludes",
              "_source_includes",
              "pipeline",
              "require_alias",
            ]
          }
        ),
        "cat.aliases" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-alias.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/aliases",
            paths: ["/_cat/aliases", "/_cat/aliases/{name}"],
            parts: [
              "name",
            ],
            params: [
              "format",
              "local",
              "h",
              "help",
              "s",
              "v",
              "expand_wildcards",
            ]
          }
        ),
        "cat.allocation" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-allocation.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/allocation",
            paths: ["/_cat/allocation", "/_cat/allocation/{node_id}"],
            parts: [
              "node_id",
            ],
            params: [
              "format",
              "bytes",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.component_templates" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-compoentn-templates.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/component_templates",
            paths: ["/_cat/component_templates", "/_cat/component_templates/{name}"],
            parts: [
              "name",
            ],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.count" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-count.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/count",
            paths: ["/_cat/count", "/_cat/count/{index}"],
            parts: [
              "index",
            ],
            params: [
              "format",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.fielddata" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-fielddata.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/fielddata",
            paths: ["/_cat/fielddata", "/_cat/fielddata/{fields}"],
            parts: [
              "fields",
            ],
            params: [
              "format",
              "bytes",
              "h",
              "help",
              "s",
              "v",
              "fields",
            ]
          }
        ),
        "cat.health" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-health.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/health",
            paths: ["/_cat/health"],
            params: [
              "format",
              "h",
              "help",
              "s",
              "time",
              "ts",
              "v",
            ]
          }
        ),
        "cat.help" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat",
            paths: ["/_cat"],
            params: [
              "help",
              "s",
            ]
          }
        ),
        "cat.indices" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-indices.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/indices",
            paths: ["/_cat/indices", "/_cat/indices/{index}"],
            parts: [
              "index",
            ],
            params: [
              "format",
              "bytes",
              "master_timeout",
              "h",
              "health",
              "help",
              "pri",
              "s",
              "time",
              "v",
              "include_unloaded_segments",
              "expand_wildcards",
            ]
          }
        ),
        "cat.master" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-master.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/master",
            paths: ["/_cat/master"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.ml_data_frame_analytics" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/current/cat-dfanalytics.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/ml/data_frame/analytics",
            paths: ["/_cat/ml/data_frame/analytics", "/_cat/ml/data_frame/analytics/{id}"],
            parts: [
              "id",
            ],
            params: [
              "allow_no_match",
              "bytes",
              "format",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.ml_datafeeds" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/current/cat-datafeeds.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/ml/datafeeds",
            paths: ["/_cat/ml/datafeeds", "/_cat/ml/datafeeds/{datafeed_id}"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "allow_no_match",
              "format",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.ml_jobs" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/current/cat-anomaly-detectors.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/ml/anomaly_detectors",
            paths: ["/_cat/ml/anomaly_detectors", "/_cat/ml/anomaly_detectors/{job_id}"],
            parts: [
              "job_id",
            ],
            params: [
              "allow_no_match",
              "bytes",
              "format",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.ml_trained_models" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-trained-model.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/ml/trained_models",
            paths: ["/_cat/ml/trained_models", "/_cat/ml/trained_models/{model_id}"],
            parts: [
              "model_id",
            ],
            params: [
              "allow_no_match",
              "from",
              "size",
              "bytes",
              "format",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.nodeattrs" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-nodeattrs.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/nodeattrs",
            paths: ["/_cat/nodeattrs"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.nodes" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-nodes.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/nodes",
            paths: ["/_cat/nodes"],
            params: [
              "bytes",
              "format",
              "full_id",
              "master_timeout",
              "h",
              "help",
              "s",
              "time",
              "v",
              "include_unloaded_segments",
            ]
          }
        ),
        "cat.pending_tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-pending-tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/pending_tasks",
            paths: ["/_cat/pending_tasks"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.plugins" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-plugins.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/plugins",
            paths: ["/_cat/plugins"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "include_bootstrap",
              "s",
              "v",
            ]
          }
        ),
        "cat.recovery" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-recovery.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/recovery",
            paths: ["/_cat/recovery", "/_cat/recovery/{index}"],
            parts: [
              "index",
            ],
            params: [
              "format",
              "active_only",
              "bytes",
              "detailed",
              "h",
              "help",
              "index",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.repositories" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-repositories.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/repositories",
            paths: ["/_cat/repositories"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.segments" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-segments.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/segments",
            paths: ["/_cat/segments", "/_cat/segments/{index}"],
            parts: [
              "index",
            ],
            params: [
              "format",
              "bytes",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.shards" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-shards.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/shards",
            paths: ["/_cat/shards", "/_cat/shards/{index}"],
            parts: [
              "index",
            ],
            params: [
              "format",
              "bytes",
              "master_timeout",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.snapshots" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-snapshots.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/snapshots",
            paths: ["/_cat/snapshots", "/_cat/snapshots/{repository}"],
            parts: [
              "repository",
            ],
            params: [
              "format",
              "ignore_unavailable",
              "master_timeout",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/tasks",
            paths: ["/_cat/tasks"],
            params: [
              "format",
              "nodes",
              "actions",
              "detailed",
              "parent_task_id",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "cat.templates" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-templates.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/templates",
            paths: ["/_cat/templates", "/_cat/templates/{name}"],
            parts: [
              "name",
            ],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.thread_pool" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cat-thread-pool.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/thread_pool",
            paths: ["/_cat/thread_pool", "/_cat/thread_pool/{thread_pool_patterns}"],
            parts: [
              "thread_pool_patterns",
            ],
            params: [
              "format",
              "time",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.transforms" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-transforms.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/transforms",
            paths: ["/_cat/transforms", "/_cat/transforms/{transform_id}"],
            parts: [
              "transform_id",
            ],
            params: [
              "from",
              "size",
              "allow_no_match",
              "format",
              "h",
              "help",
              "s",
              "time",
              "v",
            ]
          }
        ),
        "ccr.delete_auto_follow_pattern" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-delete-auto-follow-pattern.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ccr/auto_follow/{name}",
            paths: ["/_ccr/auto_follow/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "ccr.follow" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-follow.html",
          methods: ["PUT"],
          body: {"description"=>"The name of the leader index and other optional ccr related parameters", "required"=>true},
          url: {
            path: "/{index}/_ccr/follow",
            paths: ["/{index}/_ccr/follow"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_active_shards",
            ]
          }
        ),
        "ccr.follow_info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-follow-info.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_ccr/info",
            paths: ["/{index}/_ccr/info"],
            parts: [
              "index",
            ],
          }
        ),
        "ccr.follow_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-follow-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_ccr/stats",
            paths: ["/{index}/_ccr/stats"],
            parts: [
              "index",
            ],
          }
        ),
        "ccr.forget_follower" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-forget-follower.html",
          methods: ["POST"],
          body: {"description"=>"the name and UUID of the follower index, the name of the cluster containing the follower index, and the alias from the perspective of that cluster for the remote cluster containing the leader index", "required"=>true},
          url: {
            path: "/{index}/_ccr/forget_follower",
            paths: ["/{index}/_ccr/forget_follower"],
            parts: [
              "index",
            ],
          }
        ),
        "ccr.get_auto_follow_pattern" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-auto-follow-pattern.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ccr/auto_follow",
            paths: ["/_ccr/auto_follow", "/_ccr/auto_follow/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "ccr.pause_auto_follow_pattern" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-pause-auto-follow-pattern.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ccr/auto_follow/{name}/pause",
            paths: ["/_ccr/auto_follow/{name}/pause"],
            parts: [
              "name",
            ],
          }
        ),
        "ccr.pause_follow" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-pause-follow.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_ccr/pause_follow",
            paths: ["/{index}/_ccr/pause_follow"],
            parts: [
              "index",
            ],
          }
        ),
        "ccr.put_auto_follow_pattern" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-auto-follow-pattern.html",
          methods: ["PUT"],
          body: {"description"=>"The specification of the auto follow pattern", "required"=>true},
          url: {
            path: "/_ccr/auto_follow/{name}",
            paths: ["/_ccr/auto_follow/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "ccr.resume_auto_follow_pattern" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-resume-auto-follow-pattern.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ccr/auto_follow/{name}/resume",
            paths: ["/_ccr/auto_follow/{name}/resume"],
            parts: [
              "name",
            ],
          }
        ),
        "ccr.resume_follow" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-resume-follow.html",
          methods: ["POST"],
          body: {"description"=>"The name of the leader index and other optional ccr related parameters", "required"=>false},
          url: {
            path: "/{index}/_ccr/resume_follow",
            paths: ["/{index}/_ccr/resume_follow"],
            parts: [
              "index",
            ],
          }
        ),
        "ccr.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ccr/stats",
            paths: ["/_ccr/stats"],
          }
        ),
        "ccr.unfollow" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-unfollow.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_ccr/unfollow",
            paths: ["/{index}/_ccr/unfollow"],
            parts: [
              "index",
            ],
          }
        ),
        "clear_scroll" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/clear-scroll-api.html",
          methods: ["DELETE"],
          body: {"description"=>"A comma-separated list of scroll IDs to clear if none was specified via the scroll_id parameter"},
          url: {
            path: "/_search/scroll",
            paths: ["/_search/scroll", "/_search/scroll/{scroll_id}"],
            parts: [
              "scroll_id",
            ],
          }
        ),
        "close_point_in_time" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/point-in-time-api.html",
          methods: ["DELETE"],
          body: {"description"=>"a point-in-time id to close"},
          url: {
            path: "/_pit",
            paths: ["/_pit"],
          }
        ),
        "cluster.allocation_explain" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-allocation-explain.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The index, shard, and primary flag to explain. Empty means 'explain a randomly-chosen unassigned shard'"},
          url: {
            path: "/_cluster/allocation/explain",
            paths: ["/_cluster/allocation/explain"],
            params: [
              "include_yes_decisions",
              "include_disk_info",
            ]
          }
        ),
        "cluster.delete_component_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-component-template.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_component_template/{name}",
            paths: ["/_component_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "cluster.delete_voting_config_exclusions" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/voting-config-exclusions.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_cluster/voting_config_exclusions",
            paths: ["/_cluster/voting_config_exclusions"],
            params: [
              "wait_for_removal",
              "master_timeout",
            ]
          }
        ),
        "cluster.exists_component_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-component-template.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/_component_template/{name}",
            paths: ["/_component_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "master_timeout",
              "local",
            ]
          }
        ),
        "cluster.get_component_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-component-template.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_component_template",
            paths: ["/_component_template", "/_component_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "master_timeout",
              "local",
            ]
          }
        ),
        "cluster.get_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-get-settings.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/settings",
            paths: ["/_cluster/settings"],
            params: [
              "flat_settings",
              "master_timeout",
              "timeout",
              "include_defaults",
            ]
          }
        ),
        "cluster.health" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-health.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/health",
            paths: ["/_cluster/health", "/_cluster/health/{index}"],
            parts: [
              "index",
            ],
            params: [
              "expand_wildcards",
              "level",
              "local",
              "master_timeout",
              "timeout",
              "wait_for_active_shards",
              "wait_for_nodes",
              "wait_for_events",
              "wait_for_no_relocating_shards",
              "wait_for_no_initializing_shards",
              "wait_for_status",
            ]
          }
        ),
        "cluster.pending_tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-pending.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/pending_tasks",
            paths: ["/_cluster/pending_tasks"],
            params: [
              "local",
              "master_timeout",
            ]
          }
        ),
        "cluster.post_voting_config_exclusions" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/voting-config-exclusions.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_cluster/voting_config_exclusions",
            paths: ["/_cluster/voting_config_exclusions"],
            params: [
              "node_ids",
              "node_names",
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "cluster.put_component_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-component-template.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The template definition", "required"=>true},
          url: {
            path: "/_component_template/{name}",
            paths: ["/_component_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "create",
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "cluster.put_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-update-settings.html",
          methods: ["PUT"],
          body: {"description"=>"The settings to be updated. Can be either `transient` or `persistent` (survives cluster restart).", "required"=>true},
          url: {
            path: "/_cluster/settings",
            paths: ["/_cluster/settings"],
            params: [
              "flat_settings",
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "cluster.remote_info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-remote-info.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_remote/info",
            paths: ["/_remote/info"],
          }
        ),
        "cluster.reroute" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-reroute.html",
          methods: ["POST"],
          body: {"description"=>"The definition of `commands` to perform (`move`, `cancel`, `allocate`)"},
          url: {
            path: "/_cluster/reroute",
            paths: ["/_cluster/reroute"],
            params: [
              "dry_run",
              "explain",
              "retry_failed",
              "metric",
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "cluster.state" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-state.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/state",
            paths: ["/_cluster/state", "/_cluster/state/{metric}", "/_cluster/state/{metric}/{index}"],
            parts: [
              "metric",
              "index",
            ],
            params: [
              "local",
              "master_timeout",
              "flat_settings",
              "wait_for_metadata_version",
              "wait_for_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "cluster.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/stats",
            paths: ["/_cluster/stats", "/_cluster/stats/nodes/{node_id}"],
            parts: [
              "node_id",
            ],
            params: [
              "flat_settings",
              "timeout",
            ]
          }
        ),
        "count" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-count.html",
          methods: ["POST", "GET"],
          body: {"description"=>"A query to restrict the results specified with the Query DSL (optional)"},
          url: {
            path: "/_count",
            paths: ["/_count", "/{index}/_count"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "ignore_throttled",
              "allow_no_indices",
              "expand_wildcards",
              "min_score",
              "preference",
              "routing",
              "q",
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "lenient",
              "terminate_after",
            ]
          }
        ),
        "create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-index_.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/{index}/_create/{id}",
            paths: ["/{index}/_create/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "refresh",
              "routing",
              "timeout",
              "version",
              "version_type",
              "pipeline",
            ]
          }
        ),
        "dangling_indices.delete_dangling_index" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-gateway-dangling-indices.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_dangling/{index_uuid}",
            paths: ["/_dangling/{index_uuid}"],
            parts: [
              "index_uuid",
            ],
            params: [
              "accept_data_loss",
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "dangling_indices.import_dangling_index" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-gateway-dangling-indices.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_dangling/{index_uuid}",
            paths: ["/_dangling/{index_uuid}"],
            parts: [
              "index_uuid",
            ],
            params: [
              "accept_data_loss",
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "dangling_indices.list_dangling_indices" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-gateway-dangling-indices.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_dangling",
            paths: ["/_dangling"],
          }
        ),
        "delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-delete.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/{index}/_doc/{id}",
            paths: ["/{index}/_doc/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "refresh",
              "routing",
              "timeout",
              "if_seq_no",
              "if_primary_term",
              "version",
              "version_type",
            ]
          }
        ),
        "delete_by_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-delete-by-query.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL", "required"=>true},
          url: {
            path: "/{index}/_delete_by_query",
            paths: ["/{index}/_delete_by_query"],
            parts: [
              "index",
            ],
            params: [
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "from",
              "ignore_unavailable",
              "allow_no_indices",
              "conflicts",
              "expand_wildcards",
              "lenient",
              "preference",
              "q",
              "routing",
              "scroll",
              "search_type",
              "search_timeout",
              "max_docs",
              "sort",
              "terminate_after",
              "stats",
              "version",
              "request_cache",
              "refresh",
              "timeout",
              "wait_for_active_shards",
              "scroll_size",
              "wait_for_completion",
              "requests_per_second",
              "slices",
            ]
          }
        ),
        "delete_by_query_rethrottle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_delete_by_query/{task_id}/_rethrottle",
            paths: ["/_delete_by_query/{task_id}/_rethrottle"],
            parts: [
              "task_id",
            ],
            params: [
              "requests_per_second",
            ]
          }
        ),
        "delete_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-scripting.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_scripts/{id}",
            paths: ["/_scripts/{id}"],
            parts: [
              "id",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "enrich.delete_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-enrich-policy-api.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_enrich/policy/{name}",
            paths: ["/_enrich/policy/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "enrich.execute_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/execute-enrich-policy-api.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/_enrich/policy/{name}/_execute",
            paths: ["/_enrich/policy/{name}/_execute"],
            parts: [
              "name",
            ],
            params: [
              "wait_for_completion",
            ]
          }
        ),
        "enrich.get_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-enrich-policy-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_enrich/policy/{name}",
            paths: ["/_enrich/policy/{name}", "/_enrich/policy"],
            parts: [
              "name",
            ],
          }
        ),
        "enrich.put_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-enrich-policy-api.html",
          methods: ["PUT"],
          body: {"description"=>"The enrich policy to register", "required"=>true},
          url: {
            path: "/_enrich/policy/{name}",
            paths: ["/_enrich/policy/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "enrich.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/enrich-stats-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_enrich/_stats",
            paths: ["/_enrich/_stats"],
          }
        ),
        "eql.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/eql-search-api.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_eql/search/{id}",
            paths: ["/_eql/search/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "eql.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/eql-search-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_eql/search/{id}",
            paths: ["/_eql/search/{id}"],
            parts: [
              "id",
            ],
            params: [
              "wait_for_completion_timeout",
              "keep_alive",
            ]
          }
        ),
        "eql.get_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/eql-search-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_eql/search/status/{id}",
            paths: ["/_eql/search/status/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "eql.search" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/eql-search-api.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Eql request body. Use the `query` to limit the query scope.", "required"=>true},
          url: {
            path: "/{index}/_eql/search",
            paths: ["/{index}/_eql/search"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_completion_timeout",
              "keep_on_completion",
              "keep_alive",
            ]
          }
        ),
        "exists" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-get.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}/_doc/{id}",
            paths: ["/{index}/_doc/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "stored_fields",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
              "version",
              "version_type",
            ]
          }
        ),
        "exists_source" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-get.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}/_source/{id}",
            paths: ["/{index}/_source/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
              "version",
              "version_type",
            ]
          }
        ),
        "explain" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-explain.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The query definition using the Query DSL"},
          url: {
            path: "/{index}/_explain/{id}",
            paths: ["/{index}/_explain/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "analyze_wildcard",
              "analyzer",
              "default_operator",
              "df",
              "stored_fields",
              "lenient",
              "preference",
              "q",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
            ]
          }
        ),
        "features.get_features" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-features-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_features",
            paths: ["/_features"],
            params: [
              "master_timeout",
            ]
          }
        ),
        "features.reset_features" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_features/_reset",
            paths: ["/_features/_reset"],
          }
        ),
        "field_caps" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-field-caps.html",
          methods: ["GET", "POST"],
          body: {"description"=>"An index filter specified with the Query DSL"},
          url: {
            path: "/_field_caps",
            paths: ["/_field_caps", "/{index}/_field_caps"],
            parts: [
              "index",
            ],
            params: [
              "fields",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "include_unmapped",
              "filters",
              "types",
            ]
          }
        ),
        "fleet.global_checkpoints" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-global-checkpoints.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_fleet/global_checkpoints",
            paths: ["/{index}/_fleet/global_checkpoints"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_advance",
              "wait_for_index",
              "checkpoints",
              "timeout",
            ]
          }
        ),
        "fleet.msearch" => RestApi.new(
          documentation: "",
          methods: ["GET", "POST"],
          body: {"description"=>"The request definitions (metadata-fleet search request definition pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_fleet/_fleet_msearch",
            paths: ["/_fleet/_fleet_msearch", "/{index}/_fleet/_fleet_msearch"],
            parts: [
              "index",
            ],
          }
        ),
        "fleet.search" => RestApi.new(
          documentation: "",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/{index}/_fleet/_fleet_search",
            paths: ["/{index}/_fleet/_fleet_search"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_checkpoints",
              "wait_for_checkpoints_timeout",
              "allow_partial_search_results",
            ]
          }
        ),
        "get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-get.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_doc/{id}",
            paths: ["/{index}/_doc/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "force_synthetic_source",
              "stored_fields",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
              "version",
              "version_type",
            ]
          }
        ),
        "get_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-scripting.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_scripts/{id}",
            paths: ["/_scripts/{id}"],
            parts: [
              "id",
            ],
            params: [
              "master_timeout",
            ]
          }
        ),
        "get_script_context" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/painless/master/painless-contexts.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_script_context",
            paths: ["/_script_context"],
          }
        ),
        "get_script_languages" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-scripting.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_script_language",
            paths: ["/_script_language"],
          }
        ),
        "get_source" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-get.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_source/{id}",
            paths: ["/{index}/_source/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
              "version",
              "version_type",
            ]
          }
        ),
        "graph.explore" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/graph-explore-api.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Graph Query DSL"},
          url: {
            path: "/{index}/_graph/explore",
            paths: ["/{index}/_graph/explore"],
            parts: [
              "index",
            ],
            params: [
              "routing",
              "timeout",
            ]
          }
        ),
        "health_report" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/health-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_health_report",
            paths: ["/_health_report", "/_health_report/{feature}"],
            parts: [
              "feature",
            ],
            params: [
              "timeout",
              "verbose",
              "size",
            ]
          }
        ),
        "ilm.delete_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-delete-lifecycle.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ilm/policy/{policy}",
            paths: ["/_ilm/policy/{policy}"],
            parts: [
              "policy",
            ],
          }
        ),
        "ilm.explain_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-explain-lifecycle.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_ilm/explain",
            paths: ["/{index}/_ilm/explain"],
            parts: [
              "index",
            ],
            params: [
              "only_managed",
              "only_errors",
            ]
          }
        ),
        "ilm.get_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-get-lifecycle.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ilm/policy/{policy}",
            paths: ["/_ilm/policy/{policy}", "/_ilm/policy"],
            parts: [
              "policy",
            ],
          }
        ),
        "ilm.get_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-get-status.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ilm/status",
            paths: ["/_ilm/status"],
          }
        ),
        "ilm.migrate_to_data_tiers" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-migrate-to-data-tiers.html",
          methods: ["POST"],
          body: {"description"=>"Optionally specify a legacy index template name to delete and optionally specify a node attribute name used for index shard routing (defaults to \"data\")", "required"=>false},
          url: {
            path: "/_ilm/migrate_to_data_tiers",
            paths: ["/_ilm/migrate_to_data_tiers"],
            params: [
              "dry_run",
            ]
          }
        ),
        "ilm.move_to_step" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-move-to-step.html",
          methods: ["POST"],
          body: {"description"=>"The new lifecycle step to move to"},
          url: {
            path: "/_ilm/move/{index}",
            paths: ["/_ilm/move/{index}"],
            parts: [
              "index",
            ],
          }
        ),
        "ilm.put_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-put-lifecycle.html",
          methods: ["PUT"],
          body: {"description"=>"The lifecycle policy definition to register"},
          url: {
            path: "/_ilm/policy/{policy}",
            paths: ["/_ilm/policy/{policy}"],
            parts: [
              "policy",
            ],
          }
        ),
        "ilm.remove_policy" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-remove-policy.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_ilm/remove",
            paths: ["/{index}/_ilm/remove"],
            parts: [
              "index",
            ],
          }
        ),
        "ilm.retry" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-retry-policy.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_ilm/retry",
            paths: ["/{index}/_ilm/retry"],
            parts: [
              "index",
            ],
          }
        ),
        "ilm.start" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-start.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ilm/start",
            paths: ["/_ilm/start"],
          }
        ),
        "ilm.stop" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-stop.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ilm/stop",
            paths: ["/_ilm/stop"],
          }
        ),
        "index" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-index_.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/{index}/_doc/{id}",
            paths: ["/{index}/_doc/{id}", "/{index}/_doc"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "op_type",
              "refresh",
              "routing",
              "timeout",
              "version",
              "version_type",
              "if_seq_no",
              "if_primary_term",
              "pipeline",
              "require_alias",
            ]
          }
        ),
        "indices.add_block" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/index-modules-blocks.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/{index}/_block/{block}",
            paths: ["/{index}/_block/{block}"],
            parts: [
              "index",
              "block",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.analyze" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-analyze.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Define analyzer/tokenizer parameters and the text on which the analysis should be performed"},
          url: {
            path: "/_analyze",
            paths: ["/_analyze", "/{index}/_analyze"],
            parts: [
              "index",
            ],
            params: [
              "index",
            ]
          }
        ),
        "indices.clear_cache" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-clearcache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_cache/clear",
            paths: ["/_cache/clear", "/{index}/_cache/clear"],
            parts: [
              "index",
            ],
            params: [
              "fielddata",
              "fields",
              "query",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "index",
              "request",
            ]
          }
        ),
        "indices.clone" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-clone-index.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The configuration for the target index (`settings` and `aliases`)"},
          url: {
            path: "/{index}/_clone/{target}",
            paths: ["/{index}/_clone/{target}"],
            parts: [
              "index",
              "target",
            ],
            params: [
              "timeout",
              "master_timeout",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.close" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-open-close.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_close",
            paths: ["/{index}/_close"],
            parts: [
              "index",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-create-index.html",
          methods: ["PUT"],
          body: {"description"=>"The configuration for the index (`settings` and `mappings`)"},
          url: {
            path: "/{index}",
            paths: ["/{index}"],
            parts: [
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.create_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/_data_stream/{name}",
            paths: ["/_data_stream/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "indices.data_streams_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_data_stream/_stats",
            paths: ["/_data_stream/_stats", "/_data_stream/{name}/_stats"],
            parts: [
              "name",
            ],
          }
        ),
        "indices.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-delete-index.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/{index}",
            paths: ["/{index}"],
            parts: [
              "index",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.delete_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-aliases.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/{index}/_alias/{name}",
            paths: ["/{index}/_alias/{name}", "/{index}/_aliases/{name}"],
            parts: [
              "index",
              "name",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.delete_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_data_stream/{name}",
            paths: ["/_data_stream/{name}"],
            parts: [
              "name",
            ],
            params: [
              "expand_wildcards",
            ]
          }
        ),
        "indices.delete_index_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_index_template/{name}",
            paths: ["/_index_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.delete_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_template/{name}",
            paths: ["/_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.disk_usage" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-disk-usage.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_disk_usage",
            paths: ["/{index}/_disk_usage"],
            parts: [
              "index",
            ],
            params: [
              "run_expensive_tasks",
              "flush",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.downsample" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/xpack-rollup.html",
          methods: ["POST"],
          body: {"description"=>"The downsampling configuration", "required"=>true},
          url: {
            path: "/{index}/_downsample/{target_index}",
            paths: ["/{index}/_downsample/{target_index}"],
            parts: [
              "index",
              "target_index",
            ],
          }
        ),
        "indices.exists" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-exists.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}",
            paths: ["/{index}"],
            parts: [
              "index",
            ],
            params: [
              "local",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "flat_settings",
              "include_defaults",
            ]
          }
        ),
        "indices.exists_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-aliases.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/_alias/{name}",
            paths: ["/_alias/{name}", "/{index}/_alias/{name}"],
            parts: [
              "name",
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.exists_index_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/_index_template/{name}",
            paths: ["/_index_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "flat_settings",
              "master_timeout",
              "local",
            ]
          }
        ),
        "indices.exists_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/_template/{name}",
            paths: ["/_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "flat_settings",
              "master_timeout",
              "local",
            ]
          }
        ),
        "indices.field_usage_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/field-usage-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_field_usage_stats",
            paths: ["/{index}/_field_usage_stats"],
            parts: [
              "index",
            ],
            params: [
              "fields",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.flush" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-flush.html",
          methods: ["POST", "GET"],
          body: nil,
          url: {
            path: "/_flush",
            paths: ["/_flush", "/{index}/_flush"],
            parts: [
              "index",
            ],
            params: [
              "force",
              "wait_if_ongoing",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.forcemerge" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-forcemerge.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_forcemerge",
            paths: ["/_forcemerge", "/{index}/_forcemerge"],
            parts: [
              "index",
            ],
            params: [
              "flush",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "max_num_segments",
              "only_expunge_deletes",
              "wait_for_completion",
            ]
          }
        ),
        "indices.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-get-index.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}",
            paths: ["/{index}"],
            parts: [
              "index",
            ],
            params: [
              "local",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "features",
              "flat_settings",
              "include_defaults",
              "master_timeout",
            ]
          }
        ),
        "indices.get_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-aliases.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_alias",
            paths: ["/_alias", "/_alias/{name}", "/{index}/_alias/{name}", "/{index}/_alias"],
            parts: [
              "name",
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.get_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_data_stream",
            paths: ["/_data_stream", "/_data_stream/{name}"],
            parts: [
              "name",
            ],
            params: [
              "expand_wildcards",
            ]
          }
        ),
        "indices.get_field_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-get-field-mapping.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_mapping/field/{fields}",
            paths: ["/_mapping/field/{fields}", "/{index}/_mapping/field/{fields}"],
            parts: [
              "fields",
              "index",
            ],
            params: [
              "include_defaults",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.get_index_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_index_template",
            paths: ["/_index_template", "/_index_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "flat_settings",
              "master_timeout",
              "local",
            ]
          }
        ),
        "indices.get_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-get-mapping.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_mapping",
            paths: ["/_mapping", "/{index}/_mapping"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "master_timeout",
              "local",
            ]
          }
        ),
        "indices.get_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-get-settings.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_settings",
            paths: ["/_settings", "/{index}/_settings", "/{index}/_settings/{name}", "/_settings/{name}"],
            parts: [
              "index",
              "name",
            ],
            params: [
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "flat_settings",
              "local",
              "include_defaults",
            ]
          }
        ),
        "indices.get_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_template",
            paths: ["/_template", "/_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "flat_settings",
              "master_timeout",
              "local",
            ]
          }
        ),
        "indices.migrate_to_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_data_stream/_migrate/{name}",
            paths: ["/_data_stream/_migrate/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "indices.modify_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["POST"],
          body: {"description"=>"The data stream modifications", "required"=>true},
          url: {
            path: "/_data_stream/_modify",
            paths: ["/_data_stream/_modify"],
          }
        ),
        "indices.open" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-open-close.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_open",
            paths: ["/{index}/_open"],
            parts: [
              "index",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.promote_data_stream" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/data-streams.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_data_stream/_promote/{name}",
            paths: ["/_data_stream/_promote/{name}"],
            parts: [
              "name",
            ],
          }
        ),
        "indices.put_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-aliases.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The settings for the alias, such as `routing` or `filter`", "required"=>false},
          url: {
            path: "/{index}/_alias/{name}",
            paths: ["/{index}/_alias/{name}", "/{index}/_aliases/{name}"],
            parts: [
              "index",
              "name",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.put_index_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The template definition", "required"=>true},
          url: {
            path: "/_index_template/{name}",
            paths: ["/_index_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "create",
              "cause",
              "master_timeout",
            ]
          }
        ),
        "indices.put_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-put-mapping.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The mapping definition", "required"=>true},
          url: {
            path: "/{index}/_mapping",
            paths: ["/{index}/_mapping"],
            parts: [
              "index",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "write_index_only",
            ]
          }
        ),
        "indices.put_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-update-settings.html",
          methods: ["PUT"],
          body: {"description"=>"The index settings to be updated", "required"=>true},
          url: {
            path: "/_settings",
            paths: ["/_settings", "/{index}/_settings"],
            parts: [
              "index",
            ],
            params: [
              "master_timeout",
              "timeout",
              "preserve_existing",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "flat_settings",
            ]
          }
        ),
        "indices.put_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The template definition", "required"=>true},
          url: {
            path: "/_template/{name}",
            paths: ["/_template/{name}"],
            parts: [
              "name",
            ],
            params: [
              "order",
              "create",
              "master_timeout",
            ]
          }
        ),
        "indices.recovery" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-recovery.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_recovery",
            paths: ["/_recovery", "/{index}/_recovery"],
            parts: [
              "index",
            ],
            params: [
              "detailed",
              "active_only",
            ]
          }
        ),
        "indices.refresh" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-refresh.html",
          methods: ["POST", "GET"],
          body: nil,
          url: {
            path: "/_refresh",
            paths: ["/_refresh", "/{index}/_refresh"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.reload_search_analyzers" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-reload-analyzers.html",
          methods: ["GET", "POST"],
          body: nil,
          url: {
            path: "/{index}/_reload_search_analyzers",
            paths: ["/{index}/_reload_search_analyzers"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.resolve_index" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-resolve-index-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_resolve/index/{name}",
            paths: ["/_resolve/index/{name}"],
            parts: [
              "name",
            ],
            params: [
              "expand_wildcards",
            ]
          }
        ),
        "indices.rollover" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-rollover-index.html",
          methods: ["POST"],
          body: {"description"=>"The conditions that needs to be met for executing rollover"},
          url: {
            path: "/{alias}/_rollover",
            paths: ["/{alias}/_rollover", "/{alias}/_rollover/{new_index}"],
            parts: [
              "alias",
              "new_index",
            ],
            params: [
              "timeout",
              "dry_run",
              "master_timeout",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.segments" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-segments.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_segments",
            paths: ["/_segments", "/{index}/_segments"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "verbose",
            ]
          }
        ),
        "indices.shard_stores" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-shards-stores.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_shard_stores",
            paths: ["/_shard_stores", "/{index}/_shard_stores"],
            parts: [
              "index",
            ],
            params: [
              "status",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "indices.shrink" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-shrink-index.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The configuration for the target index (`settings` and `aliases`)"},
          url: {
            path: "/{index}/_shrink/{target}",
            paths: ["/{index}/_shrink/{target}"],
            parts: [
              "index",
              "target",
            ],
            params: [
              "timeout",
              "master_timeout",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.simulate_index_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["POST"],
          body: {"description"=>"New index template definition, which will be included in the simulation, as if it already exists in the system", "required"=>false},
          url: {
            path: "/_index_template/_simulate_index/{name}",
            paths: ["/_index_template/_simulate_index/{name}"],
            parts: [
              "name",
            ],
            params: [
              "create",
              "cause",
              "master_timeout",
            ]
          }
        ),
        "indices.simulate_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-templates.html",
          methods: ["POST"],
          body: {"description"=>"New index template definition to be simulated, if no index template name is specified", "required"=>false},
          url: {
            path: "/_index_template/_simulate",
            paths: ["/_index_template/_simulate", "/_index_template/_simulate/{name}"],
            parts: [
              "name",
            ],
            params: [
              "create",
              "cause",
              "master_timeout",
            ]
          }
        ),
        "indices.split" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-split-index.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The configuration for the target index (`settings` and `aliases`)"},
          url: {
            path: "/{index}/_split/{target}",
            paths: ["/{index}/_split/{target}"],
            parts: [
              "index",
              "target",
            ],
            params: [
              "timeout",
              "master_timeout",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_stats",
            paths: ["/_stats", "/_stats/{metric}", "/{index}/_stats", "/{index}/_stats/{metric}"],
            parts: [
              "metric",
              "index",
            ],
            params: [
              "completion_fields",
              "fielddata_fields",
              "fields",
              "groups",
              "level",
              "include_segment_file_sizes",
              "include_unloaded_segments",
              "expand_wildcards",
              "forbid_closed_indices",
            ]
          }
        ),
        "indices.unfreeze" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/unfreeze-index-api.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_unfreeze",
            paths: ["/{index}/_unfreeze"],
            parts: [
              "index",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "wait_for_active_shards",
            ]
          }
        ),
        "indices.update_aliases" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-aliases.html",
          methods: ["POST"],
          body: {"description"=>"The definition of `actions` to perform", "required"=>true},
          url: {
            path: "/_aliases",
            paths: ["/_aliases"],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "indices.validate_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-validate.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The query definition specified with the Query DSL"},
          url: {
            path: "/_validate/query",
            paths: ["/_validate/query", "/{index}/_validate/query"],
            parts: [
              "index",
            ],
            params: [
              "explain",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "q",
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "lenient",
              "rewrite",
              "all_shards",
            ]
          }
        ),
        "info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/",
            paths: ["/"],
          }
        ),
        "ingest.delete_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/delete-pipeline-api.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ingest/pipeline/{id}",
            paths: ["/_ingest/pipeline/{id}"],
            parts: [
              "id",
            ],
            params: [
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "ingest.geo_ip_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/geoip-stats-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ingest/geoip/stats",
            paths: ["/_ingest/geoip/stats"],
          }
        ),
        "ingest.get_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-pipeline-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ingest/pipeline",
            paths: ["/_ingest/pipeline", "/_ingest/pipeline/{id}"],
            parts: [
              "id",
            ],
            params: [
              "summary",
              "master_timeout",
            ]
          }
        ),
        "ingest.processor_grok" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/grok-processor.html#grok-processor-rest-get",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ingest/processor/grok",
            paths: ["/_ingest/processor/grok"],
          }
        ),
        "ingest.put_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/put-pipeline-api.html",
          methods: ["PUT"],
          body: {"description"=>"The ingest definition", "required"=>true},
          url: {
            path: "/_ingest/pipeline/{id}",
            paths: ["/_ingest/pipeline/{id}"],
            parts: [
              "id",
            ],
            params: [
              "if_version",
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "ingest.simulate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/simulate-pipeline-api.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The simulate definition", "required"=>true},
          url: {
            path: "/_ingest/pipeline/_simulate",
            paths: ["/_ingest/pipeline/_simulate", "/_ingest/pipeline/{id}/_simulate"],
            parts: [
              "id",
            ],
            params: [
              "verbose",
            ]
          }
        ),
        "knn_search" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition"},
          url: {
            path: "/{index}/_knn_search",
            paths: ["/{index}/_knn_search"],
            parts: [
              "index",
            ],
            params: [
              "routing",
            ]
          }
        ),
        "license.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/delete-license.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_license",
            paths: ["/_license"],
          }
        ),
        "license.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-license.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_license",
            paths: ["/_license"],
            params: [
              "local",
              "accept_enterprise",
            ]
          }
        ),
        "license.get_basic_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-basic-status.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_license/basic_status",
            paths: ["/_license/basic_status"],
          }
        ),
        "license.get_trial_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-trial-status.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_license/trial_status",
            paths: ["/_license/trial_status"],
          }
        ),
        "license.post" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/update-license.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"licenses to be installed"},
          url: {
            path: "/_license",
            paths: ["/_license"],
            params: [
              "acknowledge",
            ]
          }
        ),
        "license.post_start_basic" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/start-basic.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_license/start_basic",
            paths: ["/_license/start_basic"],
            params: [
              "acknowledge",
            ]
          }
        ),
        "license.post_start_trial" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/start-trial.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_license/start_trial",
            paths: ["/_license/start_trial"],
            params: [
              "type",
              "acknowledge",
            ]
          }
        ),
        "logstash.delete_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/logstash-api-delete-pipeline.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_logstash/pipeline/{id}",
            paths: ["/_logstash/pipeline/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "logstash.get_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/logstash-api-get-pipeline.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_logstash/pipeline",
            paths: ["/_logstash/pipeline", "/_logstash/pipeline/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "logstash.put_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/logstash-api-put-pipeline.html",
          methods: ["PUT"],
          body: {"description"=>"The Pipeline to add or update", "required"=>true},
          url: {
            path: "/_logstash/pipeline/{id}",
            paths: ["/_logstash/pipeline/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "mget" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-multi-get.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Document identifiers; can be either `docs` (containing full document information) or `ids` (when index is provided in the URL.", "required"=>true},
          url: {
            path: "/_mget",
            paths: ["/_mget", "/{index}/_mget"],
            parts: [
              "index",
            ],
            params: [
              "force_synthetic_source",
              "stored_fields",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_excludes",
              "_source_includes",
            ]
          }
        ),
        "migration.deprecations" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-deprecation.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_migration/deprecations",
            paths: ["/_migration/deprecations", "/{index}/_migration/deprecations"],
            parts: [
              "index",
            ],
          }
        ),
        "migration.get_feature_upgrade_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-feature-upgrade.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_migration/system_features",
            paths: ["/_migration/system_features"],
          }
        ),
        "migration.post_feature_upgrade" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-feature-upgrade.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_migration/system_features",
            paths: ["/_migration/system_features"],
          }
        ),
        "ml.clear_trained_model_deployment_cache" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/clear-trained-model-deployment-cache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}/deployment/cache/_clear",
            paths: ["/_ml/trained_models/{model_id}/deployment/cache/_clear"],
            parts: [
              "model_id",
            ],
          }
        ),
        "ml.close_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-close-job.html",
          methods: ["POST"],
          body: {"description"=>"The URL params optionally sent in the body", "required"=>false},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_close",
            paths: ["/_ml/anomaly_detectors/{job_id}/_close"],
            parts: [
              "job_id",
            ],
            params: [
              "allow_no_match",
              "force",
              "timeout",
            ]
          }
        ),
        "ml.delete_calendar" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-calendar.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/calendars/{calendar_id}",
            paths: ["/_ml/calendars/{calendar_id}"],
            parts: [
              "calendar_id",
            ],
          }
        ),
        "ml.delete_calendar_event" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-calendar-event.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/calendars/{calendar_id}/events/{event_id}",
            paths: ["/_ml/calendars/{calendar_id}/events/{event_id}"],
            parts: [
              "calendar_id",
              "event_id",
            ],
          }
        ),
        "ml.delete_calendar_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-calendar-job.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/calendars/{calendar_id}/jobs/{job_id}",
            paths: ["/_ml/calendars/{calendar_id}/jobs/{job_id}"],
            parts: [
              "calendar_id",
              "job_id",
            ],
          }
        ),
        "ml.delete_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-dfanalytics.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/data_frame/analytics/{id}",
            paths: ["/_ml/data_frame/analytics/{id}"],
            parts: [
              "id",
            ],
            params: [
              "force",
              "timeout",
            ]
          }
        ),
        "ml.delete_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-datafeed.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/datafeeds/{datafeed_id}",
            paths: ["/_ml/datafeeds/{datafeed_id}"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "force",
            ]
          }
        ),
        "ml.delete_expired_data" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-expired-data.html",
          methods: ["DELETE"],
          body: {"description"=>"deleting expired data parameters"},
          url: {
            path: "/_ml/_delete_expired_data/{job_id}",
            paths: ["/_ml/_delete_expired_data/{job_id}", "/_ml/_delete_expired_data"],
            parts: [
              "job_id",
            ],
            params: [
              "requests_per_second",
              "timeout",
            ]
          }
        ),
        "ml.delete_filter" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-filter.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/filters/{filter_id}",
            paths: ["/_ml/filters/{filter_id}"],
            parts: [
              "filter_id",
            ],
          }
        ),
        "ml.delete_forecast" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-forecast.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_forecast",
            paths: ["/_ml/anomaly_detectors/{job_id}/_forecast", "/_ml/anomaly_detectors/{job_id}/_forecast/{forecast_id}"],
            parts: [
              "job_id",
              "forecast_id",
            ],
            params: [
              "allow_no_forecasts",
              "timeout",
            ]
          }
        ),
        "ml.delete_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-job.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}"],
            parts: [
              "job_id",
            ],
            params: [
              "force",
              "wait_for_completion",
              "delete_user_annotations",
            ]
          }
        ),
        "ml.delete_model_snapshot" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-snapshot.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
          }
        ),
        "ml.delete_trained_model" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-trained-models.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}",
            paths: ["/_ml/trained_models/{model_id}"],
            parts: [
              "model_id",
            ],
            params: [
              "timeout",
              "force",
            ]
          }
        ),
        "ml.delete_trained_model_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-trained-models-aliases.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}/model_aliases/{model_alias}",
            paths: ["/_ml/trained_models/{model_id}/model_aliases/{model_alias}"],
            parts: [
              "model_alias",
              "model_id",
            ],
          }
        ),
        "ml.estimate_model_memory" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-apis.html",
          methods: ["POST"],
          body: {"description"=>"The analysis config, plus cardinality estimates for fields it references", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/_estimate_model_memory",
            paths: ["/_ml/anomaly_detectors/_estimate_model_memory"],
          }
        ),
        "ml.evaluate_data_frame" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/evaluate-dfanalytics.html",
          methods: ["POST"],
          body: {"description"=>"The evaluation definition", "required"=>true},
          url: {
            path: "/_ml/data_frame/_evaluate",
            paths: ["/_ml/data_frame/_evaluate"],
          }
        ),
        "ml.explain_data_frame_analytics" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/current/explain-dfanalytics.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The data frame analytics config to explain", "required"=>false},
          url: {
            path: "/_ml/data_frame/analytics/_explain",
            paths: ["/_ml/data_frame/analytics/_explain", "/_ml/data_frame/analytics/{id}/_explain"],
            parts: [
              "id",
            ],
          }
        ),
        "ml.flush_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-flush-job.html",
          methods: ["POST"],
          body: {"description"=>"Flush parameters"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_flush",
            paths: ["/_ml/anomaly_detectors/{job_id}/_flush"],
            parts: [
              "job_id",
            ],
            params: [
              "calc_interim",
              "start",
              "end",
              "advance_time",
              "skip_time",
            ]
          }
        ),
        "ml.forecast" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-forecast.html",
          methods: ["POST"],
          body: {"description"=>"Query parameters can be specified in the body", "required"=>false},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_forecast",
            paths: ["/_ml/anomaly_detectors/{job_id}/_forecast"],
            parts: [
              "job_id",
            ],
            params: [
              "duration",
              "expires_in",
              "max_model_memory",
            ]
          }
        ),
        "ml.get_buckets" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-bucket.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Bucket selection details if not provided in URI"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/results/buckets/{timestamp}",
            paths: ["/_ml/anomaly_detectors/{job_id}/results/buckets/{timestamp}", "/_ml/anomaly_detectors/{job_id}/results/buckets"],
            parts: [
              "job_id",
              "timestamp",
            ],
            params: [
              "expand",
              "exclude_interim",
              "from",
              "size",
              "start",
              "end",
              "anomaly_score",
              "sort",
              "desc",
            ]
          }
        ),
        "ml.get_calendar_events" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-calendar-event.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/calendars/{calendar_id}/events",
            paths: ["/_ml/calendars/{calendar_id}/events"],
            parts: [
              "calendar_id",
            ],
            params: [
              "job_id",
              "start",
              "end",
              "from",
              "size",
            ]
          }
        ),
        "ml.get_calendars" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-calendar.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The from and size parameters optionally sent in the body"},
          url: {
            path: "/_ml/calendars",
            paths: ["/_ml/calendars", "/_ml/calendars/{calendar_id}"],
            parts: [
              "calendar_id",
            ],
            params: [
              "from",
              "size",
            ]
          }
        ),
        "ml.get_categories" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-category.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Category selection details if not provided in URI"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/results/categories/{category_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}/results/categories/{category_id}", "/_ml/anomaly_detectors/{job_id}/results/categories/"],
            parts: [
              "job_id",
              "category_id",
            ],
            params: [
              "from",
              "size",
              "partition_field_value",
            ]
          }
        ),
        "ml.get_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-dfanalytics.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/data_frame/analytics/{id}",
            paths: ["/_ml/data_frame/analytics/{id}", "/_ml/data_frame/analytics"],
            parts: [
              "id",
            ],
            params: [
              "allow_no_match",
              "from",
              "size",
              "exclude_generated",
            ]
          }
        ),
        "ml.get_data_frame_analytics_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-dfanalytics-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/data_frame/analytics/_stats",
            paths: ["/_ml/data_frame/analytics/_stats", "/_ml/data_frame/analytics/{id}/_stats"],
            parts: [
              "id",
            ],
            params: [
              "allow_no_match",
              "from",
              "size",
              "verbose",
            ]
          }
        ),
        "ml.get_datafeed_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-datafeed-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/datafeeds/{datafeed_id}/_stats",
            paths: ["/_ml/datafeeds/{datafeed_id}/_stats", "/_ml/datafeeds/_stats"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "allow_no_match",
            ]
          }
        ),
        "ml.get_datafeeds" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-datafeed.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/datafeeds/{datafeed_id}",
            paths: ["/_ml/datafeeds/{datafeed_id}", "/_ml/datafeeds"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "allow_no_match",
              "exclude_generated",
            ]
          }
        ),
        "ml.get_filters" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-filter.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/filters",
            paths: ["/_ml/filters", "/_ml/filters/{filter_id}"],
            parts: [
              "filter_id",
            ],
            params: [
              "from",
              "size",
            ]
          }
        ),
        "ml.get_influencers" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-influencer.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Influencer selection criteria"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/results/influencers",
            paths: ["/_ml/anomaly_detectors/{job_id}/results/influencers"],
            parts: [
              "job_id",
            ],
            params: [
              "exclude_interim",
              "from",
              "size",
              "start",
              "end",
              "influencer_score",
              "sort",
              "desc",
            ]
          }
        ),
        "ml.get_job_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-job-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/_stats",
            paths: ["/_ml/anomaly_detectors/_stats", "/_ml/anomaly_detectors/{job_id}/_stats"],
            parts: [
              "job_id",
            ],
            params: [
              "allow_no_match",
            ]
          }
        ),
        "ml.get_jobs" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-job.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}", "/_ml/anomaly_detectors"],
            parts: [
              "job_id",
            ],
            params: [
              "allow_no_match",
              "exclude_generated",
            ]
          }
        ),
        "ml.get_memory_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-ml-memory.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/memory/_stats",
            paths: ["/_ml/memory/_stats", "/_ml/memory/{node_id}/_stats"],
            parts: [
              "node_id",
            ],
            params: [
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "ml.get_model_snapshot_upgrade_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-job-model-snapshot-upgrade-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_upgrade/_stats",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_upgrade/_stats"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
            params: [
              "allow_no_match",
            ]
          }
        ),
        "ml.get_model_snapshots" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-snapshot.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Model snapshot selection criteria"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}", "/_ml/anomaly_detectors/{job_id}/model_snapshots"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
            params: [
              "from",
              "size",
              "start",
              "end",
              "sort",
              "desc",
            ]
          }
        ),
        "ml.get_overall_buckets" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-overall-buckets.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Overall bucket selection details if not provided in URI"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/results/overall_buckets",
            paths: ["/_ml/anomaly_detectors/{job_id}/results/overall_buckets"],
            parts: [
              "job_id",
            ],
            params: [
              "top_n",
              "bucket_span",
              "overall_score",
              "exclude_interim",
              "start",
              "end",
              "allow_no_match",
            ]
          }
        ),
        "ml.get_records" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-record.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Record selection criteria"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/results/records",
            paths: ["/_ml/anomaly_detectors/{job_id}/results/records"],
            parts: [
              "job_id",
            ],
            params: [
              "exclude_interim",
              "from",
              "size",
              "start",
              "end",
              "record_score",
              "sort",
              "desc",
            ]
          }
        ),
        "ml.get_trained_models" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-trained-models.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}",
            paths: ["/_ml/trained_models/{model_id}", "/_ml/trained_models"],
            parts: [
              "model_id",
            ],
            params: [
              "allow_no_match",
              "include",
              "include_model_definition",
              "decompress_definition",
              "from",
              "size",
              "tags",
              "exclude_generated",
            ]
          }
        ),
        "ml.get_trained_models_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-trained-models-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}/_stats",
            paths: ["/_ml/trained_models/{model_id}/_stats", "/_ml/trained_models/_stats"],
            parts: [
              "model_id",
            ],
            params: [
              "allow_no_match",
              "from",
              "size",
            ]
          }
        ),
        "ml.infer_trained_model" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/infer-trained-model.html",
          methods: ["POST"],
          body: {"description"=>"The docs to apply inference on and inference configuration overrides", "required"=>true},
          url: {
            path: "/_ml/trained_models/{model_id}/_infer",
            paths: ["/_ml/trained_models/{model_id}/_infer", "/_ml/trained_models/{model_id}/deployment/_infer"],
            parts: [
              "model_id",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "ml.info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-ml-info.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ml/info",
            paths: ["/_ml/info"],
          }
        ),
        "ml.open_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-open-job.html",
          methods: ["POST"],
          body: {"description"=>"Query parameters can be specified in the body", "required"=>false},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_open",
            paths: ["/_ml/anomaly_detectors/{job_id}/_open"],
            parts: [
              "job_id",
            ],
          }
        ),
        "ml.post_calendar_events" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-post-calendar-event.html",
          methods: ["POST"],
          body: {"description"=>"A list of events", "required"=>true},
          url: {
            path: "/_ml/calendars/{calendar_id}/events",
            paths: ["/_ml/calendars/{calendar_id}/events"],
            parts: [
              "calendar_id",
            ],
          }
        ),
        "ml.post_data" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-post-data.html",
          methods: ["POST"],
          body: {"description"=>"The data to process", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_data",
            paths: ["/_ml/anomaly_detectors/{job_id}/_data"],
            parts: [
              "job_id",
            ],
            params: [
              "reset_start",
              "reset_end",
            ]
          }
        ),
        "ml.preview_data_frame_analytics" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/current/preview-dfanalytics.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The data frame analytics config to preview", "required"=>false},
          url: {
            path: "/_ml/data_frame/analytics/_preview",
            paths: ["/_ml/data_frame/analytics/_preview", "/_ml/data_frame/analytics/{id}/_preview"],
            parts: [
              "id",
            ],
          }
        ),
        "ml.preview_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-preview-datafeed.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The datafeed config and job config with which to execute the preview", "required"=>false},
          url: {
            path: "/_ml/datafeeds/{datafeed_id}/_preview",
            paths: ["/_ml/datafeeds/{datafeed_id}/_preview", "/_ml/datafeeds/_preview"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "start",
              "end",
            ]
          }
        ),
        "ml.put_calendar" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-calendar.html",
          methods: ["PUT"],
          body: {"description"=>"The calendar details", "required"=>false},
          url: {
            path: "/_ml/calendars/{calendar_id}",
            paths: ["/_ml/calendars/{calendar_id}"],
            parts: [
              "calendar_id",
            ],
          }
        ),
        "ml.put_calendar_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-calendar-job.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/_ml/calendars/{calendar_id}/jobs/{job_id}",
            paths: ["/_ml/calendars/{calendar_id}/jobs/{job_id}"],
            parts: [
              "calendar_id",
              "job_id",
            ],
          }
        ),
        "ml.put_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-dfanalytics.html",
          methods: ["PUT"],
          body: {"description"=>"The data frame analytics configuration", "required"=>true},
          url: {
            path: "/_ml/data_frame/analytics/{id}",
            paths: ["/_ml/data_frame/analytics/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "ml.put_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-datafeed.html",
          methods: ["PUT"],
          body: {"description"=>"The datafeed config", "required"=>true},
          url: {
            path: "/_ml/datafeeds/{datafeed_id}",
            paths: ["/_ml/datafeeds/{datafeed_id}"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "ignore_throttled",
              "expand_wildcards",
            ]
          }
        ),
        "ml.put_filter" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-filter.html",
          methods: ["PUT"],
          body: {"description"=>"The filter details", "required"=>true},
          url: {
            path: "/_ml/filters/{filter_id}",
            paths: ["/_ml/filters/{filter_id}"],
            parts: [
              "filter_id",
            ],
          }
        ),
        "ml.put_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-job.html",
          methods: ["PUT"],
          body: {"description"=>"The job", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}",
            paths: ["/_ml/anomaly_detectors/{job_id}"],
            parts: [
              "job_id",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "ignore_throttled",
              "expand_wildcards",
            ]
          }
        ),
        "ml.put_trained_model" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-trained-models.html",
          methods: ["PUT"],
          body: {"description"=>"The trained model configuration", "required"=>true},
          url: {
            path: "/_ml/trained_models/{model_id}",
            paths: ["/_ml/trained_models/{model_id}"],
            parts: [
              "model_id",
            ],
            params: [
              "defer_definition_decompression",
            ]
          }
        ),
        "ml.put_trained_model_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-trained-models-aliases.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}/model_aliases/{model_alias}",
            paths: ["/_ml/trained_models/{model_id}/model_aliases/{model_alias}"],
            parts: [
              "model_alias",
              "model_id",
            ],
            params: [
              "reassign",
            ]
          }
        ),
        "ml.put_trained_model_definition_part" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-trained-model-definition-part.html",
          methods: ["PUT"],
          body: {"description"=>"The trained model definition part", "required"=>true},
          url: {
            path: "/_ml/trained_models/{model_id}/definition/{part}",
            paths: ["/_ml/trained_models/{model_id}/definition/{part}"],
            parts: [
              "model_id",
              "part",
            ],
          }
        ),
        "ml.put_trained_model_vocabulary" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-trained-model-vocabulary.html",
          methods: ["PUT"],
          body: {"description"=>"The trained model vocabulary", "required"=>true},
          url: {
            path: "/_ml/trained_models/{model_id}/vocabulary",
            paths: ["/_ml/trained_models/{model_id}/vocabulary"],
            parts: [
              "model_id",
            ],
          }
        ),
        "ml.reset_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-reset-job.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_reset",
            paths: ["/_ml/anomaly_detectors/{job_id}/_reset"],
            parts: [
              "job_id",
            ],
            params: [
              "wait_for_completion",
              "delete_user_annotations",
            ]
          }
        ),
        "ml.revert_model_snapshot" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-revert-snapshot.html",
          methods: ["POST"],
          body: {"description"=>"Reversion options"},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_revert",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_revert"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
            params: [
              "delete_intervening_results",
            ]
          }
        ),
        "ml.set_upgrade_mode" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-set-upgrade-mode.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ml/set_upgrade_mode",
            paths: ["/_ml/set_upgrade_mode"],
            params: [
              "enabled",
              "timeout",
            ]
          }
        ),
        "ml.start_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/start-dfanalytics.html",
          methods: ["POST"],
          body: {"description"=>"The start data frame analytics parameters"},
          url: {
            path: "/_ml/data_frame/analytics/{id}/_start",
            paths: ["/_ml/data_frame/analytics/{id}/_start"],
            parts: [
              "id",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "ml.start_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-start-datafeed.html",
          methods: ["POST"],
          body: {"description"=>"The start datafeed parameters"},
          url: {
            path: "/_ml/datafeeds/{datafeed_id}/_start",
            paths: ["/_ml/datafeeds/{datafeed_id}/_start"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "start",
              "end",
              "timeout",
            ]
          }
        ),
        "ml.start_trained_model_deployment" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/start-trained-model-deployment.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ml/trained_models/{model_id}/deployment/_start",
            paths: ["/_ml/trained_models/{model_id}/deployment/_start"],
            parts: [
              "model_id",
            ],
            params: [
              "cache_size",
              "number_of_allocations",
              "threads_per_allocation",
              "priority",
              "queue_capacity",
              "timeout",
              "wait_for",
            ]
          }
        ),
        "ml.stop_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/stop-dfanalytics.html",
          methods: ["POST"],
          body: {"description"=>"The stop data frame analytics parameters"},
          url: {
            path: "/_ml/data_frame/analytics/{id}/_stop",
            paths: ["/_ml/data_frame/analytics/{id}/_stop"],
            parts: [
              "id",
            ],
            params: [
              "allow_no_match",
              "force",
              "timeout",
            ]
          }
        ),
        "ml.stop_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-stop-datafeed.html",
          methods: ["POST"],
          body: {"description"=>"The URL params optionally sent in the body", "required"=>false},
          url: {
            path: "/_ml/datafeeds/{datafeed_id}/_stop",
            paths: ["/_ml/datafeeds/{datafeed_id}/_stop"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "allow_no_match",
              "allow_no_datafeeds",
              "force",
              "timeout",
            ]
          }
        ),
        "ml.stop_trained_model_deployment" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/stop-trained-model-deployment.html",
          methods: ["POST"],
          body: {"description"=>"The stop deployment parameters"},
          url: {
            path: "/_ml/trained_models/{model_id}/deployment/_stop",
            paths: ["/_ml/trained_models/{model_id}/deployment/_stop"],
            parts: [
              "model_id",
            ],
            params: [
              "allow_no_match",
              "force",
            ]
          }
        ),
        "ml.update_data_frame_analytics" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/update-dfanalytics.html",
          methods: ["POST"],
          body: {"description"=>"The data frame analytics settings to update", "required"=>true},
          url: {
            path: "/_ml/data_frame/analytics/{id}/_update",
            paths: ["/_ml/data_frame/analytics/{id}/_update"],
            parts: [
              "id",
            ],
          }
        ),
        "ml.update_datafeed" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-datafeed.html",
          methods: ["POST"],
          body: {"description"=>"The datafeed update settings", "required"=>true},
          url: {
            path: "/_ml/datafeeds/{datafeed_id}/_update",
            paths: ["/_ml/datafeeds/{datafeed_id}/_update"],
            parts: [
              "datafeed_id",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "ignore_throttled",
              "expand_wildcards",
            ]
          }
        ),
        "ml.update_filter" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-filter.html",
          methods: ["POST"],
          body: {"description"=>"The filter update", "required"=>true},
          url: {
            path: "/_ml/filters/{filter_id}/_update",
            paths: ["/_ml/filters/{filter_id}/_update"],
            parts: [
              "filter_id",
            ],
          }
        ),
        "ml.update_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-job.html",
          methods: ["POST"],
          body: {"description"=>"The job update settings", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/_update",
            paths: ["/_ml/anomaly_detectors/{job_id}/_update"],
            parts: [
              "job_id",
            ],
          }
        ),
        "ml.update_model_snapshot" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-snapshot.html",
          methods: ["POST"],
          body: {"description"=>"The model snapshot properties to update", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_update",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_update"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
          }
        ),
        "ml.update_trained_model_deployment" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/update-trained-model-deployment.html",
          methods: ["POST"],
          body: {"description"=>"The updated trained model deployment settings", "required"=>true},
          url: {
            path: "/_ml/trained_models/{model_id}/deployment/_update",
            paths: ["/_ml/trained_models/{model_id}/deployment/_update"],
            parts: [
              "model_id",
            ],
          }
        ),
        "ml.upgrade_job_snapshot" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-upgrade-job-model-snapshot.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_upgrade",
            paths: ["/_ml/anomaly_detectors/{job_id}/model_snapshots/{snapshot_id}/_upgrade"],
            parts: [
              "job_id",
              "snapshot_id",
            ],
            params: [
              "timeout",
              "wait_for_completion",
            ]
          }
        ),
        "ml.validate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/machine-learning/current/ml-jobs.html",
          methods: ["POST"],
          body: {"description"=>"The job config", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/_validate",
            paths: ["/_ml/anomaly_detectors/_validate"],
          }
        ),
        "ml.validate_detector" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/machine-learning/current/ml-jobs.html",
          methods: ["POST"],
          body: {"description"=>"The detector", "required"=>true},
          url: {
            path: "/_ml/anomaly_detectors/_validate/detector",
            paths: ["/_ml/anomaly_detectors/_validate/detector"],
          }
        ),
        "monitoring.bulk" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/monitor-elasticsearch-cluster.html",
          methods: ["POST", "PUT"],
          body: {"description"=>"The operation definition and data (action-data pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_monitoring/bulk",
            paths: ["/_monitoring/bulk", "/_monitoring/{type}/bulk"],
            parts: [
              "type",
            ],
            params: [
              "system_id",
              "system_api_version",
              "interval",
            ]
          }
        ),
        "msearch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-multi-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The request definitions (metadata-search request definition pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_msearch",
            paths: ["/_msearch", "/{index}/_msearch"],
            parts: [
              "index",
            ],
            params: [
              "search_type",
              "max_concurrent_searches",
              "typed_keys",
              "pre_filter_shard_size",
              "max_concurrent_shard_requests",
              "rest_total_hits_as_int",
              "ccs_minimize_roundtrips",
            ]
          }
        ),
        "msearch_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The request definitions (metadata-search request definition pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_msearch/template",
            paths: ["/_msearch/template", "/{index}/_msearch/template"],
            parts: [
              "index",
            ],
            params: [
              "search_type",
              "typed_keys",
              "max_concurrent_searches",
              "rest_total_hits_as_int",
              "ccs_minimize_roundtrips",
            ]
          }
        ),
        "mtermvectors" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-multi-termvectors.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Define ids, documents, parameters or a list of parameters per document here. You must at least provide a list of document ids. See documentation.", "required"=>false},
          url: {
            path: "/_mtermvectors",
            paths: ["/_mtermvectors", "/{index}/_mtermvectors"],
            parts: [
              "index",
            ],
            params: [
              "ids",
              "term_statistics",
              "field_statistics",
              "fields",
              "offsets",
              "positions",
              "payloads",
              "preference",
              "routing",
              "realtime",
              "version",
              "version_type",
            ]
          }
        ),
        "nodes.clear_repositories_metering_archive" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/clear-repositories-metering-archive-api.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_nodes/{node_id}/_repositories_metering/{max_archive_version}",
            paths: ["/_nodes/{node_id}/_repositories_metering/{max_archive_version}"],
            parts: [
              "node_id",
              "max_archive_version",
            ],
          }
        ),
        "nodes.get_repositories_metering_info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-repositories-metering-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/{node_id}/_repositories_metering",
            paths: ["/_nodes/{node_id}/_repositories_metering"],
            parts: [
              "node_id",
            ],
          }
        ),
        "nodes.hot_threads" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-nodes-hot-threads.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/hot_threads",
            paths: ["/_nodes/hot_threads", "/_nodes/{node_id}/hot_threads"],
            parts: [
              "node_id",
            ],
            params: [
              "interval",
              "snapshots",
              "threads",
              "ignore_idle_threads",
              "type",
              "sort",
              "timeout",
            ]
          }
        ),
        "nodes.info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-nodes-info.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes",
            paths: ["/_nodes", "/_nodes/{node_id}", "/_nodes/{metric}", "/_nodes/{node_id}/{metric}"],
            parts: [
              "node_id",
              "metric",
            ],
            params: [
              "flat_settings",
              "timeout",
            ]
          }
        ),
        "nodes.reload_secure_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/secure-settings.html#reloadable-secure-settings",
          methods: ["POST"],
          body: {"description"=>"An object containing the password for the elasticsearch keystore", "required"=>false},
          url: {
            path: "/_nodes/reload_secure_settings",
            paths: ["/_nodes/reload_secure_settings", "/_nodes/{node_id}/reload_secure_settings"],
            parts: [
              "node_id",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "nodes.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-nodes-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/stats",
            paths: ["/_nodes/stats", "/_nodes/{node_id}/stats", "/_nodes/stats/{metric}", "/_nodes/{node_id}/stats/{metric}", "/_nodes/stats/{metric}/{index_metric}", "/_nodes/{node_id}/stats/{metric}/{index_metric}"],
            parts: [
              "node_id",
              "metric",
              "index_metric",
            ],
            params: [
              "completion_fields",
              "fielddata_fields",
              "fields",
              "groups",
              "level",
              "types",
              "timeout",
              "include_segment_file_sizes",
              "include_unloaded_segments",
            ]
          }
        ),
        "nodes.usage" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/cluster-nodes-usage.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/usage",
            paths: ["/_nodes/usage", "/_nodes/{node_id}/usage", "/_nodes/usage/{metric}", "/_nodes/{node_id}/usage/{metric}"],
            parts: [
              "node_id",
              "metric",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "open_point_in_time" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/point-in-time-api.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/{index}/_pit",
            paths: ["/{index}/_pit"],
            parts: [
              "index",
            ],
            params: [
              "preference",
              "routing",
              "ignore_unavailable",
              "expand_wildcards",
              "keep_alive",
            ]
          }
        ),
        "ping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/",
            paths: ["/"],
          }
        ),
        "put_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-scripting.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/_scripts/{id}",
            paths: ["/_scripts/{id}", "/_scripts/{id}/{context}"],
            parts: [
              "id",
              "context",
            ],
            params: [
              "timeout",
              "master_timeout",
              "context",
            ]
          }
        ),
        "rank_eval" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-rank-eval.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The ranking evaluation search definition, including search requests, document ratings and ranking metric definition.", "required"=>true},
          url: {
            path: "/_rank_eval",
            paths: ["/_rank_eval", "/{index}/_rank_eval"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "search_type",
            ]
          }
        ),
        "reindex" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-reindex.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL and the prototype for the index request.", "required"=>true},
          url: {
            path: "/_reindex",
            paths: ["/_reindex"],
            params: [
              "refresh",
              "timeout",
              "wait_for_active_shards",
              "wait_for_completion",
              "requests_per_second",
              "scroll",
              "slices",
              "max_docs",
            ]
          }
        ),
        "reindex_rethrottle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-reindex.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_reindex/{task_id}/_rethrottle",
            paths: ["/_reindex/{task_id}/_rethrottle"],
            parts: [
              "task_id",
            ],
            params: [
              "requests_per_second",
            ]
          }
        ),
        "render_search_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/render-search-template-api.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition template and its params"},
          url: {
            path: "/_render/template",
            paths: ["/_render/template", "/_render/template/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.delete_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-delete-job.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_rollup/job/{id}",
            paths: ["/_rollup/job/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.get_jobs" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-get-job.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_rollup/job/{id}",
            paths: ["/_rollup/job/{id}", "/_rollup/job/"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.get_rollup_caps" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-get-rollup-caps.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_rollup/data/{id}",
            paths: ["/_rollup/data/{id}", "/_rollup/data/"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.get_rollup_index_caps" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-get-rollup-index-caps.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/_rollup/data",
            paths: ["/{index}/_rollup/data"],
            parts: [
              "index",
            ],
          }
        ),
        "rollup.put_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-put-job.html",
          methods: ["PUT"],
          body: {"description"=>"The job configuration", "required"=>true},
          url: {
            path: "/_rollup/job/{id}",
            paths: ["/_rollup/job/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.rollup_search" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search request body", "required"=>true},
          url: {
            path: "/{index}/_rollup_search",
            paths: ["/{index}/_rollup_search"],
            parts: [
              "index",
            ],
            params: [
              "typed_keys",
              "rest_total_hits_as_int",
            ]
          }
        ),
        "rollup.start_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-start-job.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_rollup/job/{id}/_start",
            paths: ["/_rollup/job/{id}/_start"],
            parts: [
              "id",
            ],
          }
        ),
        "rollup.stop_job" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/rollup-stop-job.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_rollup/job/{id}/_stop",
            paths: ["/_rollup/job/{id}/_stop"],
            parts: [
              "id",
            ],
            params: [
              "wait_for_completion",
              "timeout",
            ]
          }
        ),
        "scripts_painless_execute" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/painless/master/painless-execute-api.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The script to execute"},
          url: {
            path: "/_scripts/painless/_execute",
            paths: ["/_scripts/painless/_execute"],
          }
        ),
        "scroll" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-request-body.html#request-body-search-scroll",
          methods: ["GET", "POST"],
          body: {"description"=>"The scroll ID if not passed by URL or query parameter."},
          url: {
            path: "/_search/scroll",
            paths: ["/_search/scroll", "/_search/scroll/{scroll_id}"],
            parts: [
              "scroll_id",
            ],
            params: [
              "scroll",
              "scroll_id",
              "rest_total_hits_as_int",
            ]
          }
        ),
        "search" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/_search",
            paths: ["/_search", "/{index}/_search"],
            parts: [
              "index",
            ],
            params: [
              "analyzer",
              "analyze_wildcard",
              "ccs_minimize_roundtrips",
              "default_operator",
              "df",
              "explain",
              "stored_fields",
              "docvalue_fields",
              "from",
              "force_synthetic_source",
              "ignore_unavailable",
              "ignore_throttled",
              "allow_no_indices",
              "expand_wildcards",
              "lenient",
              "preference",
              "q",
              "routing",
              "scroll",
              "search_type",
              "size",
              "sort",
              "_source",
              "_source_excludes",
              "_source_includes",
              "terminate_after",
              "stats",
              "suggest_field",
              "suggest_mode",
              "suggest_size",
              "suggest_text",
              "timeout",
              "track_scores",
              "track_total_hits",
              "allow_partial_search_results",
              "typed_keys",
              "version",
              "seq_no_primary_term",
              "request_cache",
              "batched_reduce_size",
              "max_concurrent_shard_requests",
              "pre_filter_shard_size",
              "rest_total_hits_as_int",
              "min_compatible_shard_node",
            ]
          }
        ),
        "search_mvt" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-vector-tile-api.html",
          methods: ["POST", "GET"],
          body: {"description"=>"Search request body.", "required"=>false},
          url: {
            path: "/{index}/_mvt/{field}/{zoom}/{x}/{y}",
            paths: ["/{index}/_mvt/{field}/{zoom}/{x}/{y}"],
            parts: [
              "index",
              "field",
              "zoom",
              "x",
              "y",
            ],
            params: [
              "exact_bounds",
              "extent",
              "grid_precision",
              "grid_type",
              "size",
              "track_total_hits",
              "with_labels",
            ]
          }
        ),
        "search_shards" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/search-shards.html",
          methods: ["GET", "POST"],
          body: nil,
          url: {
            path: "/_search_shards",
            paths: ["/_search_shards", "/{index}/_search_shards"],
            parts: [
              "index",
            ],
            params: [
              "preference",
              "routing",
              "local",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "search_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition template and its params", "required"=>true},
          url: {
            path: "/_search/template",
            paths: ["/_search/template", "/{index}/_search/template"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "ignore_throttled",
              "allow_no_indices",
              "expand_wildcards",
              "preference",
              "routing",
              "scroll",
              "search_type",
              "explain",
              "profile",
              "typed_keys",
              "rest_total_hits_as_int",
              "ccs_minimize_roundtrips",
            ]
          }
        ),
        "searchable_snapshots.cache_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/searchable-snapshots-apis.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_searchable_snapshots/cache/stats",
            paths: ["/_searchable_snapshots/cache/stats", "/_searchable_snapshots/{node_id}/cache/stats"],
            parts: [
              "node_id",
            ],
          }
        ),
        "searchable_snapshots.clear_cache" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/searchable-snapshots-apis.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_searchable_snapshots/cache/clear",
            paths: ["/_searchable_snapshots/cache/clear", "/{index}/_searchable_snapshots/cache/clear"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "index",
            ]
          }
        ),
        "searchable_snapshots.mount" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/searchable-snapshots-api-mount-snapshot.html",
          methods: ["POST"],
          body: {"description"=>"The restore configuration for mounting the snapshot as searchable", "required"=>true},
          url: {
            path: "/_snapshot/{repository}/{snapshot}/_mount",
            paths: ["/_snapshot/{repository}/{snapshot}/_mount"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
              "wait_for_completion",
              "storage",
            ]
          }
        ),
        "searchable_snapshots.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/searchable-snapshots-apis.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_searchable_snapshots/stats",
            paths: ["/_searchable_snapshots/stats", "/{index}/_searchable_snapshots/stats"],
            parts: [
              "index",
            ],
            params: [
              "level",
            ]
          }
        ),
        "security.activate_user_profile" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-activate-user-profile.html",
          methods: ["POST"],
          body: {"description"=>"The grant type and user's credential", "required"=>true},
          url: {
            path: "/_security/profile/_activate",
            paths: ["/_security/profile/_activate"],
          }
        ),
        "security.authenticate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-authenticate.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/_authenticate",
            paths: ["/_security/_authenticate"],
          }
        ),
        "security.bulk_update_api_keys" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-bulk-update-api-keys.html",
          methods: ["POST"],
          body: {"description"=>"The API key request to update the attributes of multiple API keys.", "required"=>true},
          url: {
            path: "/_security/api_key/_bulk_update",
            paths: ["/_security/api_key/_bulk_update"],
          }
        ),
        "security.change_password" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-change-password.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"the new password for the user", "required"=>true},
          url: {
            path: "/_security/user/{username}/_password",
            paths: ["/_security/user/{username}/_password", "/_security/user/_password"],
            parts: [
              "username",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.clear_api_key_cache" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-api-key-cache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_security/api_key/{ids}/_clear_cache",
            paths: ["/_security/api_key/{ids}/_clear_cache"],
            parts: [
              "ids",
            ],
          }
        ),
        "security.clear_cached_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-privilege-cache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_security/privilege/{application}/_clear_cache",
            paths: ["/_security/privilege/{application}/_clear_cache"],
            parts: [
              "application",
            ],
          }
        ),
        "security.clear_cached_realms" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-cache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_security/realm/{realms}/_clear_cache",
            paths: ["/_security/realm/{realms}/_clear_cache"],
            parts: [
              "realms",
            ],
            params: [
              "usernames",
            ]
          }
        ),
        "security.clear_cached_roles" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-role-cache.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_security/role/{name}/_clear_cache",
            paths: ["/_security/role/{name}/_clear_cache"],
            parts: [
              "name",
            ],
          }
        ),
        "security.clear_cached_service_tokens" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-service-token-caches.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_security/service/{namespace}/{service}/credential/token/{name}/_clear_cache",
            paths: ["/_security/service/{namespace}/{service}/credential/token/{name}/_clear_cache"],
            parts: [
              "namespace",
              "service",
              "name",
            ],
          }
        ),
        "security.create_api_key" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-create-api-key.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The api key request to create an API key", "required"=>true},
          url: {
            path: "/_security/api_key",
            paths: ["/_security/api_key"],
            params: [
              "refresh",
            ]
          }
        ),
        "security.create_service_token" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-create-service-token.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_security/service/{namespace}/{service}/credential/token/{name}",
            paths: ["/_security/service/{namespace}/{service}/credential/token/{name}", "/_security/service/{namespace}/{service}/credential/token"],
            parts: [
              "namespace",
              "service",
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.delete_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-privilege.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_security/privilege/{application}/{name}",
            paths: ["/_security/privilege/{application}/{name}"],
            parts: [
              "application",
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.delete_role" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-role.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_security/role/{name}",
            paths: ["/_security/role/{name}"],
            parts: [
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.delete_role_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-role-mapping.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_security/role_mapping/{name}",
            paths: ["/_security/role_mapping/{name}"],
            parts: [
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.delete_service_token" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-service-token.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_security/service/{namespace}/{service}/credential/token/{name}",
            paths: ["/_security/service/{namespace}/{service}/credential/token/{name}"],
            parts: [
              "namespace",
              "service",
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.delete_user" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-user.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_security/user/{username}",
            paths: ["/_security/user/{username}"],
            parts: [
              "username",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.disable_user" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-disable-user.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_security/user/{username}/_disable",
            paths: ["/_security/user/{username}/_disable"],
            parts: [
              "username",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.disable_user_profile" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/security-api-disable-user-profile.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_security/profile/{uid}/_disable",
            paths: ["/_security/profile/{uid}/_disable"],
            parts: [
              "uid",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.enable_user" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-enable-user.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_security/user/{username}/_enable",
            paths: ["/_security/user/{username}/_enable"],
            parts: [
              "username",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.enable_user_profile" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/security-api-enable-user-profile.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_security/profile/{uid}/_enable",
            paths: ["/_security/profile/{uid}/_enable"],
            parts: [
              "uid",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.enroll_kibana" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/security-api-kibana-enrollment.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/enroll/kibana",
            paths: ["/_security/enroll/kibana"],
          }
        ),
        "security.enroll_node" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/security-api-node-enrollment.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/enroll/node",
            paths: ["/_security/enroll/node"],
          }
        ),
        "security.get_api_key" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-api-key.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/api_key",
            paths: ["/_security/api_key"],
            params: [
              "id",
              "name",
              "username",
              "realm_name",
              "owner",
              "with_limited_by",
            ]
          }
        ),
        "security.get_builtin_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-builtin-privileges.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/privilege/_builtin",
            paths: ["/_security/privilege/_builtin"],
          }
        ),
        "security.get_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-privileges.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/privilege",
            paths: ["/_security/privilege", "/_security/privilege/{application}", "/_security/privilege/{application}/{name}"],
            parts: [
              "application",
              "name",
            ],
          }
        ),
        "security.get_role" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-role.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/role/{name}",
            paths: ["/_security/role/{name}", "/_security/role"],
            parts: [
              "name",
            ],
          }
        ),
        "security.get_role_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-role-mapping.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/role_mapping/{name}",
            paths: ["/_security/role_mapping/{name}", "/_security/role_mapping"],
            parts: [
              "name",
            ],
          }
        ),
        "security.get_service_accounts" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-service-accounts.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/service/{namespace}/{service}",
            paths: ["/_security/service/{namespace}/{service}", "/_security/service/{namespace}", "/_security/service"],
            parts: [
              "namespace",
              "service",
            ],
          }
        ),
        "security.get_service_credentials" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-service-credentials.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/service/{namespace}/{service}/credential",
            paths: ["/_security/service/{namespace}/{service}/credential"],
            parts: [
              "namespace",
              "service",
            ],
          }
        ),
        "security.get_token" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-token.html",
          methods: ["POST"],
          body: {"description"=>"The token request to get", "required"=>true},
          url: {
            path: "/_security/oauth2/token",
            paths: ["/_security/oauth2/token"],
          }
        ),
        "security.get_user" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-user.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/user/{username}",
            paths: ["/_security/user/{username}", "/_security/user"],
            parts: [
              "username",
            ],
            params: [
              "with_profile_uid",
            ]
          }
        ),
        "security.get_user_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-user-privileges.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/user/_privileges",
            paths: ["/_security/user/_privileges"],
          }
        ),
        "security.get_user_profile" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-user-profile.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/profile/{uid}",
            paths: ["/_security/profile/{uid}"],
            parts: [
              "uid",
            ],
            params: [
              "data",
            ]
          }
        ),
        "security.grant_api_key" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-grant-api-key.html",
          methods: ["POST"],
          body: {"description"=>"The api key request to create an API key", "required"=>true},
          url: {
            path: "/_security/api_key/grant",
            paths: ["/_security/api_key/grant"],
            params: [
              "refresh",
            ]
          }
        ),
        "security.has_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-has-privileges.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The privileges to test", "required"=>true},
          url: {
            path: "/_security/user/_has_privileges",
            paths: ["/_security/user/_has_privileges", "/_security/user/{user}/_has_privileges"],
            parts: [
              "user",
            ],
          }
        ),
        "security.has_privileges_user_profile" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-has-privileges-user-profile.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The privileges to check and the list of profile IDs", "required"=>true},
          url: {
            path: "/_security/profile/_has_privileges",
            paths: ["/_security/profile/_has_privileges"],
          }
        ),
        "security.invalidate_api_key" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-invalidate-api-key.html",
          methods: ["DELETE"],
          body: {"description"=>"The api key request to invalidate API key(s)", "required"=>true},
          url: {
            path: "/_security/api_key",
            paths: ["/_security/api_key"],
          }
        ),
        "security.invalidate_token" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-invalidate-token.html",
          methods: ["DELETE"],
          body: {"description"=>"The token to invalidate", "required"=>true},
          url: {
            path: "/_security/oauth2/token",
            paths: ["/_security/oauth2/token"],
          }
        ),
        "security.oidc_authenticate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-oidc-authenticate.html",
          methods: ["POST"],
          body: {"description"=>"The OpenID Connect response to authenticate", "required"=>true},
          url: {
            path: "/_security/oidc/authenticate",
            paths: ["/_security/oidc/authenticate"],
          }
        ),
        "security.oidc_logout" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-oidc-logout.html",
          methods: ["POST"],
          body: {"description"=>"Access token and refresh token to invalidate", "required"=>true},
          url: {
            path: "/_security/oidc/logout",
            paths: ["/_security/oidc/logout"],
          }
        ),
        "security.oidc_prepare_authentication" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-oidc-prepare-authentication.html",
          methods: ["POST"],
          body: {"description"=>"The OpenID Connect authentication realm configuration", "required"=>true},
          url: {
            path: "/_security/oidc/prepare",
            paths: ["/_security/oidc/prepare"],
          }
        ),
        "security.put_privileges" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-privileges.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The privilege(s) to add", "required"=>true},
          url: {
            path: "/_security/privilege/",
            paths: ["/_security/privilege/"],
            params: [
              "refresh",
            ]
          }
        ),
        "security.put_role" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-role.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The role to add", "required"=>true},
          url: {
            path: "/_security/role/{name}",
            paths: ["/_security/role/{name}"],
            parts: [
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.put_role_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-role-mapping.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The role mapping to add", "required"=>true},
          url: {
            path: "/_security/role_mapping/{name}",
            paths: ["/_security/role_mapping/{name}"],
            parts: [
              "name",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.put_user" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-user.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The user to add", "required"=>true},
          url: {
            path: "/_security/user/{username}",
            paths: ["/_security/user/{username}"],
            parts: [
              "username",
            ],
            params: [
              "refresh",
            ]
          }
        ),
        "security.query_api_keys" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-query-api-key.html",
          methods: ["GET", "POST"],
          body: {"description"=>"From, size, query, sort and search_after", "required"=>false},
          url: {
            path: "/_security/_query/api_key",
            paths: ["/_security/_query/api_key"],
            params: [
              "with_limited_by",
            ]
          }
        ),
        "security.saml_authenticate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-authenticate.html",
          methods: ["POST"],
          body: {"description"=>"The SAML response to authenticate", "required"=>true},
          url: {
            path: "/_security/saml/authenticate",
            paths: ["/_security/saml/authenticate"],
          }
        ),
        "security.saml_complete_logout" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-complete-logout.html",
          methods: ["POST"],
          body: {"description"=>"The logout response to verify", "required"=>true},
          url: {
            path: "/_security/saml/complete_logout",
            paths: ["/_security/saml/complete_logout"],
          }
        ),
        "security.saml_invalidate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-invalidate.html",
          methods: ["POST"],
          body: {"description"=>"The LogoutRequest message", "required"=>true},
          url: {
            path: "/_security/saml/invalidate",
            paths: ["/_security/saml/invalidate"],
          }
        ),
        "security.saml_logout" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-logout.html",
          methods: ["POST"],
          body: {"description"=>"The tokens to invalidate", "required"=>true},
          url: {
            path: "/_security/saml/logout",
            paths: ["/_security/saml/logout"],
          }
        ),
        "security.saml_prepare_authentication" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-prepare-authentication.html",
          methods: ["POST"],
          body: {"description"=>"The realm for which to create the authentication request, identified by either its name or the ACS URL", "required"=>true},
          url: {
            path: "/_security/saml/prepare",
            paths: ["/_security/saml/prepare"],
          }
        ),
        "security.saml_service_provider_metadata" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-saml-sp-metadata.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_security/saml/metadata/{realm_name}",
            paths: ["/_security/saml/metadata/{realm_name}"],
            parts: [
              "realm_name",
            ],
          }
        ),
        "security.suggest_user_profiles" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/security-api-suggest-user-profile.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The suggestion definition for user profiles", "required"=>false},
          url: {
            path: "/_security/profile/_suggest",
            paths: ["/_security/profile/_suggest"],
            params: [
              "data",
            ]
          }
        ),
        "security.update_api_key" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-update-api-key.html",
          methods: ["PUT"],
          body: {"description"=>"The API key request to update attributes of an API key.", "required"=>false},
          url: {
            path: "/_security/api_key/{id}",
            paths: ["/_security/api_key/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "security.update_user_profile_data" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-update-user-profile-data.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The application data to update", "required"=>true},
          url: {
            path: "/_security/profile/{uid}/_data",
            paths: ["/_security/profile/{uid}/_data"],
            parts: [
              "uid",
            ],
            params: [
              "if_seq_no",
              "if_primary_term",
              "refresh",
            ]
          }
        ),
        "shutdown.delete_node" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_nodes/{node_id}/shutdown",
            paths: ["/_nodes/{node_id}/shutdown"],
            parts: [
              "node_id",
            ],
          }
        ),
        "shutdown.get_node" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/shutdown",
            paths: ["/_nodes/shutdown", "/_nodes/{node_id}/shutdown"],
            parts: [
              "node_id",
            ],
          }
        ),
        "shutdown.put_node" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current",
          methods: ["PUT"],
          body: {"description"=>"The shutdown type definition to register", "required"=>true},
          url: {
            path: "/_nodes/{node_id}/shutdown",
            paths: ["/_nodes/{node_id}/shutdown"],
            parts: [
              "node_id",
            ],
          }
        ),
        "slm.delete_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-delete-policy.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_slm/policy/{policy_id}",
            paths: ["/_slm/policy/{policy_id}"],
            parts: [
              "policy_id",
            ],
          }
        ),
        "slm.execute_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-execute-lifecycle.html",
          methods: ["PUT"],
          body: nil,
          url: {
            path: "/_slm/policy/{policy_id}/_execute",
            paths: ["/_slm/policy/{policy_id}/_execute"],
            parts: [
              "policy_id",
            ],
          }
        ),
        "slm.execute_retention" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-execute-retention.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_slm/_execute_retention",
            paths: ["/_slm/_execute_retention"],
          }
        ),
        "slm.get_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-get-policy.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_slm/policy/{policy_id}",
            paths: ["/_slm/policy/{policy_id}", "/_slm/policy"],
            parts: [
              "policy_id",
            ],
          }
        ),
        "slm.get_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/slm-api-get-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_slm/stats",
            paths: ["/_slm/stats"],
          }
        ),
        "slm.get_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-get-status.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_slm/status",
            paths: ["/_slm/status"],
          }
        ),
        "slm.put_lifecycle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-put-policy.html",
          methods: ["PUT"],
          body: {"description"=>"The snapshot lifecycle policy definition to register"},
          url: {
            path: "/_slm/policy/{policy_id}",
            paths: ["/_slm/policy/{policy_id}"],
            parts: [
              "policy_id",
            ],
          }
        ),
        "slm.start" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-start.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_slm/start",
            paths: ["/_slm/start"],
          }
        ),
        "slm.stop" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/slm-api-stop.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_slm/stop",
            paths: ["/_slm/stop"],
          }
        ),
        "snapshot.cleanup_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/clean-up-snapshot-repo-api.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}/_cleanup",
            paths: ["/_snapshot/{repository}/_cleanup"],
            parts: [
              "repository",
            ],
            params: [
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "snapshot.clone" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["PUT"],
          body: {"description"=>"The snapshot clone definition", "required"=>true},
          url: {
            path: "/_snapshot/{repository}/{snapshot}/_clone/{target_snapshot}",
            paths: ["/_snapshot/{repository}/{snapshot}/_clone/{target_snapshot}"],
            parts: [
              "repository",
              "snapshot",
              "target_snapshot",
            ],
            params: [
              "master_timeout",
            ]
          }
        ),
        "snapshot.create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The snapshot definition", "required"=>false},
          url: {
            path: "/_snapshot/{repository}/{snapshot}",
            paths: ["/_snapshot/{repository}/{snapshot}"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
              "wait_for_completion",
            ]
          }
        ),
        "snapshot.create_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The repository definition", "required"=>true},
          url: {
            path: "/_snapshot/{repository}",
            paths: ["/_snapshot/{repository}"],
            parts: [
              "repository",
            ],
            params: [
              "master_timeout",
              "timeout",
              "verify",
            ]
          }
        ),
        "snapshot.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}/{snapshot}",
            paths: ["/_snapshot/{repository}/{snapshot}"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
            ]
          }
        ),
        "snapshot.delete_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}",
            paths: ["/_snapshot/{repository}"],
            parts: [
              "repository",
            ],
            params: [
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "snapshot.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}/{snapshot}",
            paths: ["/_snapshot/{repository}/{snapshot}"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
              "ignore_unavailable",
              "index_names",
              "index_details",
              "include_repository",
              "sort",
              "size",
              "order",
              "from_sort_value",
              "after",
              "offset",
              "slm_policy_filter",
              "verbose",
            ]
          }
        ),
        "snapshot.get_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_snapshot",
            paths: ["/_snapshot", "/_snapshot/{repository}"],
            parts: [
              "repository",
            ],
            params: [
              "master_timeout",
              "local",
            ]
          }
        ),
        "snapshot.repository_analyze" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}/_analyze",
            paths: ["/_snapshot/{repository}/_analyze"],
            parts: [
              "repository",
            ],
            params: [
              "blob_count",
              "concurrency",
              "read_node_count",
              "early_read_node_count",
              "seed",
              "rare_action_probability",
              "max_blob_size",
              "max_total_data_size",
              "timeout",
              "detailed",
              "rarely_abort_writes",
            ]
          }
        ),
        "snapshot.restore" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["POST"],
          body: {"description"=>"Details of what to restore", "required"=>false},
          url: {
            path: "/_snapshot/{repository}/{snapshot}/_restore",
            paths: ["/_snapshot/{repository}/{snapshot}/_restore"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
              "wait_for_completion",
            ]
          }
        ),
        "snapshot.status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_snapshot/_status",
            paths: ["/_snapshot/_status", "/_snapshot/{repository}/_status", "/_snapshot/{repository}/{snapshot}/_status"],
            parts: [
              "repository",
              "snapshot",
            ],
            params: [
              "master_timeout",
              "ignore_unavailable",
            ]
          }
        ),
        "snapshot.verify_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/modules-snapshots.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_snapshot/{repository}/_verify",
            paths: ["/_snapshot/{repository}/_verify"],
            parts: [
              "repository",
            ],
            params: [
              "master_timeout",
              "timeout",
            ]
          }
        ),
        "sql.clear_cursor" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/clear-sql-cursor-api.html",
          methods: ["POST"],
          body: {"description"=>"Specify the cursor value in the `cursor` element to clean the cursor.", "required"=>true},
          url: {
            path: "/_sql/close",
            paths: ["/_sql/close"],
          }
        ),
        "sql.delete_async" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/delete-async-sql-search-api.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_sql/async/delete/{id}",
            paths: ["/_sql/async/delete/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "sql.get_async" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-async-sql-search-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_sql/async/{id}",
            paths: ["/_sql/async/{id}"],
            parts: [
              "id",
            ],
            params: [
              "delimiter",
              "format",
              "keep_alive",
              "wait_for_completion_timeout",
            ]
          }
        ),
        "sql.get_async_status" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/get-async-sql-search-status-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_sql/async/status/{id}",
            paths: ["/_sql/async/status/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "sql.query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-search-api.html",
          methods: ["POST", "GET"],
          body: {"description"=>"Use the `query` element to start a query. Use the `cursor` element to continue a query.", "required"=>true},
          url: {
            path: "/_sql",
            paths: ["/_sql"],
            params: [
              "format",
            ]
          }
        ),
        "sql.translate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-translate-api.html",
          methods: ["POST", "GET"],
          body: {"description"=>"Specify the query in the `query` element.", "required"=>true},
          url: {
            path: "/_sql/translate",
            paths: ["/_sql/translate"],
          }
        ),
        "ssl.certificates" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-ssl.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ssl/certificates",
            paths: ["/_ssl/certificates"],
          }
        ),
        "tasks.cancel" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/tasks.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_tasks/_cancel",
            paths: ["/_tasks/_cancel", "/_tasks/{task_id}/_cancel"],
            parts: [
              "task_id",
            ],
            params: [
              "nodes",
              "actions",
              "parent_task_id",
              "wait_for_completion",
            ]
          }
        ),
        "tasks.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_tasks/{task_id}",
            paths: ["/_tasks/{task_id}"],
            parts: [
              "task_id",
            ],
            params: [
              "wait_for_completion",
              "timeout",
            ]
          }
        ),
        "tasks.list" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_tasks",
            paths: ["/_tasks"],
            params: [
              "nodes",
              "actions",
              "detailed",
              "parent_task_id",
              "wait_for_completion",
              "group_by",
              "timeout",
            ]
          }
        ),
        "terms_enum" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/search-terms-enum.html",
          methods: ["GET", "POST"],
          body: {"description"=>"field name, string which is the prefix expected in matching terms, timeout and size for max number of results"},
          url: {
            path: "/{index}/_terms_enum",
            paths: ["/{index}/_terms_enum"],
            parts: [
              "index",
            ],
          }
        ),
        "termvectors" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-termvectors.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Define parameters and or supply a document to get termvectors for. See documentation.", "required"=>false},
          url: {
            path: "/{index}/_termvectors/{id}",
            paths: ["/{index}/_termvectors/{id}", "/{index}/_termvectors"],
            parts: [
              "index",
              "id",
            ],
            params: [
              "term_statistics",
              "field_statistics",
              "fields",
              "offsets",
              "positions",
              "payloads",
              "preference",
              "routing",
              "realtime",
              "version",
              "version_type",
            ]
          }
        ),
        "text_structure.find_structure" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/find-structure.html",
          methods: ["POST"],
          body: {"description"=>"The contents of the file to be analyzed", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_text_structure/find_structure",
            paths: ["/_text_structure/find_structure"],
            params: [
              "lines_to_sample",
              "line_merge_size_limit",
              "timeout",
              "charset",
              "format",
              "has_header_row",
              "column_names",
              "delimiter",
              "quote",
              "should_trim_fields",
              "grok_pattern",
              "ecs_compatibility",
              "timestamp_field",
              "timestamp_format",
              "explain",
            ]
          }
        ),
        "transform.delete_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-transform.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}",
            paths: ["/_transform/{transform_id}"],
            parts: [
              "transform_id",
            ],
            params: [
              "force",
              "timeout",
            ]
          }
        ),
        "transform.get_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-transform.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}",
            paths: ["/_transform/{transform_id}", "/_transform"],
            parts: [
              "transform_id",
            ],
            params: [
              "from",
              "size",
              "allow_no_match",
              "exclude_generated",
            ]
          }
        ),
        "transform.get_transform_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/get-transform-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}/_stats",
            paths: ["/_transform/{transform_id}/_stats"],
            parts: [
              "transform_id",
            ],
            params: [
              "from",
              "size",
              "timeout",
              "allow_no_match",
            ]
          }
        ),
        "transform.preview_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/preview-transform.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The definition for the transform to preview", "required"=>false},
          url: {
            path: "/_transform/{transform_id}/_preview",
            paths: ["/_transform/{transform_id}/_preview", "/_transform/_preview"],
            parts: [
              "transform_id",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "transform.put_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/put-transform.html",
          methods: ["PUT"],
          body: {"description"=>"The transform definition", "required"=>true},
          url: {
            path: "/_transform/{transform_id}",
            paths: ["/_transform/{transform_id}"],
            parts: [
              "transform_id",
            ],
            params: [
              "defer_validation",
              "timeout",
            ]
          }
        ),
        "transform.reset_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/reset-transform.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}/_reset",
            paths: ["/_transform/{transform_id}/_reset"],
            parts: [
              "transform_id",
            ],
            params: [
              "force",
              "timeout",
            ]
          }
        ),
        "transform.schedule_now_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/schedule-now-transform.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}/_schedule_now",
            paths: ["/_transform/{transform_id}/_schedule_now"],
            parts: [
              "transform_id",
            ],
            params: [
              "timeout",
            ]
          }
        ),
        "transform.start_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/start-transform.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}/_start",
            paths: ["/_transform/{transform_id}/_start"],
            parts: [
              "transform_id",
            ],
            params: [
              "from",
              "timeout",
            ]
          }
        ),
        "transform.stop_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/stop-transform.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_transform/{transform_id}/_stop",
            paths: ["/_transform/{transform_id}/_stop"],
            parts: [
              "transform_id",
            ],
            params: [
              "force",
              "wait_for_completion",
              "timeout",
              "allow_no_match",
              "wait_for_checkpoint",
            ]
          }
        ),
        "transform.update_transform" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/update-transform.html",
          methods: ["POST"],
          body: {"description"=>"The update transform definition", "required"=>true},
          url: {
            path: "/_transform/{transform_id}/_update",
            paths: ["/_transform/{transform_id}/_update"],
            parts: [
              "transform_id",
            ],
            params: [
              "defer_validation",
              "timeout",
            ]
          }
        ),
        "transform.upgrade_transforms" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/upgrade-transforms.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_transform/_upgrade",
            paths: ["/_transform/_upgrade"],
            params: [
              "dry_run",
              "timeout",
            ]
          }
        ),
        "update" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-update.html",
          methods: ["POST"],
          body: {"description"=>"The request definition requires either `script` or partial `doc`", "required"=>true},
          url: {
            path: "/{index}/_update/{id}",
            paths: ["/{index}/_update/{id}"],
            parts: [
              "id",
              "index",
            ],
            params: [
              "wait_for_active_shards",
              "_source",
              "_source_excludes",
              "_source_includes",
              "lang",
              "refresh",
              "retry_on_conflict",
              "routing",
              "timeout",
              "if_seq_no",
              "if_primary_term",
              "require_alias",
            ]
          }
        ),
        "update_by_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/master/docs-update-by-query.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/{index}/_update_by_query",
            paths: ["/{index}/_update_by_query"],
            parts: [
              "index",
            ],
            params: [
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "from",
              "ignore_unavailable",
              "allow_no_indices",
              "conflicts",
              "expand_wildcards",
              "lenient",
              "pipeline",
              "preference",
              "q",
              "routing",
              "scroll",
              "search_type",
              "search_timeout",
              "max_docs",
              "sort",
              "terminate_after",
              "stats",
              "version",
              "version_type",
              "request_cache",
              "refresh",
              "timeout",
              "wait_for_active_shards",
              "scroll_size",
              "wait_for_completion",
              "requests_per_second",
              "slices",
            ]
          }
        ),
        "update_by_query_rethrottle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_update_by_query/{task_id}/_rethrottle",
            paths: ["/_update_by_query/{task_id}/_rethrottle"],
            parts: [
              "task_id",
            ],
            params: [
              "requests_per_second",
            ]
          }
        ),
        "watcher.ack_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-ack-watch.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_watcher/watch/{watch_id}/_ack",
            paths: ["/_watcher/watch/{watch_id}/_ack", "/_watcher/watch/{watch_id}/_ack/{action_id}"],
            parts: [
              "watch_id",
              "action_id",
            ],
          }
        ),
        "watcher.activate_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-activate-watch.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_watcher/watch/{watch_id}/_activate",
            paths: ["/_watcher/watch/{watch_id}/_activate"],
            parts: [
              "watch_id",
            ],
          }
        ),
        "watcher.deactivate_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-deactivate-watch.html",
          methods: ["PUT", "POST"],
          body: nil,
          url: {
            path: "/_watcher/watch/{watch_id}/_deactivate",
            paths: ["/_watcher/watch/{watch_id}/_deactivate"],
            parts: [
              "watch_id",
            ],
          }
        ),
        "watcher.delete_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-delete-watch.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_watcher/watch/{id}",
            paths: ["/_watcher/watch/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "watcher.execute_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-execute-watch.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"Execution control", "required"=>false},
          url: {
            path: "/_watcher/watch/{id}/_execute",
            paths: ["/_watcher/watch/{id}/_execute", "/_watcher/watch/_execute"],
            parts: [
              "id",
            ],
            params: [
              "debug",
            ]
          }
        ),
        "watcher.get_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-get-watch.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_watcher/watch/{id}",
            paths: ["/_watcher/watch/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "watcher.put_watch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-put-watch.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The watch", "required"=>false},
          url: {
            path: "/_watcher/watch/{id}",
            paths: ["/_watcher/watch/{id}"],
            parts: [
              "id",
            ],
            params: [
              "active",
              "version",
              "if_seq_no",
              "if_primary_term",
            ]
          }
        ),
        "watcher.query_watches" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-query-watches.html",
          methods: ["GET", "POST"],
          body: {"description"=>"From, size, query, sort and search_after", "required"=>false},
          url: {
            path: "/_watcher/_query/watches",
            paths: ["/_watcher/_query/watches"],
          }
        ),
        "watcher.start" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-start.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_watcher/_start",
            paths: ["/_watcher/_start"],
          }
        ),
        "watcher.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_watcher/stats",
            paths: ["/_watcher/stats", "/_watcher/stats/{metric}"],
            parts: [
              "metric",
            ],
            params: [
              "metric",
              "emit_stacktraces",
            ]
          }
        ),
        "watcher.stop" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-stop.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_watcher/_stop",
            paths: ["/_watcher/_stop"],
          }
        ),
        "xpack.info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/info-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_xpack",
            paths: ["/_xpack"],
            params: [
              "categories",
              "accept_enterprise",
            ]
          }
        ),
        "xpack.usage" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/usage-api.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_xpack/usage",
            paths: ["/_xpack/usage"],
            params: [
              "master_timeout",
            ]
          }
        ),
      }
      @common_params = [
        "pretty",
        "human",
        "error_trace",
        "source",
        "filter_path",
      ]
      super
    end
  end
end
