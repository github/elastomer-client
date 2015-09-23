## 0.8.0 (2015-09-23)
- BREAKING: Remove `Client#warmer` method
- Add the Percolate API

## 0.7.0 (2015-09-18)
- Add streaming bulk functionality via `bulk_stream_items`
- Make Delete by Query compatible with Elasticsearch 2.0

## 0.6.0 (2015-09-11)
- Support all URL parameters when using `Client.#scroll`
- BREAKING: Moved some `Scroller` reader methods into `Scroller.opts`

## 0.5.1 (2015-04-03)
- Add response body to notification payload

## 0.5.0 (2015-01-21)
- BREAKING: rename action.available notification to action.ping
- Index Component
  - client.index no longer requires a name
- Documents Component
  - client.docs no longer requires an index name
  - added an `exists?` method
  - added `termvector` and `multi_termvectors` methods
  - added a `search_shards` method
  - added an `mget` alias for `multi_get`
- Adding more documentation
- Rename client.available? to client.ping (aliased as available?)
- Updating tests to pass with ES 1.4.X
- Enabling regular scroll queries vi `Client#scroll`

## 0.4.1 (2014-10-14)
- Support for index `_recovery` endpoint
- Fix Faraday 0.8 support
- Wrap all Faraday exceptions
- Correctly wrap single-command reroute with a command array

## 0.4.0 (2014-10-08)
- BREAKING: docs.add alias for docs.index removed
- BREAKING: Faraday exceptions are now raised as Elastomer exceptions
- Repository and snapshot support
- Support cluster state filtering on 1.x
- Support node stats filtering on 1.x
- New apis: cluster stats, cluster pending\_tasks
- Support single-index alias get, add, delete

## 0.3.3 (2014-08-18)
- Allow symbols as parameter values #67

## 0.3.2 (2014-07-02)
- Make underscore optional in bulk params #66

## 0.3.1 (2014-06-24)
- First rubygems release
- Make `update_aliases` more flexible
- Add `Client#semantic_version` for ES version comparisons
