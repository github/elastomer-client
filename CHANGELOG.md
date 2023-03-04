## 4.0.1 (2023-02-10)
- Fix a bug in the bulk API interface that prevents a version check from working correctly

## 4.0.0 (2023-02-10)
- Add ES 7 and ES 8 compatibility for existing functionality
- Remove ES 2 support
- Add support for newer Ruby versions (3.0, 3.1, 3.2)
- Remove support for older Ruby versions (< 3.0)

## 3.2.3 (2020-02-26)
- Fix warnings in Ruby 2.7 whan passing a Hash to a method that is expecting keyword arguments

## 3.2.2 (2020-02-25)
- Update Webmock to ~> 3.5 to support Ruby 2.6+ (#222)

## 3.2.1 (2019-08-27)
- Ignore basic_auth unless username and password are present

## 3.2.0 (2019-08-22)
- Add config based basic and token auth to `Elastomer::Client#connection`
- Filter `Elastomer::Client#inspect` output to hide basic and token auth info,
  and reduce noisiness when debugging

## 3.1.5 (2019-06-26)
- Add new more granular exception type

## 3.1.1 (2018-02-24)
- Output opaque ID information when a conflict is detected
- Updating the `semantic` gem

## 3.1.0 (2018-01-19)
- Added the `strict_params` flag for enforcing params passed to the REST API
- Added the `RestApiSpec` module and classes for enforcing strict params

## 3.0.1 (2017-12-20)
- Fixed argument passing to `app_delete_by_query`
- Explicitly close scroll search contexts when scroll is complete

## 3.0.0 (2017-12-15)
- Fixed swapped args in {Client,Index}#multi\_percolate count calls using block API
- Support for Elasticsearch 5.x
- Uses Elasticsearch's built-in `_delete_by_query` when supported
- GET and HEAD requests are retried when possible
- Add support for `_tasks` API
- Replace `scan` queries with `scroll` sorted by `doc_id`

## 2.3.0 (2017-11-29)
- Remove Elasticsearch 1.x and earlier code paths
- Fix CI and configure an Elasticsearch 5.6 build

## 2.2.0 (2017-04-29)
- Added a `clear_scroll` API
- JSON timestamps include milliseconds by default
- Removing Fixnum usage

## 2.1.1 (2016-09-02)
- Bulk index only rejects documents larger than the maximum request size

## 2.1.0 (2016-01-02)
- Added enforcement of maximum request size
- Added some exception wrapping

## 2.0.1 (2016-09-01)
- Fix bug in delete by query when routing is required

## 2.0.0 (2016-08-25)
- Support Elasticsearch 2

## 0.9.0 (2016-02-26)
- Adding support for the `/_suggest` API endpoint
- Documentation cleanup - thank you Matt Wagner @wags

## 0.8.1 (2015-11-04)
- Replace yanked 0.8.0
- Fix code style based on Rubocop recommendations

## 0.8.0 (2015-09-23) yanked due to invalid build
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
