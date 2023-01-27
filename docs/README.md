# Elastomer Client in Depth

We first started building the Elastomer Client gem when an
[official client](https://github.com/elasticsearch/elasticsearch-ruby)
was not yet available from Elasticsearch. We were looking for a client that
provided a one-to-one mapping of the Elasticsearch APIs and avoided higher level
complexity such as connection pooling, round-robin connections, thrift support,
and the like. We think these things are better handled at different layers and
by other software libraries.

Our goal is to keep our Elasticsearch client simple and then compose
higher level functionality from smaller components. This is the UNIX philosophy
in action.

To that end we have tried to be as faithful as possible to the Elasticsearch API
with our implementation. There are a few places where it made sense to wrap the
Elasticsearch API inside Ruby idioms. One notable location is the
[scan-scroll](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html)
search type; the Elastomer Client provides a Ruby iterator to work with these
types of queries.

Below are links to documents describing the various components of the Elastomer
Client library. Start with the core components - specifically the **Client**
document. All the other components are built atop the client.

**Core Components**

* [Client](client.md)
* [Index](index.md)
* [Documents](docs.md)
* [Cluster](cluster.md)
* [Templates](templates.md)

**Bulk Components**

* [Bulk Indexing](bulk_indexing.md)
* [Multi-Search](multi_search.md)
* [Scan/Scroll](scan_scroll.md)

**Operational Components**

* [Snapshots](snapshots.md)
* [Notifications](notifications.md)
