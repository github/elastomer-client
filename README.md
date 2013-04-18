# Elastomer

Making a stupid simple ElasticSearch client so your project can be smarter!

## Getting Started

Use [Boxen](https://setup.githubapp.com) to get your machine set up. Then:

```
$ git clone https://github.com/github/elastomer.git
$ cd elastomer
$ script/bootstrap
$ script/testsuite
```

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
require 'elastomer/client'
client = Elastomer::Client.new

# the current health summary
client.cluster.health

# detailed cluster state information
client.cluster.state

# the list of all index templates
client.cluster.templates
```

#### Index

The methods in the [Index](lib/elastomer/client/index.rb) class deal with the
management of indexes in the cluster. This includes setting up type mappings
and adjusting settings. The actual indexing and search of documents are
handled by the Docs class (discussed next).

```ruby
require 'elastomer/client'
client = Elastomer::Client.new

index = client.index('twitter')
index.create(
  :settings => { 'index.number_of_shards' => 3 },
  :mappings => {
    :tweet => {
      :_source => { :enabled => true },
      :_all    => { :enabled => false },
      :properties => {
        :author => { :type => 'string', :index => 'not_analyzed' },
        :tweet  => { :type => 'string', :analyze => 'standard' }
      }
    }
  }
)

index.exists?

index.exists? :type => 'tweet'

index.delete
```

#### Docs

This decomposition is the most questionable, but it's a starting point. The
[Docs](lib/elastomer/client/docs.rb) class handles the indexing and searching
of documents. Each instance is scoped to an index and optionally a document
type.

```ruby
require 'elastomer/client'
client = Elastomer::Client.new

docs = client.docs('twitter')

docs.index({
  :_id    => 1,
  :_type  => 'tweet',
  :author => '@pea53',
  :tweet  => 'announcing Elastomer, the stupid simple ElasticSearch client'
})

docs.search({:query => {:match_all => {}}}, :search_type => 'count')
```

