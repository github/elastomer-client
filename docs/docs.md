# ElastomerClient Documents Component

The documents components handles all API calls related to
[indexing documents](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html)
and [searching documents](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html).

Access to the documents component is provided via the `docs` method on the index
component or the `docs` method on the client. The `docs` method on the index
component sets the index name that will be used for all documents API calls;
that is the only difference between the two. In the example below, the resulting
documents components are equivalent.

```ruby
require 'elastomer/client'
client = ElastomerClient::Client.new :port => 9200

docs1 = client.index("blog").docs("post")
docs2 = client.docs("blog", "post")

docs1.name == docs2.name  #=> true - both have the "blog" index name
docs2.type == docs2.type  #=> true - both have the "post" document type
```

You can operate on more than one index, more than one type, one index and
multiple types, or multiple indices and a single type. Just provide the index
names and document types as an Array of Strings.

```ruby
# multiple types for a single index
client.index("blog").docs(%w[post info])
client.docs("blog", %w[post info])

# multiple indices for a single type
client.index(%w[blog user]).docs("info")
client.docs(%w[blog user], "info")

# multiple indices and types
client.docs(%w[blog user], %w[post info])

# you can omit both index and type which is useful for `multi_get`
# operations across multiple indices and types.
client.docs
```

Let's walk through some basic operations with the documents component.

#### Indexing Documents

We have created a "blog" index to hold a collection of "post" documents that we
want to search. Let's start adding posts to our index. We'll use the `index`
method on the documents component.

```ruby
docs = client.docs("blog", "post")
docs.index(
  :author => "Michael Lopp",
  :title  => "The Nerd Handbook",
  :post_date => "2007-11-11",
  :body => %q[
    A nerd needs a project because a nerd builds stuff. All the time. Those
    lulls in the conversation over dinner? That’s the nerd working on his
    project in his head ...
  ]
)
```

This will create a new document in the search index. But what do we do if there
is a misspelling in the body of our blog post? We'll need to re-index the
document.

Elasticsearch assigned our document a unique identifier when we first added it
to the index. In order to change this document, we need to supply the unique
identifier along with our modified document.

```ruby
docs = client.docs("blog", "post")
docs.index(
  :_id => "wM0OSFhDQXGZAWDf0-drSA",
  :author => "Michael Lopp",
  :title  => "The Nerd Handbook",
  :post_date => "2007-11-11",
  :body => post_body
)
```

*The `post_body` above is a variable representing the real body of the blog
post. I don't want to type it over and over again.*

You do not have to relay on the auto-generated IDs from Elasticsearch. You can
always provide your own IDs; this is recommended if your documents are also
stored in a database that provides unique IDs. Using the same IDs in both
locations enables you to reconcile documents between the two.

The `:_id` field is only one of several special fields that control document
indexing in Elasticsearch. The full list of supported fields are enumerated in
the `index`
[method documentation](https://github.com/github/elastomer-client/blob/main/lib/elastomer/client/docs.rb#L45-56).

As a parting note, you can also provide the index name and document type as part
of the document itself. These fields will be extracted from the document before
it is indexed.

```ruby
client.docs.index(
  :_index => "blog",
  :_type => "post",
  :_id => 127,
  :author => "Michael Lopp",
  :title  => "The Nerd Handbook",
  :post_date => "2007-11-11",
  :body => post_body
)
```

[Bulk indexing](bulk_indexing.md) also uses these same document attributes to
determine the index and document type to use.

There are several other operations where a document ID is required. A prime
example is deleting a document from a search index.

```ruby
client.docs.delete \
  :index => "blog",
  :type  => "post",
  :id    => 127

# you can also write
client.docs("blog", "post").delete :id => 127
```

Since we are not providing an actual document to the `delete` method, the underscore
fields are not used. The `delete` method only understands parameters that become
part of a URL passed to an HTTP DELETE call.

#### Searching

Putting documents into an index is only half the story. The other half is
searching for documents (and somewhere in there is GI Joe and red and blue
lasers). The `search` method accepts a query Hash and a set of parameters that
control the search processing (such as routing, search type, timeouts, etc).

```ruby
client.docs("blog", "post").search \
  :query => {:match_all => {}}

client.docs.search(
  {:query => {:match_all => {}}},
  :index => "blog",
  :type  => "post"
)
```

You can also pass the query via the `:q` parameter. The query will be sent as
part of the URL. The examples above send the query as the request body.

```ruby
client.docs.search \
  :q     => "*:*",
  :index => "blog",
  :type  => "post"
```

The `search` method returns the query response from Elasticsearch as a ruby
Hash. All the keys are represented as Strings. The [hashie](https://github.com/intridea/hashie)
project has some useful transforms and wrappers for working with these result
sets, but that is left to the user to implement if they so desire. ElastomerClient
client returns only ruby Hashes.

Searches can be executed against multiple indices and multiple types. Again,
just pass in an Array of index names and an Array document types.

```ruby
client.docs.search(
  {:query => {:match => {:title => "nerd"}}},
  :index   => %w[blog user],
  :type    => %w[post info]
  :timeout => "500"    # 500ms timeout
)
```

The above search assumes that all the documents have a *title* field that is
analyzed and searchable.

#### Counting

There are times when we want to know how many documents match a search but are
not necessarily interested in returning those documents. A quick and easy to get
the number of documents is to set the `:size` of the result set to zero.

```ruby
results = client.docs("blog", "post").search \
  :q    => "title:nerd",
  :size => 0

results["hits"]["total"]  #=> 1
```

The search results always contain the total number of matched documents; even if
the `:size` is set to zero or some other number.

Elasticsearch provides specific methods for obtaining the number of documents
that match a search. Using the count API endpoint is another way to get the
number of documents.

```ruby
results = client.docs("blog", "post").count \
  :q => "title:nerd"

results["count"]  #=> 1
```

#### Deleting

Documents can be deleted directly given their document ID.

```ruby
client.docs("blog", "post").delete :id => 127
```

But we can also delete all documents that match a given query. For example, we
can delete all documents that have "nerd" in their title.

```ruby
client.docs.delete_by_query \
  :q => "title:nerd",
  :index => "blog",
  :type => "post"
```

The `:type` can be omitted in order to delete any kind of document in the blog
index. Or you can specify more than one type (and more than one index) by
passing in an Array of values.

Just as with the `search` methods, the query can be passed as a parameter or as
the request body.

```ruby
client.docs.delete_by_query(
  {:query => {:match => {:title => "nerd"}}},
  :index => "blog",
  :type => "post"
)
```

Take a look through the documents component for information on all the other
supported API methods.
