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
- cluster.get_settings
- cluster.health
- cluster.reroute
- cluster.state
- cluster.update_settings
- cluster.available
- cluster.get_aliases
- cluster.info
- cluster.shutdown
- cluster.update_aliases
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
- index.analyze
- index.clear_cache
- index.close
- index.create
- index.delete
- index.delete_mapping
- index.exists
- index.flush
- index.get_aliases
- index.get_settings
- index.mapping
- index.open
- index.optimize
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
- search.scan
- search.scroll
- template.create
- template.get
