# Elastomer Client in Depth

We first started building the Elastomer Client gem when an
[official client](https://github.com/elasticsearch/elasticsearch-ruby)
was not yet available from ElasticSearch. We were looking for a client that
provided a one-to-one mapping of the ElasticSearch APIs and avoided higher level
complexity such as connection pooling, round-robin connections, thrift support,
and the like. We think these things these things are bettered handled at
different layers and by other software libraries.

Our goal is to keep our ElasticSearch client simple and then compose
higher level functionality from smaller components. This is the UNIX philosophy
in action.

To that end we have tried to be as faithful as possible to the ElasticSearch API
with our implementation. There are a few places where it made sense to wrap the
ElasticSearch API inside Ruby idioms. One notable location is the
[scan-scroll](http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/scan-scroll.html)
search type; the Elastomer Client provides a Ruby iterator to work with these
types of queries.

Below are links to documents describing the various components of the Elastomer
Client library. Start with the core components - specifically the **Client**
document. All the other components are build atop the client.

**Core Components**

* [Client](client.md)
* [Index](index.md)
* [Documents](docs.md)
* [Cluster](cluster.md)
* [Templates](templates.md)
* [Warmers](warmers.md)

**Bulk Components**

* [Bulk Indexing](bulk_indexing.md)
* [Multi-Search](multi_search.md)
* [Scan/Scroll](scan_scroll.md)

**Operational Components**

* [Snapshots](snapshots.md)
* [Notifications](notifications.md)
