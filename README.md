# ElastomerClient [![CI build Workflow](https://github.com/github/elastomer-client/actions/workflows/main.yml/badge.svg)](https://github.com/github/elastomer-client/actions/workflows/main.yml)

Making a stupid simple Elasticsearch client so your project can be smarter!

## Client

The client provides a one-to-one mapping to the Elasticsearch [API
endpoints](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html).
The API is decomposed into logical sections and accessed according to what you
are trying to accomplish. Each logical section is represented as a [client
class](lib/elastomer_client/client) and a top-level accessor is provided for each.

#### Cluster

API endpoints dealing with cluster level information and settings are found in
the [Cluster](lib/elastomer_client/client/cluster.rb) class.

```ruby
require 'elastomer_client/client'
client = ElastomerClient::Client.new

# the current health summary
client.cluster.health

# detailed cluster state information
client.cluster.state

# the list of all index templates
client.cluster.templates
```

#### Index

The methods in the [Index](lib/elastomer_client/client/index.rb) class deal with the
management of indexes in the cluster. This includes setting up type mappings
and adjusting settings. The actual indexing and search of documents are
handled by the Docs class (discussed next).

```ruby
require 'elastomer_client/client'
client = ElastomerClient::Client.new

index = client.index('books')
index.create(
  :settings => { 'index.number_of_shards' => 3 },
  :mappings => {
    :_source => { :enabled => true },
    :properties => {
      :author => { :type => 'keyword' },
      :title  => { :type => 'text' }
    }
  }
)

index.exists?

index.delete
```

#### Docs

The [Docs](lib/elastomer_client/client/docs.rb) class handles the indexing and
searching of documents. Each instance is scoped to an index and optionally a
document type.

```ruby
require 'elastomer_client/client'
client = ElastomerClient::Client.new

docs = client.docs('books')

docs.index({
  :_id    => 1,
  :author => 'Mark Twain',
  :title  => 'The Adventures of Huckleberry Finn'
})

docs.search({:query => {:match_all => {}}})
```

#### Performance

By default ElastomerClient uses Net::HTTP (via Faraday) to communicate with
Elasticsearch. You may find that Excon performs better for your use. To enable
Excon, add it to your bundle and then change your ElastomerClient initialization
thusly:

```ruby
ElastomerClient::Client.new(url: YOUR_ES_URL, adapter: :excon)
```

## Development

Get started by cloning and running a few scripts:

1. Bootstrap the project
    - `script/bootstrap`
2. Run ES in Docker (see below)
3. Run tests
    - for ES 8: `ES_PORT=9208 rake test`
    - for ES 7: `ES_PORT=9207 rake test`
    - for ES 5: `ES_PORT=9205 rake test`


Run ES 5, ES 7, and ES 8:
```
cd docker
docker compose --profile all up
```

Run only ES 8:
```
cd docker
docker compose --profile es8 up
```

Run only ES 7:
```
cd docker
docker compose --profile es7 up
```

Run only ES 5:
```
cd docker
docker compose --profile es5 up
```


## Releasing

1. Create a new branch from `main`
2. Bump the version number in `lib/elastomer_client/version.rb`
3. Update `CHANGELOG.md` with info about the new version
4. Execute `bin/rake build`. This will place a new gem file in the `pkg/` folder.
5. Run `gem install pkg/elastomer-client-{VERSION}.gem` to install the new gem locally
6. Start an `irb` session, `require "elastomer_client/client"` and make sure things work as you expect
7. Once everything is working as you expect, commit the version bump and open a PR
8. Once you get approval and merge it to master, pull down a fresh copy of master and then...
9. Run `rake release`
10. If necessary, manually push the new version to rubygems.org
11. 🕺 💃 🎉
