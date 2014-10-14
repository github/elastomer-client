# Notifications Support

Requiring `elastomer/notifications` enables support for broadcasting
elastomer events through ActiveSupport::Notifications.

The event namespace is `request.client.elastomer`.

## Sample event payload

```
:index  => "index-test",
:type   => nil,
:action => "docs.search",
:context=> nil,
:body   => "{\"query\":{\"match_all\":{}}}",
:url    => #<URI::HTTP:0x007fb6f3e98b60 URL:http://localhost:19200/index-test/_search?search_type=count>,
:method => :get,
:status => 200}
```

## Valid actions
- bulk
- cluster.available
- cluster.get_aliases
- cluster.get_settings
- cluster.health
- cluster.info
- cluster.pending_tasks
- cluster.reroute
- cluster.shutdown
- cluster.state
- cluster.stats
- cluster.update_aliases
- cluster.update_settings
- docs.delete
- docs.delete_by_query
- docs.explain
- docs.get
- docs.index
- docs.more_like_this
- docs.multi_get
- docs.search
- docs.source
- docs.update
- docs.validate
- index.add_alias
- index.analyze
- index.clear_cache
- index.close
- index.create
- index.delete
- index.delete_alias
- index.delete_mapping
- index.exists
- index.flush
- index.get_alias
- index.get_aliases
- index.get_settings
- index.mapping
- index.open
- index.optimize
- index.recovery
- index.refresh
- index.segments
- index.snapshot
- index.stats
- index.status
- index.update_mapping
- index.update_settings
- nodes.hot_threads
- nodes.info
- nodes.shutdown
- nodes.stats
- repository.create
- repository.delete
- repository.exists
- repository.get
- repository.status
- repository.update
- search.scan
- search.scroll
- snapshot.create
- snapshot.delete
- snapshot.exists
- snapshot.get
- snapshot.restore
- snapshot.status
- template.create
- template.delete
- template.get
