# ElastomerClient Index Component

The index component provides access to the
[indices API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html)
used for index management, settings, mappings, and aliases. Index
[templates](templates.md) are handled via their own
components. Methods for adding documents to the index and searching those
documents are found in the [documents](documents.md) component. The index
component deals solely with management of the indices themselves.

Access to the index component is provided via the `index` method on the client.
If you provide an index name then it will be used for all the API calls.
However, you can omit the index name and pass it along with each API method
called.

```ruby
require 'elastomer/client'
client = ElastomerClient::Client.new :port => 9200

# you can provide an index name
index = client.index "blog"
index.status

# or you can omit the index name and provide it with each API method call
index = client.index
index.status :index => "blog"
index.status :index => "users"
```

You can operate on more than one index, too, by providing a list of index names.
This is useful for maintenance operations on more than one index.

```ruby
client.index(%w[blog users]).status
client.index.status :index => %w[blog users]
```

Some operations do not make sense against multiple indices - index existence is a
good example of this. If three indices are given it only takes one non-existent
index for the response to be false.

```ruby
client.index("blog").exists?             #=> true
client.index(%w[blog user]).exists?      #=> true
client.index(%w[blog user foo]).exists?  #=> false
```

Let's take a look at some basic index operations. We'll be working with an
imaginary "blog" index that contains standard blog post information.

#### Create an Index

Here we create a "blog" index that contains "post" documents. We pass the
`:settings` for the index and the document type `:mappings` to the `create`
method.

```ruby
index = client.index "blog"
index.create \
  :settings => {
    :number_of_shards   => 5,
    :number_of_replicas => 1
  },
  :mappings => {
    :post => {
      :_all => { :enabled => false },
      :_source => { :compress => true },
      :properties => {
        :author => { :type => "string", :index => "not_analyzed" },
        :title  => { :type => "string" },
        :body   => { :type => "string" }
      }
    }
  }
```

Our "blog" index is created with 5 shards and a replication factor of 1. This
gives us a total of 10 shards (5 primaries and 5 replicas). The "post" documents
have an author, title, and body.

#### Update Mappings

It would be really nice to know when a blog post was created. We can use this in
our search to limit results to recent blog posts. So let's add this information
to our post document type.

```ruby
index = client.index "blog"
index.update_mapping :post,
  :post => {
    :properties => {
      :post_date => { :type => "date", :format => "dateOptionalTime" }
    }
  }
```

The `:post` type is given twice - once as a method argument, and once in the
request body. This is an artifact of the Elasticsearch API. We could hide this
wart, but the philosophy of the elastomer-client is to be as faithful to the API
as possible.

#### Analysis

The [analysis](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html)
process has the greatest impact on the relevancy of your search results. It is
the process of decomposing text into searchable tokens. Understanding this
process is important, and creating your own analyzers is as much an art form as
it is science.

Elasticsearch provides an [analyze](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html)
API for exploring the analysis process and return tokens. We can see how
individual fields will analyze text.

```ruby
index = client.index "blog"
index.analyze "The Role of Morphology in Phoneme Prediction",
  :field => "post.title"
```

And we can explore the default analyzers provided by Elasticsearch.

```ruby
client.index.analyze "The Role of Morphology in Phoneme Prediction",
  :analyzer => "snowball"
```

#### Index Maintenance

A common practice when dealing with non-changing data sets (event logs) is to
create a new index for each week or month. Only the current index is written to,
and the older indices can be made read-only. Eventually, when it is time to
expire the data, the older indices can be deleted from the cluster.

Let's take a look at some simple event log maintenance using elastomer-client.

```ruby
# the previous month's event log
index = client.index "event-log-2014-09"

# force merge the index to have only 1 segment file (expunges deleted documents)
index.force merge \
  :max_num_segments => 1,
  :wait_for_merge   => true

# block write operations to this index
# and disable the bloom filter which is only used for indexing
index.update_settings \
  :index => {
    "blocks.write"     => true,
    "codec.bloom.load" => false
  }
```

Now we have a nicely optimized event log index that can be searched but cannot
be written to. Sometime in the future we can delete this index (but we should
take a [snapshot](snapshots.md) first).

```ruby
client.index("event-log-2014-09").delete
```
