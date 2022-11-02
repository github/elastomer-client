# Elastomer Client [![CI build Workflow](https://github.com/github/elastomer-client/actions/workflows/main.yml/badge.svg)](https://github.com/github/elastomer-client/actions/workflows/main.yml)

Making a stupid simple Elasticsearch client so your project can be smarter!

## Getting Started

Get started by cloning and running a few scripts:

```
$ git clone https://github.com/github/elastomer-client.git
$ cd elastomer-client
$ script/bootstrap
$ bundle exec rake test
```

## Client

The client provides a one-to-one mapping to the Elasticsearch [API
endpoints](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html).
The API is decomposed into logical sections and accessed according to what you
are trying to accomplish. Each logical section is represented as a [client
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

The [Docs](lib/elastomer/client/docs.rb) class handles the indexing and
searching of documents. Each instance is scoped to an index and optionally a
document type.

```ruby
require 'elastomer/client'
client = Elastomer::Client.new

docs = client.docs('twitter')

docs.index({
  :_id    => 1,
  :_type  => 'tweet',
  :author => '@pea53',
  :tweet  => 'announcing Elastomer, the stupid simple Elasticsearch client'
})

docs.search({:query => {:match_all => {}}}, :size => 0)
```

#### Performance

By default Elastomer uses Net::HTTP (via Faraday) to communicate with
Elasticsearch. You may find that Excon performs better for your use. To enable
Excon, add it to your bundle and then change your Elastomer initialization
thusly:

```ruby
Elastomer::Client.new(url: YOUR_ES_URL, adapter: :excon)
```

## Releasing

1. Create a new branch from `master`
2. Bump the version number in `lib/elastomer/version.rb`
3. Update `CHANGELOG.md` with info about the new version
4. Execute `bin/rake build`. This will place a new gem file in the `pkg/` folder.
5. Run `gem install pkg/elastomer-client-{VERSION}.gem` to install the new gem locally
6. Start an `irb` session, `require "elastomer/client"` and make sure things work as you expect
7. Once everything is working as you expect, commit the version bump and open a PR
8. Once you get approval and merge it to master, pull down a fresh copy of master and then...
9. Run `rake release`
10. If necessary, manually push the new version to rubygems.org
11. 🕺 💃 🎉
