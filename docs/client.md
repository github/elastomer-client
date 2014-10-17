# Elastomer Client Component

All methods in the Elastomer Client gem eventually make an HTTP request to
ElasticSearch. The [`Elastomer::Client`](https://github.com/github/elastomer-client/blob/master/lib/elastomer/client.rb)
class is responsible for connecting to an ElasticSearch instance, making HTTP
requests, processing the response, and handling errors. Let's look at the
details of how `Elastomer::Client` handles HTTP communication.

### Connecting

We use the [Faraday](https://github.com/lostisland/faraday) gem for all HTTP
communication. Faraday provides a uniform wrapper around several different HTTP
clients allowing any of these clients to be used at runtime. Faraday also has
the concept of *middlewares* that operate on the HTTP request and response. We
use Faraday middleware to encode and decode JSON messages exchanged with
ElasticSearch.

Without any options the `Elastomer::Client` will connect to the default
ElasticSearch URL `http://localhost:9200`. The `Net:HTTP` client from the Ruby
standard library will be used.

```ruby
client = Elastomer::Client.new
client.host  #=> 'localhost'
client.port  #=> 9200
client.url   #=> 'http://localhost:9200'
```

[Boxen](https://boxen.github.com) configures ElasticSearch to listen on port
`19200` instead of the standard port. We can provide either the full URL or just
a different port number if ElasticSearch is running on `localhost`.

```ruby
client = Elastomer::Client.new :port => 19200
client.host  #=> 'localhost'
client.port  #=> 19200
client.url   #=> 'http://localhost:19200'

client = Elastomer::Client.new :url => "http://localhost:19200"
```

ElasticSearch works best with persistent connections. We can use the
`Net::HTTP::Persistent` adapater with Faraday.

```ruby
client = Elastomer::Client.new \
  :port    => 19200,
  :adapter => :net_http_persistent
```

We also want to configure the `:open_timeout` (for making the initial connection
to ElasticSearch) and the `:read_timeout` (used to limit each request). The open
timeout should be short - it defaaults to 2 seconds. The read timeout should be
longer, but it can vary depending upon the type of request you are making. Large
bulk requests will take longer than a quick count query.

The open timeout is configured once when the client is first created. The read
timeout can be set for each request.

```ruby
client = Elastomer::Client.new \
  :url          => "http:/localhost:19200",
  :adapter      => :net_http_persistent
  :open_timeout => 1,
  :read_timeout => 5

client.get("/", :read_timeout => 1)
```

Because each library handles read timeouts differently, some caution must be
used. Persistent connections might or might not be closed and reopened when the
read timeout is reached. If the connection is left open and reused, then the
returned data might actually be from a previous request. This can lead to all
kinds of horrible data leaks.

ElasticSearch provides an `X-Opaque-Id` request header. Any value set in this
request header will be returned in the corresponding response header. This
allows the client to correlate the response from ElasticSearch with the request
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

### URL Handling

### Parameter Handling

### Errors
