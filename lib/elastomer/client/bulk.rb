module Elastomer
  class Client

    # The `bulk` method can be used in two ways. Without a block the method
    # will perform an API call, and it requires a bulk request body and
    # optional request parameters. If given a block, the method will use a
    # Bulk instance to assemble the operations called in the block into a
    # bulk request and dispatch it at the end of the block.
    #
    # See http://www.elasticsearch.org/guide/reference/api/bulk/
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
    #   bulk( request_body, :index => 'default-index' )
    #
    #   bulk( :index => 'default-index' ) do |b|
    #     b.index( document1 )
    #     b.index( document2 )
    #     b.delete( document3 )
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
        raise 'bulk request body cannot be nil' if body.nil?
        params ||= {}

        response = self.post '{/index}{/type}/_bulk', params.merge(:body => body, :action => 'bulk')
        response.body
      end
    end


    # The Bulk class provides some abstractions and helper methods for working
    # with the ElasticSearch bulk API command. Instances of the Bulk class
    # accumulate indexing and delete operations and then issue a single bulk
    # API request to ElasticSearch. Those operations are then executed by the
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
        self.request_size = params.delete(:request_size)
        self.action_count = params.delete(:action_count)
      end

      attr_reader :client, :request_size, :action_count

      # Set the request size in bytes. If the value is nil, then request size
      # limiting will not be used and a request will only be made when the call
      # method is called. It is up to the user to ensure that the request does
      # not exceed ElasticSearch request size limits.
      #
      # If the value is a number greater than zero, then actions will be
      # buffered until the request size is met or exceeded. When this happens a
      # bulk request is issued, queued actions are cleared, and the response
      # from ElasticSearch is returned.
      def request_size=( value )
        if value.nil?
          @request_size = nil
        else
          @request_size = value.to_i <= 0 ? nil : value.to_i
        end
      end

      # Set the action count. If the value is nil, then action count limiting
      # will not be used and a request will only be made when the call method
      # is called. It is up to the user to ensure that the request does not
      # exceed ElasticSearch request size limits.
      #
      # If the value is a number greater than zero, then actions will be
      # buffered until the action count is met. When this happens a bulk
      # request is issued, queued actions are cleared, and the response from
      # ElasticSearch is returned.
      def action_count=(value)
        if value.nil?
          @action_count = nil
        else
          @action_count = value.to_i <= 0 ? nil : value.to_i
        end
      end

      # Add an index action to the list of bulk actions to be performed when
      # the bulk API call is made. The `_id` of the document cannot be `nil`
      # or empty. If this is the case then we remove the `_id` and allow
      # ElasticSearch to generate one.
      #
      # document - The document to index as a Hash or JSON encoded String
      # params   - Parameters for the index action (as a Hash)
      #
      # Returns the response from the bulk call if one was made or nil.
      def index( document, params = {} )
        params = convert_special_keys(params)
        params = params.merge from_document(document)
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?

        add_to_actions({:index => params}, document)
      end
      alias :add :index

      # Add a create action to the list of bulk actions to be performed when
      # the bulk API call is made. The `_id` of the document cannot be `nil`
      # or empty.
      #
      # document - The document to create as a Hash or JSON encoded String
      # params   - Parameters for the create action (as a Hash)
      #
      # Returns the response from the bulk call if one was made or nil.
      def create( document, params )
        params = convert_special_keys(params)
        params = params.merge from_document(document)
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?

        add_to_actions({:create => params}, document)
      end

      # Add an update action to the list of bulk actions to be performed when
      # the bulk API call is made. The `_id` of the document cannot be `nil`
      # or empty.
      #
      # document - The document to update as a Hash or JSON encoded String
      # params   - Parameters for the update action (as a Hash)
      #
      # Returns the response from the bulk call if one was made or nil.
      def update( document, params )
        params = convert_special_keys(params)
        params = params.merge from_document(document)
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?

        add_to_actions({:update => params}, document)
      end

      # Add a delete action to the list of bulk actions to be performed when
      # the bulk API call is made.
      #
      # params - Parameters for the delete action (as a Hash)
      #
      # Returns the response from the bulk call if one was made or nil.
      def delete( params )
        params = convert_special_keys(params)
        add_to_actions :delete => params
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

      # Internal: special keys.
      #
      # Returns Array<String>
      def special_keys
        %w[_id _type _index _version _version_type _routing _parent _percolator _timestamp _ttl _retry_on_conflict]
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
        return opts if String === document

        special_keys.each do |field|
          key = field.to_sym
          opts[key] = document.delete field if document[field]
          opts[key] = document.delete key   if document[key]
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

        special_keys.each do |field|
          key = field.sub(/^_/, '')

          new_params[field] = params.delete key if params.key? key
          new_params[field.to_sym] = params.delete key.to_sym if params.key? key.to_sym
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
      def add_to_actions( action, document = nil )
        action = MultiJson.dump action
        @actions << action
        @current_request_size += action.bytesize
        @current_action_count += 1

        unless document.nil?
          document = MultiJson.dump document unless String === document
          @actions << document
          @current_request_size += document.bytesize
        end

        if (request_size && @current_request_size >= request_size) ||
           (action_count && @current_action_count >= action_count)
          call
        else
          nil
        end
      end

    end  # Bulk
  end  # Client
end  # Elastomer
