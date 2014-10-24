# Elastomer Cluster Component

The cluster component deals with commands for managing cluster state and
monitoring cluster health. All the commands found under the
[Cluster API](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster.html)
section of the ElasticSearch documentation are implemented by the
[`cluster.rb`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client/cluster.rb)
module and the [`nodes.rb`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client/nodes.rb)
module.

## Cluster

API endpoints dealing with cluster level information and settings are found in
the [Cluster](lib/elastomer/client/cluster.rb) class. Each of these methods
corresponds to an API endpoint described in the ElasticSearch documentation
(linked to above). The params listed in the documentation can be passed to these
methods, so we do not take too much trouble to enumerate them all.

#### health

The cluster [health API](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-health.html)
returns a very simple cluster health status report.

```ruby
require 'elastomer/client'
client = Elastomer::Client.new :port => 19200

# the current health summary
client.cluster.health
```

You can wait for a *yellow* status.

```ruby
client.cluster.health \
  :wait_for_status => "yellow",
  :timeout         => "10s",
  :read_timeout    => 12
```

And you can request index level health details. The default timeout for the
health endpoint is 30 seconds; hence, we set our read timeout to 32 seconds.

```ruby
client.cluster.health \
  :level        => "indices",
  :read_timeout => 32
```

#### state & stats

If you need something more than basic health information, then the
[`state`](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-state.html)
and [`stats`](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-stats.html)
endpoints are the next methods to call. Please look through the API
documentation linked to above for all the details. And you can play with these
endpoints via an IRB session.

```ruby
# detailed cluster state information
client.cluster.state

# cluster wide statistics
client.cluster.stats
```

#### settings

Cluster behavior is controlled via the
[settings API](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-update-settings.html).
The settings can be retrieved, and some settings can be modified at runtime to
control shard allocations, routing, index replicas, and so forth. For example,
when performing a [rolling restart](http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/_rolling_restarts.html)
of a cluster, disabling shard allocation between restarts can reduce the
cluster recovery time.

```ruby
# disable all shard allocation
client.cluster.update_settings :transient => {
  "cluster.routing.allocation.enable" => "none"
}

# shutdown the local node
client.nodes('_local').shutdown

# restart the local node and wait for it to rejoin the cluster

# re-enable shard allocation
client.cluster.update_settings :transient => {
  "cluster.routing.allocation.enable" => "all"
}
```

#### extras

We've added a few extras to the `cluster` module purely for convenience. These
are not API mappings; they are requests we frequently make from our
applications.

```ruby
# the list of all index templates
client.cluster.templates

# list all the indices in the cluster
client.cluster.indices

# list all nodes that are currently part of the cluster
client.cluster.nodes
```

Using these methods we can quickly get the names of all the indices in the
cluster. The `indices` method above returns a hash of the index settings keyed
by the index name.

```ruby
client.cluster.indices.keys
```

The same method can be used for getting all the template names, too.

## Nodes

