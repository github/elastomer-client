# Elastomer Client Component

All methods in the Elastomer Client gem eventually make an HTTP request to
Elasticsearch. The [`Elastomer::Client`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client.rb)
class is responsible for connecting to an Elasticsearch instance, making HTTP
requests, processing the response, and handling errors. Let's look at the
details of how `Elastomer::Client` handles HTTP communication.

### Connecting

We use the [Faraday](https://github.com/lostisland/faraday) gem for all HTTP
communication. Faraday provides a uniform wrapper around several different HTTP
clients allowing any of these clients to be used at runtime. Faraday also has
the concept of *middlewares* that operate on the HTTP request and response. We
use Faraday middleware to encode and decode JSON messages exchanged with
Elasticsearch.

Without any options the `Elastomer::Client` will connect to the default
Elasticsearch URL `http://localhost:9200`. The `Net:HTTP` client from the Ruby
standard library will be used.

```ruby
client = Elastomer::Client.new
client.host  #=> 'localhost'
client.port  #=> 9200
client.url   #=> 'http://localhost:9200'
```

[Boxen](https://boxen.github.com) configures Elasticsearch to listen on port
`19200` instead of the standard port. We can provide either the full URL or just
a different port number if Elasticsearch is running on `localhost`.

```ruby
client = Elastomer::Client.new :port => 19200
client.host  #=> 'localhost'
client.port  #=> 19200
client.url   #=> 'http://localhost:19200'

client = Elastomer::Client.new :url => "http://localhost:19200"
```

Elasticsearch works best with persistent connections. We can use the
`Net::HTTP::Persistent` adapter with Faraday.

```ruby
client = Elastomer::Client.new \
  :port    => 19200,
  :adapter => :net_http_persistent
```

We also want to configure the `:open_timeout` (for making the initial connection
to Elasticsearch) and the `:read_timeout` (used to limit each request). The open
timeout should be short - it defaults to 2 seconds. The read timeout should be
longer, but it can vary depending upon the type of request you are making. Large
bulk requests will take longer than a quick count query.

The open timeout is configured once when the client is first created. The read
timeout can be set for each request.

```ruby
client = Elastomer::Client.new \
  :url          => "http://localhost:19200",
  :adapter      => :net_http_persistent,
  :open_timeout => 1,
  :read_timeout => 5

client.get("/", :read_timeout => 1)
```

Because each library handles read timeouts differently, some caution must be
used. Persistent connections might or might not be closed and reopened when the
read timeout is reached. If the connection is left open and reused, then the
returned data might actually be from a previous request. This can lead to all
kinds of horrible data leaks.

Elasticsearch provides an `X-Opaque-Id` request header. Any value set in this
request header will be returned in the corresponding response header. This
allows the client to correlate the response from Elasticsearch with the request
that was submitted. We have written an
[OpaqueId](https://github.com/github/elastomer-client/blob/master/lib/elastomer/middleware/opaque_id.rb)
middleware that will abort any request if the `X-Opaque-Id` headers disagree
between the request and the response. You can use this feature by setting
the `:opaque_id` flag.

```ruby
client = Elastomer::Client.new \
  :url       => "http://localhost:19200",
  :adapter   => :net_http_persistent,
  :opaque_id => true
```

If you are not using persistent connections, then you do not need to worry about
`X-Opaque-Id` headers.

### HTTP Methods

The standard HTTP verbs - `head`, `get`, `put`, `post`, `delete` - are exposed
as methods on the `Elastomer::Client` class. Each method accepts a path and a
Hash of parameters. Some parameters are applied as path expansions, some are
reserved, and the remainder are used as URL parameters. We'll look at the
reserved parameters first.

#### Reserved Parameters

**:body**

The value passed in as the `:body` parameter will be used as the body of the
HTTP request. The HTTP `head` method does not support a request body and ignores
this parameter. The other HTTP methods all support request bodies.

The `:body` value will be converted into JSON format before being sent to
Elasticsearch unless the body is a String or an Array. If the body is a String
it is assumed to already be JSON formatted, and it is sent to Elasticsearch as
is without any modifications. When the body is an Array then all the items are
joined with a newline character `\n` and a trailing newline is appended; this
supports [bulk](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
indexing and [multi-search](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html)
requests.

**:read_timeout**

The read timeout for the HTTP network calls can be changed on a per-call basis.
If a `:read_timeout` is supplied then it will be used instead of the global read
timeout configured during initialization. This is useful for large bulk
operations that might take longer than normal.

```ruby
client.cluster.health \
  :index           => "test-index-1",
  :wait_for_status => "green",
  :timeout         => "5s",
  :read_timeout    => 7
```

In the example above we are waiting for the named index to reach a green state.
The `:timeout` of 5 seconds is passed to Elasticsearch. This call will return
after 5 seconds even if the index has not yet reached green status. So we set
our network call timeout to 7 seconds to ensure we don't kill the request before
Elasticsearch has responded.

**:action** and **:context**

Each method in the Elastomer client gem has its own `:action` value that is
used in conjunction with the [notifications](notifications.md) layer. The
`:action` parameter cannot be changed by the user. Instead you can provide a
`:context` value to each method call. This will be passed unchanged to the
notifications layer, and it is useful for tracking where an Elastomer client
method is called from within your application.

#### URL Handling

URLs are generated by combining a URL template with values extracted from the
parameters. The [Addressable](https://github.com/sporkmonger/addressable) gem is
used for this URL template expansion.

With the [`Addressable::Template`](https://github.com/sporkmonger/addressable#uri-templates)
a typical search URL takes the form `{/index}{/type}/_search`. The `:index` and
`:type` values are taken from the parameters Hash and combined with the template
to generate the URL. The internal
[`expand_path`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client.rb#L245)
method handles the URL generation.

Here are a few examples to better illustrate the concept.

```ruby
client.expand_path("{/index}{/type}/_search", {
  :q => "*:*"
})
#=> "/_search?q=*:*"

client.expand_path("{/index}{/type}/_search", {
  :index => "twitter",
  :q     => "*:*"
})
#=> "/twitter/_search?q=*:*"

client.expand_path("{/index}{/type}/_search", {
  :index => "twitter",
  :type  => "tweet",
  :q     => "*:*"
})
#=> "/twitter/tweet/_search?q=*:*"

client.expand_path("{/index}{/type}/_search", {
  :index       => "twitter",
  :type        => ["tweet", "user"],
  :q           => "*:*"
  :search_type => "count"
})
#=> "/twitter/tweet,user/_search?q=*:*&search_type=count"
```

In the examples above the path elements are optional. We can force them to be
required and non-empty using a slightly different template syntax. In the
example below we are requiring the `:index` and `:type` parameters to be
provided. If either of them are missing (or nil or an empty string) then an
`ArgumentError` is raised.

```ruby
client.expand_path("/{index}/{type}/_search", {
  :index => "twitter",
  :q     => "*:*"
})
#=> raises an ArgumentError - :type is missing

client.expand_path("/{index}/{type}/_search", {
  :index => "twitter",
  :type  => " ",
  :q     => "*:*"
})
#=> raises an ArgumentError - :type is an empty string
```

And that is the basic concept of the `expand_path` method. The URL template
pattern is used extensively in the Elastomer client code, so it is definitely
worth knowing about.

### Errors

Invariably things will go wrong where computers and networks are involved. The
Elastomer client code makes no attempt to retry an operation in the face of an
error. However, it does classify errors into *fatal* and *retryable* exceptions.

Each class that inherits from
[`Elastomer::Client::Error`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client/errors.rb)
has a `fatal?` method (and the inverse `retry?` method). If an exception is
fatal, then the request is fundamentally flawed and should not be retried.
Passing a malformed search query or trying to search an index that does not
exist are both examples of fatal errors - the request will never succeed.

If an error is not fatal then it can be retried. If the Elasticsearch cluster
has a full search queue then any query will fail. It not the fault of the user
or the query itself - Elasticsearch just needs more capacity. The query can be
safely retried.

Therein lies the rub, though. Retrying a search or any operation will continue
to add load to a search cluster that might already be experiencing problems.
Blindly retrying an operation might do more harm than good. It is left to the
user to implement their own exponential back-off scheme or to implement some
status / back-pressure system.

### Automatically refreshing indices

The annoyance of having to repeatedly inserting a call to `index.refresh` between writes/reads (especially in tests) can be alleviated by setting `auto_refresh => true` in the client settings:

```ruby
client = Elastomer::Client.new :auto_refresh => true
```

When `auto_refresh => true`, `index.refresh` will be called before all read operations.
