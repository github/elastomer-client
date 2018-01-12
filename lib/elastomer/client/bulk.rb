module Elastomer
  class Client

    # The `bulk` method can be used in two ways. Without a block the method
    # will perform an API call, and it requires a bulk request body and
    # optional request parameters. If given a block, the method will use a
    # Bulk instance to assemble the operations called in the block into a
    # bulk request and dispatch it at the end of the block.
    #
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html
    #
    # body   - Request body as a String (required if a block is _not_ given)
    # params - Optional request parameters as a Hash
    #   :request_size - Optional maximum request size in bytes
    #   :action_count - Optional maximum action size
    # block  - Passed to a Bulk instance which assembles the operations
    #          into one or more bulk requests.
    #
    # Examples
    #
    #   bulk(request_body, :index => 'default-index')
    #
    #   bulk(:index => 'default-index') do |b|
    #     b.index(document1)
    #     b.index(document2, :_type => 'default-type')
    #     b.delete(document3)
    #     ...
    #   end
    #
    # Returns the response body as a Hash
    def bulk( body = nil, params = nil )
      if block_given?
        params, body = (body || {}), nil
        yield bulk_obj = Bulk.new(self, params)
        bulk_obj.call

      else
        raise "bulk request body cannot be nil" if body.nil?
        params ||= {}

        response = self.post "{/index}{/type}/_bulk", params.merge(body: body, action: "bulk", rest_api: "bulk")
        response.body
      end
    end

    # Stream bulk actions from an Enumerator.
    #
    # Examples
    #
    #   ops = [
    #     [:index, document1, {:_type => "foo", :_id => 1}],
    #     [:create, document2],
    #     [:delete, {:_type => "bar", :_id => 42}]
    #   ]
    #   bulk_stream_responses(ops, :index => 'default-index').each do |response|
    #     puts response
    #   end
    #
    # Returns an Enumerator of responses.
    def bulk_stream_responses(ops, params = {})
      bulk_obj = Bulk.new(self, params)

      Enumerator.new do |yielder|
        ops.each do |action, *args|
          response = bulk_obj.send(action, *args)
          yielder.yield response unless response.nil?
        end

        response = bulk_obj.call
        yielder.yield response unless response.nil?
      end
    end

    # Internal: Determine whether or not a response item has an HTTP status code
    # in the range 200 to 299.
    #
    # item - The bulk response item
    #
    # Returns a boolean
    def is_ok?(item)
      item.values.first["status"].between?(200, 299)
    end

    # Stream bulk actions from an Enumerator and passes the response items to
    # the given block.
    #
    # Examples
    #
    #   ops = [
    #     [:index, document1, {:_type => "foo", :_id => 1}],
    #     [:create, document2],
    #     [:delete, {:_type => "bar", :_id => 42}]
    #   ]
    #   bulk_stream_items(ops, :index => 'default-index') do |item|
    #     puts item
    #   end
    #
    #   # return value:
    #   # {
    #   #   "took" => 256,
    #   #   "errors" => false,
    #   #   "success" => 3,
    #   #   "failure" => 0
    #   # }
    #
    #   # sample response item:
    #   # {
    #   #   "delete": {
    #   #     "_index": "foo",
    #   #     "_type": "bar",
    #   #     "_id": "42",
    #   #     "_version": 3,
    #   #     "status": 200,
    #   #     "found": true
    #   #   }
    #   # }
    #
    # Returns a Hash of stats about items from the responses.
    def bulk_stream_items(ops, params = {})
      stats = {
        "took" => 0,
        "errors" => false,
        "success" => 0,
        "failure" => 0
      }

      bulk_stream_responses(ops, params).each do |response|
        stats["took"] += response["took"]
        stats["errors"] |= response["errors"]

        response["items"].each do |item|
          if is_ok?(item)
            stats["success"] += 1
          else
            stats["failure"] += 1
          end
          yield item
        end
      end

      stats
    end

    # The Bulk class provides some abstractions and helper methods for working
    # with the Elasticsearch bulk API command. Instances of the Bulk class
    # accumulate indexing and delete operations and then issue a single bulk
    # API request to Elasticsearch. Those operations are then executed by the
    # cluster.
    #
    # A maximum request size can be set. As soon as the size of the request
    # body hits this threshold, a bulk request will be made to the search
    # cluster. This happens as operations are added.
    #
    # Additionally, a maximum action count can be set. As soon as the number
    # of actions equals the action count, a bulk request will be made.
    #
    # You can also use the `call` method explicitly to send a bulk request
    # immediately.
    #
    class Bulk
      DEFAULT_REQUEST_SIZE = 10 * 2**20  # 10 MB

      # Create a new bulk client for handling some of the details of
      # accumulating documents to index and then formatting them properly for
      # the bulk API command.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # params - Parameters Hash to pass to the Client#bulk method
      #   :request_size - the maximum request size in bytes
      #   :action_count - the maximum number of actions
      def initialize( client, params = {} )
        @client  = client
        @params  = params

        @actions = []
        @current_request_size = 0
        @current_action_count = 0
        self.request_size = params.delete(:request_size) || DEFAULT_REQUEST_SIZE
        self.action_count = params.delete(:action_count)
      end

      attr_reader :client, :request_size, :action_count

      # Set the request size in bytes. If the value is nil, then request size
      # limiting will not be used and a request will only be made when the call
      # method is called. It is up to the user to ensure that the request does
      # not exceed Elasticsearch request size limits.
      #
      # If the value is a number greater than zero, then actions will be
      # buffered until the request size is met or exceeded. When this happens a
      # bulk request is issued, queued actions are cleared, and the response
      # from Elasticsearch is returned.
      def request_size=( value )
        if value.nil?
          @request_size = nil
        else
          value = value.to_i
          value = nil if value <= 0
          value = client.max_request_size if value > client.max_request_size
          @request_size = value
        end
      end

      # Set the action count. If the value is nil, then action count limiting
      # will not be used and a request will only be made when the call method
      # is called. It is up to the user to ensure that the request does not
      # exceed Elasticsearch request size limits.
      #
      # If the value is a number greater than zero, then actions will be
      # buffered until the action count is met. When this happens a bulk
      # request is issued, queued actions are cleared, and the response from
      # Elasticsearch is returned.
      def action_count=(value)
        if value.nil?
          @action_count = nil
        else
          @action_count = value.to_i <= 0 ? nil : value.to_i
        end
      end

      # Add an index action to the list of bulk actions to be performed when
      # the bulk API call is made. Parameters can be provided in the
      # parameters hash (underscore prefix optional) or in the document
      # hash (underscore prefix required).
      #
      # document - The document to index as a Hash or JSON encoded String
      # params   - Parameters for the index action (as a Hash) (optional)
      #
      # Examples
      #   index({"foo" => "bar"}, {:_id => 1, :_type => "foo"}
      #   index({"foo" => "bar"}, {:id => 1, :type => "foo"}
      #   index("foo" => "bar", "_id" => 1, "_type" => "foo")
      #
      # Returns the response from the bulk call if one was made or nil.
      def index( document, params = {} )
        params = prepare_params(document, params)
        add_to_actions({:index => params}, document)
      end

      # Add a create action to the list of bulk actions to be performed when
      # the bulk API call is made. Parameters can be provided in the
      # parameters hash (underscore prefix optional) or in the document
      # hash (underscore prefix required).
      #
      # document - The document to create as a Hash or JSON encoded String
      # params   - Parameters for the create action (as a Hash) (optional)
      #
      # Examples
      #   create({"foo" => "bar"}, {:_id => 1}
      #   create({"foo" => "bar"}, {:id => 1}
      #   create("foo" => "bar", "_id" => 1)
      #
      # Returns the response from the bulk call if one was made or nil.
      def create( document, params )
        params = prepare_params(document, params)
        add_to_actions({:create => params}, document)
      end

      # Add an update action to the list of bulk actions to be performed when
      # the bulk API call is made. Parameters can be provided in the parameters
      # hash (underscore prefix optional) or in the document hash (underscore
      # prefix required).
      #
      # document - The document to update as a Hash or JSON encoded String
      # params   - Parameters for the update action (as a Hash) (optional)
      #
      # Examples
      #   update({"foo" => "bar"}, {:_id => 1}
      #   update({"foo" => "bar"}, {:id => 1}
      #   update("foo" => "bar", "_id" => 1)
      #
      # Returns the response from the bulk call if one was made or nil.
      def update( document, params )
        params = prepare_params(document, params)
        add_to_actions({:update => params}, document)
      end

      # Add a delete action to the list of bulk actions to be performed when
      # the bulk API call is made.
      #
      # params - Parameters for the delete action (as a Hash)
      #
      # Examples
      #   delete(:_id => 1, :_type => 'foo')
      #
      # Returns the response from the bulk call if one was made or nil.
      def delete( params )
        params = prepare_params(nil, params)
        add_to_actions({:delete => params})
      end

      # Immediately execute a bulk API call with the currently accumulated
      # actions. The accumulated actions list will be cleared after the call
      # has been made.
      #
      # If the accumulated actions list is empty then no action is taken.
      #
      # Returns the response body Hash.
      def call
        return nil if @actions.empty?

        body = @actions.join("\n") + "\n"
        client.bulk(body, @params)
      ensure
        @current_request_size = 0
        @current_action_count = 0
        @actions.clear
      end

      SPECIAL_KEYS = %w[id type index version version_type routing parent timestamp ttl consistency refresh retry_on_conflict]
      SPECIAL_KEYS_HASH = SPECIAL_KEYS.inject({}) { |h, k| h[k] = "_#{k}"; h }

      # Internal: convert special key parameters to their wire representation
      # and apply any override document parameters.
      def prepare_params(document, params)
        params = convert_special_keys(params)
        if document.is_a? Hash
          params = from_document(document).merge(params)
        end
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?
        params
      end

      # Internal: Extract special keys for bulk indexing from the given
      # `document`. The keys and their values are returned as a Hash from this
      # method. If a value is `nil` then it will be ignored.
      #
      # document - The document Hash
      #
      # Returns extracted key/value pairs as a Hash.
      def from_document( document )
        opts = {}

        SPECIAL_KEYS_HASH.values.each do |field|
          key = field.to_sym
          opts[key] = document.delete field if document.key? field
          opts[key] = document.delete key   if document.key? key
        end

        opts
      end

      # Internal: Convert incoming Ruby symbol keys to their special underscore
      # versions. Maintains API compaibility with the `Docs` API for `index`,
      # `create`, `update` and `delete`.
      #
      # :id -> :_id
      # 'id' -> '_id'
      #
      # params - Hash.
      #
      # Returns a new params Hash with the special keys replaced.
      def convert_special_keys(params)
        new_params = params.dup

        SPECIAL_KEYS_HASH.each do |k1, k2|
          new_params[k2] = new_params.delete k1 if new_params.key? k1
          new_params[k2.to_sym] = new_params.delete k1.to_sym if new_params.key? k1.to_sym
        end

        new_params
      end

      # Internal: Add the given `action` to the list of actions that will be
      # performed by this bulk request. An optional `document` can also be
      # given.
      #
      # If the total size of the accumulated actions meets our desired request
      # size, then a bulk API call will be performed. After the call the
      # actions list is cleared and we'll start accumulating actions again.
      #
      # action   - The bulk action (as a Hash) to perform
      # document - Optional document for the action as a Hash or JSON encoded String
      #
      # Returns the response from the bulk call if one was made or nil.
      # Raises RequestSizeError if the given action is larger than the
      #        configured requst size or the client.max_request_size
      def add_to_actions( action, document = nil )
        action = MultiJson.dump(action)
        size = action.bytesize

        if document
          document = MultiJson.dump(document) unless document.is_a?(String)
          size += document.bytesize
        end

        check_action_size!(size)

        response = nil
        begin
          response = call if ready_to_send?(size)
        rescue StandardError => err
          raise err
        ensure
          @actions << action
          @actions << document unless document.nil?
          @current_request_size += size
          @current_action_count += 1
        end

        response
      end

      # Internal: Determines if adding `size` more bytes and one more action
      # will bring the current bulk request over the `request_size` limit or the
      # `action_count` limit. If this method returns true, then it is time to
      # dispatch the bulk request.
      #
      # Returns `true` of `false`
      def ready_to_send?( size )
        total_request_size = @current_request_size + size
        total_action_count = @current_action_count + 1

        (request_size && total_request_size >= request_size) ||
        (action_count && total_action_count >  action_count)
      end

      # Internal: Raises a RequestSizeError if the given size is larger than
      # the configured client.max_request_size
      def check_action_size!( size )
        return unless size > client.max_request_size
        raise RequestSizeError, "Bulk action of size `#{size}` exceeds the maximum requst size: #{client.max_request_size}"
      end

    end
  end
end
