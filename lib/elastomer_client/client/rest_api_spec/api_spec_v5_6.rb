# frozen_string_literal: true
# Generated REST API spec file - DO NOT EDIT!
# Date: 2023-11-30
# ES version: 5.6

module ElastomerClient::Client::RestApiSpec
  class ApiSpecV5_6 < ApiSpec
    def initialize
      @rest_apis = {
        "bulk" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-bulk.html",
          methods: ["POST", "PUT"],
          body: {"description"=>"The operation definition and data (action-data pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_bulk",
            paths: ["/_bulk", "/{index}/_bulk", "/{index}/{type}/_bulk"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "wait_for_active_shards",
              "refresh",
              "routing",
              "timeout",
              "type",
              "fields",
              "_source",
              "_source_exclude",
              "_source_include",
              "pipeline",
            ]
          }
        ),
        "cat.aliases" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-alias.html",
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
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.allocation" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-allocation.html",
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
        "cat.count" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-count.html",
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
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.fielddata" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-fielddata.html",
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
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
              "fields",
            ]
          }
        ),
        "cat.health" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-health.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/health",
            paths: ["/_cat/health"],
            params: [
              "format",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "ts",
              "v",
            ]
          }
        ),
        "cat.help" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-indices.html",
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
              "local",
              "master_timeout",
              "h",
              "health",
              "help",
              "pri",
              "s",
              "v",
            ]
          }
        ),
        "cat.master" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-master.html",
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
        "cat.nodeattrs" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-nodeattrs.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-nodes.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/nodes",
            paths: ["/_cat/nodes"],
            params: [
              "format",
              "full_id",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.pending_tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-pending-tasks.html",
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
              "v",
            ]
          }
        ),
        "cat.plugins" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-plugins.html",
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
              "s",
              "v",
            ]
          }
        ),
        "cat.recovery" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-recovery.html",
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
              "bytes",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.repositories" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-repositories.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-segments.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-shards.html",
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
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.snapshots" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-snapshots.html",
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
              "v",
            ]
          }
        ),
        "cat.tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cat/tasks",
            paths: ["/_cat/tasks"],
            params: [
              "format",
              "node_id",
              "actions",
              "detailed",
              "parent_node",
              "parent_task",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "cat.templates" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-templates.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cat-thread-pool.html",
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
              "size",
              "local",
              "master_timeout",
              "h",
              "help",
              "s",
              "v",
            ]
          }
        ),
        "clear_scroll" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-request-scroll.html",
          methods: ["DELETE"],
          body: {"description"=>"A comma-separated list of scroll IDs to clear if none was specified via the scroll_id parameter"},
          url: {
            path: "/_search/scroll/{scroll_id}",
            paths: ["/_search/scroll/{scroll_id}", "/_search/scroll"],
            parts: [
              "scroll_id",
            ],
          }
        ),
        "cluster.allocation_explain" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-allocation-explain.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The index, shard, and primary flag to explain. Empty means 'explain the first unassigned shard'"},
          url: {
            path: "/_cluster/allocation/explain",
            paths: ["/_cluster/allocation/explain"],
            params: [
              "include_yes_decisions",
              "include_disk_info",
            ]
          }
        ),
        "cluster.get_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-update-settings.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-health.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/health",
            paths: ["/_cluster/health", "/_cluster/health/{index}"],
            parts: [
              "index",
            ],
            params: [
              "level",
              "local",
              "master_timeout",
              "timeout",
              "wait_for_active_shards",
              "wait_for_nodes",
              "wait_for_events",
              "wait_for_no_relocating_shards",
              "wait_for_status",
            ]
          }
        ),
        "cluster.pending_tasks" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-pending.html",
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
        "cluster.put_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-update-settings.html",
          methods: ["PUT"],
          body: {"description"=>"The settings to be updated. Can be either `transient` or `persistent` (survives cluster restart)."},
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
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-remote-info.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_remote/info",
            paths: ["/_remote/info"],
          }
        ),
        "cluster.reroute" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-reroute.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-state.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_cluster/state",
            paths: ["/_cluster/state", "/_cluster/state/{metric}", "/_cluster/state/{metric}/{index}"],
            parts: [
              "index",
              "metric",
            ],
            params: [
              "local",
              "master_timeout",
              "flat_settings",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "cluster.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-stats.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-count.html",
          methods: ["POST", "GET"],
          body: {"description"=>"A query to restrict the results specified with the Query DSL (optional)"},
          url: {
            path: "/_count",
            paths: ["/_count", "/{index}/_count", "/{index}/{type}/_count"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "ignore_unavailable",
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
        "count_percolate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-percolate.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The count percolator request definition using the percolate DSL", "required"=>false},
          url: {
            path: "/{index}/{type}/_percolate/count",
            paths: ["/{index}/{type}/_percolate/count", "/{index}/{type}/{id}/_percolate/count"],
            parts: [
              "index",
              "type",
              "id",
            ],
            params: [
              "routing",
              "preference",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "percolate_index",
              "percolate_type",
              "version",
              "version_type",
            ]
          }
        ),
        "create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-index_.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/{index}/{type}/{id}/_create",
            paths: ["/{index}/{type}/{id}/_create"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "wait_for_active_shards",
              "parent",
              "refresh",
              "routing",
              "timeout",
              "timestamp",
              "ttl",
              "version",
              "version_type",
              "pipeline",
            ]
          }
        ),
        "delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-delete.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/{index}/{type}/{id}",
            paths: ["/{index}/{type}/{id}"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "wait_for_active_shards",
              "parent",
              "refresh",
              "routing",
              "timeout",
              "version",
              "version_type",
            ]
          }
        ),
        "delete_by_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-delete-by-query.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL", "required"=>true},
          url: {
            path: "/{index}/_delete_by_query",
            paths: ["/{index}/_delete_by_query", "/{index}/{type}/_delete_by_query"],
            parts: [
              "index",
              "type",
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
              "size",
              "sort",
              "_source",
              "_source_exclude",
              "_source_include",
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
        "delete_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-scripting.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_scripts/{lang}",
            paths: ["/_scripts/{lang}", "/_scripts/{lang}/{id}"],
            parts: [
              "id",
              "lang",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "delete_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-template.html",
          methods: ["DELETE"],
          body: nil,
          url: {
            path: "/_search/template/{id}",
            paths: ["/_search/template/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "exists" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-get.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}/{type}/{id}",
            paths: ["/{index}/{type}/{id}"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "stored_fields",
              "parent",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
              "version",
              "version_type",
            ]
          }
        ),
        "exists_source" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/master/docs-get.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}/{type}/{id}/_source",
            paths: ["/{index}/{type}/{id}/_source"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "parent",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
              "version",
              "version_type",
            ]
          }
        ),
        "explain" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-explain.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The query definition using the Query DSL"},
          url: {
            path: "/{index}/{type}/{id}/_explain",
            paths: ["/{index}/{type}/{id}/_explain"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "analyze_wildcard",
              "analyzer",
              "default_operator",
              "df",
              "stored_fields",
              "lenient",
              "parent",
              "preference",
              "q",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
            ]
          }
        ),
        "field_caps" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-field-caps.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Field json objects containing an array of field names", "required"=>false},
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
            ]
          }
        ),
        "field_stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-field-stats.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Field json objects containing the name and optionally a range to filter out indices result, that have results outside the defined bounds", "required"=>false},
          url: {
            path: "/_field_stats",
            paths: ["/_field_stats", "/{index}/_field_stats"],
            parts: [
              "index",
            ],
            params: [
              "fields",
              "level",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-get.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/{type}/{id}",
            paths: ["/{index}/{type}/{id}"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "stored_fields",
              "parent",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
              "version",
              "version_type",
            ]
          }
        ),
        "get_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-scripting.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_scripts/{lang}",
            paths: ["/_scripts/{lang}", "/_scripts/{lang}/{id}"],
            parts: [
              "id",
              "lang",
            ],
          }
        ),
        "get_source" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-get.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}/{type}/{id}/_source",
            paths: ["/{index}/{type}/{id}/_source"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "parent",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
              "version",
              "version_type",
            ]
          }
        ),
        "get_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-template.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_search/template/{id}",
            paths: ["/_search/template/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "index" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-index_.html",
          methods: ["POST", "PUT"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/{index}/{type}",
            paths: ["/{index}/{type}", "/{index}/{type}/{id}"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "wait_for_active_shards",
              "op_type",
              "parent",
              "refresh",
              "routing",
              "timeout",
              "timestamp",
              "ttl",
              "version",
              "version_type",
              "pipeline",
            ]
          }
        ),
        "indices.analyze" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-analyze.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The text on which the analysis should be performed"},
          url: {
            path: "/_analyze",
            paths: ["/_analyze", "/{index}/_analyze"],
            parts: [
              "index",
            ],
            params: [
              "analyzer",
              "char_filter",
              "field",
              "filter",
              "index",
              "prefer_local",
              "text",
              "tokenizer",
              "explain",
              "attributes",
              "format",
            ]
          }
        ),
        "indices.clear_cache" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-clearcache.html",
          methods: ["POST", "GET"],
          body: nil,
          url: {
            path: "/_cache/clear",
            paths: ["/_cache/clear", "/{index}/_cache/clear"],
            parts: [
              "index",
            ],
            params: [
              "field_data",
              "fielddata",
              "fields",
              "query",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "index",
              "recycler",
              "request_cache",
              "request",
            ]
          }
        ),
        "indices.close" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-open-close.html",
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
            ]
          }
        ),
        "indices.create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-create-index.html",
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
              "update_all_types",
            ]
          }
        ),
        "indices.delete" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-delete-index.html",
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
            ]
          }
        ),
        "indices.delete_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-aliases.html",
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
        "indices.delete_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-templates.html",
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
        "indices.exists" => RestApi.new(
          documentation: "http://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-exists.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-aliases.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/_alias/{name}",
            paths: ["/_alias/{name}", "/{index}/_alias/{name}"],
            parts: [
              "index",
              "name",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.exists_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-templates.html",
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
        "indices.exists_type" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-types-exists.html",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/{index}/_mapping/{type}",
            paths: ["/{index}/_mapping/{type}"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.flush" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-flush.html",
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
        "indices.flush_synced" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-synced-flush.html",
          methods: ["POST", "GET"],
          body: nil,
          url: {
            path: "/_flush/synced",
            paths: ["/_flush/synced", "/{index}/_flush/synced"],
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
        "indices.forcemerge" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-forcemerge.html",
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
              "operation_threading",
              "wait_for_merge",
            ]
          }
        ),
        "indices.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-get-index.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/{index}",
            paths: ["/{index}", "/{index}/{feature}"],
            parts: [
              "index",
              "feature",
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
        "indices.get_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-aliases.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_alias/",
            paths: ["/_alias", "/_alias/{name}", "/{index}/_alias/{name}", "/{index}/_alias"],
            parts: [
              "index",
              "name",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.get_field_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-get-field-mapping.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_mapping/field/{fields}",
            paths: ["/_mapping/field/{fields}", "/{index}/_mapping/field/{fields}", "/_mapping/{type}/field/{fields}", "/{index}/_mapping/{type}/field/{fields}"],
            parts: [
              "index",
              "type",
              "fields",
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
        "indices.get_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-get-mapping.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_mapping",
            paths: ["/_mapping", "/{index}/_mapping", "/_mapping/{type}", "/{index}/_mapping/{type}"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "local",
            ]
          }
        ),
        "indices.get_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-get-settings.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-templates.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_template/{name}",
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
        "indices.get_upgrade" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-upgrade.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_upgrade",
            paths: ["/_upgrade", "/{index}/_upgrade"],
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
        "indices.open" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-open-close.html",
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
            ]
          }
        ),
        "indices.put_alias" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-aliases.html",
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
        "indices.put_mapping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-put-mapping.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The mapping definition", "required"=>true},
          url: {
            path: "/{index}/{type}/_mapping",
            paths: ["/{index}/{type}/_mapping", "/{index}/_mapping/{type}", "/_mapping/{type}", "/{index}/{type}/_mappings", "/{index}/_mappings/{type}", "/_mappings/{type}"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "timeout",
              "master_timeout",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "update_all_types",
            ]
          }
        ),
        "indices.put_settings" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-update-settings.html",
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
              "preserve_existing",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "flat_settings",
            ]
          }
        ),
        "indices.put_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-templates.html",
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
              "timeout",
              "master_timeout",
              "flat_settings",
            ]
          }
        ),
        "indices.recovery" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-recovery.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-refresh.html",
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
        "indices.rollover" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-rollover-index.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-segments.html",
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
              "operation_threading",
              "verbose",
            ]
          }
        ),
        "indices.shard_stores" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-shards-stores.html",
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
              "operation_threading",
            ]
          }
        ),
        "indices.shrink" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-shrink-index.html",
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
        "indices.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_stats",
            paths: ["/_stats", "/_stats/{metric}", "/{index}/_stats", "/{index}/_stats/{metric}"],
            parts: [
              "index",
              "metric",
            ],
            params: [
              "completion_fields",
              "fielddata_fields",
              "fields",
              "groups",
              "level",
              "types",
              "include_segment_file_sizes",
            ]
          }
        ),
        "indices.update_aliases" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-aliases.html",
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
        "indices.upgrade" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/indices-upgrade.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_upgrade",
            paths: ["/_upgrade", "/{index}/_upgrade"],
            parts: [
              "index",
            ],
            params: [
              "allow_no_indices",
              "expand_wildcards",
              "ignore_unavailable",
              "wait_for_completion",
              "only_ancient_segments",
            ]
          }
        ),
        "indices.validate_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-validate.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The query definition specified with the Query DSL"},
          url: {
            path: "/_validate/query",
            paths: ["/_validate/query", "/{index}/_validate/query", "/{index}/{type}/_validate/query"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "explain",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "operation_threading",
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
          documentation: "https://www.elastic.co/guide/",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/",
            paths: ["/"],
          }
        ),
        "ingest.delete_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/plugins/5.x/ingest.html",
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
        "ingest.get_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/plugins/5.x/ingest.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ingest/pipeline/{id}",
            paths: ["/_ingest/pipeline", "/_ingest/pipeline/{id}"],
            parts: [
              "id",
            ],
            params: [
              "master_timeout",
            ]
          }
        ),
        "ingest.processor_grok" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/plugins/master/ingest.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_ingest/processor/grok",
            paths: ["/_ingest/processor/grok"],
          }
        ),
        "ingest.put_pipeline" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/plugins/5.x/ingest.html",
          methods: ["PUT"],
          body: {"description"=>"The ingest definition", "required"=>true},
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
        "ingest.simulate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/plugins/5.x/ingest.html",
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
        "mget" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-multi-get.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Document identifiers; can be either `docs` (containing full document information) or `ids` (when index and type is provided in the URL.", "required"=>true},
          url: {
            path: "/_mget",
            paths: ["/_mget", "/{index}/_mget", "/{index}/{type}/_mget"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "stored_fields",
              "preference",
              "realtime",
              "refresh",
              "routing",
              "_source",
              "_source_exclude",
              "_source_include",
            ]
          }
        ),
        "mpercolate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-percolate.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The percolate request definitions (header & body pair), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_mpercolate",
            paths: ["/_mpercolate", "/{index}/_mpercolate", "/{index}/{type}/_mpercolate"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
            ]
          }
        ),
        "msearch" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-multi-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The request definitions (metadata-search request definition pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_msearch",
            paths: ["/_msearch", "/{index}/_msearch", "/{index}/{type}/_msearch"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "search_type",
              "max_concurrent_searches",
              "typed_keys",
              "pre_filter_shard_size",
            ]
          }
        ),
        "msearch_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The request definitions (metadata-search request definition pairs), separated by newlines", "required"=>true, "serialize"=>"bulk"},
          url: {
            path: "/_msearch/template",
            paths: ["/_msearch/template", "/{index}/_msearch/template", "/{index}/{type}/_msearch/template"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "search_type",
              "typed_keys",
              "max_concurrent_searches",
            ]
          }
        ),
        "mtermvectors" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-multi-termvectors.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Define ids, documents, parameters or a list of parameters per document here. You must at least provide a list of document ids. See documentation.", "required"=>false},
          url: {
            path: "/_mtermvectors",
            paths: ["/_mtermvectors", "/{index}/_mtermvectors", "/{index}/{type}/_mtermvectors"],
            parts: [
              "index",
              "type",
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
              "parent",
              "realtime",
              "version",
              "version_type",
            ]
          }
        ),
        "nodes.hot_threads" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-nodes-hot-threads.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/hot_threads",
            paths: ["/_cluster/nodes/hotthreads", "/_cluster/nodes/hot_threads", "/_cluster/nodes/{node_id}/hotthreads", "/_cluster/nodes/{node_id}/hot_threads", "/_nodes/hotthreads", "/_nodes/hot_threads", "/_nodes/{node_id}/hotthreads", "/_nodes/{node_id}/hot_threads"],
            parts: [
              "node_id",
            ],
            params: [
              "interval",
              "snapshots",
              "threads",
              "ignore_idle_threads",
              "type",
              "timeout",
            ]
          }
        ),
        "nodes.info" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-nodes-info.html",
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
        "nodes.stats" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/cluster-nodes-stats.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_nodes/stats",
            paths: ["/_nodes/stats", "/_nodes/{node_id}/stats", "/_nodes/stats/{metric}", "/_nodes/{node_id}/stats/{metric}", "/_nodes/stats/{metric}/{index_metric}", "/_nodes/{node_id}/stats/{metric}/{index_metric}"],
            parts: [
              "metric",
              "index_metric",
              "node_id",
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
            ]
          }
        ),
        "percolate" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-percolate.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The percolator request definition using the percolate DSL", "required"=>false},
          url: {
            path: "/{index}/{type}/_percolate",
            paths: ["/{index}/{type}/_percolate", "/{index}/{type}/{id}/_percolate"],
            parts: [
              "index",
              "type",
              "id",
            ],
            params: [
              "routing",
              "preference",
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "percolate_index",
              "percolate_type",
              "percolate_routing",
              "percolate_preference",
              "percolate_format",
              "version",
              "version_type",
            ]
          }
        ),
        "ping" => RestApi.new(
          documentation: "https://www.elastic.co/guide/",
          methods: ["HEAD"],
          body: nil,
          url: {
            path: "/",
            paths: ["/"],
          }
        ),
        "put_script" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-scripting.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/_scripts/{lang}",
            paths: ["/_scripts/{lang}", "/_scripts/{lang}/{id}"],
            parts: [
              "id",
              "lang",
            ],
            params: [
              "timeout",
              "master_timeout",
            ]
          }
        ),
        "put_template" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-template.html",
          methods: ["PUT", "POST"],
          body: {"description"=>"The document", "required"=>true},
          url: {
            path: "/_search/template/{id}",
            paths: ["/_search/template/{id}"],
            parts: [
              "id",
            ],
          }
        ),
        "reindex" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-reindex.html",
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
              "slices",
            ]
          }
        ),
        "reindex_rethrottle" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-reindex.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_reindex/{task_id}/_rethrottle",
            paths: ["/_reindex/{task_id}/_rethrottle", "/_update_by_query/{task_id}/_rethrottle", "/_delete_by_query/{task_id}/_rethrottle"],
            parts: [
              "task_id",
            ],
            params: [
              "requests_per_second",
            ]
          }
        ),
        "render_search_template" => RestApi.new(
          documentation: "http://www.elasticsearch.org/guide/en/elasticsearch/reference/5.x/search-template.html",
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
        "scroll" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-request-scroll.html",
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
            ]
          }
        ),
        "search" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-search.html",
          methods: ["GET", "POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/_search",
            paths: ["/_search", "/{index}/_search", "/{index}/{type}/_search"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "analyzer",
              "analyze_wildcard",
              "default_operator",
              "df",
              "explain",
              "stored_fields",
              "docvalue_fields",
              "fielddata_fields",
              "from",
              "ignore_unavailable",
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
              "_source_exclude",
              "_source_include",
              "terminate_after",
              "stats",
              "suggest_field",
              "suggest_mode",
              "suggest_size",
              "suggest_text",
              "timeout",
              "track_scores",
              "typed_keys",
              "version",
              "request_cache",
              "batched_reduce_size",
              "max_concurrent_shard_requests",
              "pre_filter_shard_size",
            ]
          }
        ),
        "search_shards" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-shards.html",
          methods: ["GET", "POST"],
          body: nil,
          url: {
            path: "/{index}/{type}/_search_shards",
            paths: ["/_search_shards", "/{index}/_search_shards", "/{index}/{type}/_search_shards"],
            parts: [
              "index",
              "type",
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
          body: {"description"=>"The search definition template and its params"},
          url: {
            path: "/_search/template",
            paths: ["/_search/template", "/{index}/_search/template", "/{index}/{type}/_search/template"],
            parts: [
              "index",
              "type",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "preference",
              "routing",
              "scroll",
              "search_type",
              "explain",
              "profile",
              "typed_keys",
            ]
          }
        ),
        "snapshot.create" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
              "verbose",
            ]
          }
        ),
        "snapshot.get_repository" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
        "snapshot.restore" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/modules-snapshots.html",
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
        "suggest" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/search-suggesters.html",
          methods: ["POST"],
          body: {"description"=>"The request definition", "required"=>true},
          url: {
            path: "/_suggest",
            paths: ["/_suggest", "/{index}/_suggest"],
            parts: [
              "index",
            ],
            params: [
              "ignore_unavailable",
              "allow_no_indices",
              "expand_wildcards",
              "preference",
              "routing",
            ]
          }
        ),
        "tasks.cancel" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html",
          methods: ["POST"],
          body: nil,
          url: {
            path: "/_tasks",
            paths: ["/_tasks/_cancel", "/_tasks/{task_id}/_cancel"],
            parts: [
              "task_id",
            ],
            params: [
              "nodes",
              "actions",
              "parent_node",
              "parent_task_id",
            ]
          }
        ),
        "tasks.get" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html",
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
            ]
          }
        ),
        "tasks.list" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/tasks.html",
          methods: ["GET"],
          body: nil,
          url: {
            path: "/_tasks",
            paths: ["/_tasks"],
            params: [
              "nodes",
              "actions",
              "detailed",
              "parent_node",
              "parent_task_id",
              "wait_for_completion",
              "group_by",
            ]
          }
        ),
        "termvectors" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-termvectors.html",
          methods: ["GET", "POST"],
          body: {"description"=>"Define parameters and or supply a document to get termvectors for. See documentation.", "required"=>false},
          url: {
            path: "/{index}/{type}/_termvectors",
            paths: ["/{index}/{type}/_termvectors", "/{index}/{type}/{id}/_termvectors"],
            parts: [
              "index",
              "type",
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
              "parent",
              "realtime",
              "version",
              "version_type",
            ]
          }
        ),
        "update" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-update.html",
          methods: ["POST"],
          body: {"description"=>"The request definition using either `script` or partial `doc`"},
          url: {
            path: "/{index}/{type}/{id}/_update",
            paths: ["/{index}/{type}/{id}/_update"],
            parts: [
              "id",
              "index",
              "type",
            ],
            params: [
              "wait_for_active_shards",
              "fields",
              "_source",
              "_source_exclude",
              "_source_include",
              "lang",
              "parent",
              "refresh",
              "retry_on_conflict",
              "routing",
              "timeout",
              "timestamp",
              "ttl",
              "version",
              "version_type",
            ]
          }
        ),
        "update_by_query" => RestApi.new(
          documentation: "https://www.elastic.co/guide/en/elasticsearch/reference/5.x/docs-update-by-query.html",
          methods: ["POST"],
          body: {"description"=>"The search definition using the Query DSL"},
          url: {
            path: "/{index}/_update_by_query",
            paths: ["/{index}/_update_by_query", "/{index}/{type}/_update_by_query"],
            parts: [
              "index",
              "type",
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
              "size",
              "sort",
              "_source",
              "_source_exclude",
              "_source_include",
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
