# Elastomer Documents Component

The documents components handles all API calls related to
[indexing documents](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs.html)
and [searching documents](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html).

Access to the documents component is provided via the `docs` method on the index
component or the `docs` method on the client. The `docs` method on the index
component sets the index name that will be used for all documents API calls;
that is the only difference between the two. In the example below, the resulting
documents components are equivalent.

```ruby
require 'elastomer/client'
client = Elastomer::Client.new :port => 19200

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

ElasticSearch assigned our document a unique identifier when we first added it
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

You do not have to relay on the auto-generated IDs from ElasticSearch. You can
always provide your own IDs; this is recommended if your documents are also
stored in a database that provides unique IDs. Using the same IDs in both
locations enables you to reconcile documents between the two.

The `:_id` field is only one of several special fields that control document
indexing in ElasticSearch. The full list of supported fields are enumerated in
the `index`
[method documentation](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client/docs.rb#L45-56).

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

Since we are not providing an actual document to this method, the underscore
fields are not used. These are just parameters being passed to an HTTP DELETE
call.

#### Searching




