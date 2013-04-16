# Elastomer

Making a stupid simple ElasticSearch client so your project can be smarter!

## Client

The client provides a one-to-one mapping to the ElasticSearch [API
endpoints](http://www.elasticsearch.org/guide/reference/api/). The API is
decomposed into logical sections and accessed according to what you are trying
to accomplish. Each logical section is represented as a [client
class](lib/elastomer/client) and a top-level accessor is provided for each.

#### Cluster

API endpoints dealing with cluster level information and settings are found in
the [Cluster](lib/elastomer/client/cluster.rb) class.

```ruby
client = Elastomer::Client.new

# the current health summary
client.cluster.health

# detailed cluster state information
client.cluster.state

# the list of all index templates
client.cluster.templates
```

