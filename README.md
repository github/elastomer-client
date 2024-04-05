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

#### Retries

You can add retry logic to your Elastomer client connection using Faraday's Retry middleware. The `ElastomerClient::Client.new` method can accept a block, which you can use to customize the Faraday connection. Here's an example:

```ruby
retry_options = {
  max: 2,
  interval: 0.05,
  methods: [:get]
}

ElastomerClient::Client.new do |connection|
  connection.request :retry, retry_options
end
```

## Compatibility

This client is tested against:

- Ruby version 3.2
- Elasticsearch versions 5.6 and 8.13

## Development

Get started by cloning and running a few scripts:

- [ElastomerClient ](#elastomerclient-)
  - [Client](#client)
      - [Cluster](#cluster)
      - [Index](#index)
      - [Docs](#docs)
      - [Performance](#performance)
  - [Compatibility](#compatibility)
  - [Development](#development)
    - [Bootstrap the project](#bootstrap-the-project)
    - [Start an Elasticsearch server in Docker](#start-an-elasticsearch-server-in-docker)
    - [Run tests against a version of Elasticsearch](#run-tests-against-a-version-of-elasticsearch)
  - [Releasing](#releasing)

### Bootstrap the project

```
script/bootstrap
```

### Start an Elasticsearch server in Docker

To run ES 5 and ES 8:
```
docker compose --project-directory docker --profile all up
```

To run only ES 8:
```
docker compose --project-directory docker --profile es8 up
```

To run only ES 5:
```
docker compose --project-directory docker --profile es5 up
```

### Run tests against a version of Elasticsearch

ES 8
```
ES_PORT=9208 rake test
```

ES 5
```
ES_PORT=9205 rake test
```

## Releasing

1. Create a new branch from `main`
1. Bump the version number in `lib/elastomer/version.rb`
1. Update `CHANGELOG.md` with info about the new version
1. Commit your changes and tag the commit with a version number starting with the prefix "v" e.g. `v4.0.2`
1. Execute `rake build`. This will place a new gem file in the `pkg/` folder.
1. Run `gem install pkg/elastomer-client-{VERSION}.gem` to install the new gem locally
1. Start an `irb` session, `require "elastomer/client"` and make sure things work as you expect
1. Once everything is working as you expect, push both your commit and your tag, and open a pull request
1. Request review from a maintainer and wait for the pull request to be approved. Once it is approved, you can merge it to `main` yourself. After that, pull down a fresh copy of `main` and then...
1. [Optional] If you intend to release a new version to Rubygems, run `rake release`
1. [Optional] If necessary, manually push the new version to rubygems.org
1. 🕺 💃 🎉
