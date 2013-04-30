require 'json' unless defined? ::JSON

module Elastomer
  class Client

    # The `bulk` method can be used in two ways. Without a block the method
    # will perform an API call, and it requires a bulk request body and
    # optional request parameters.
    #
    # body   - Request body as a String (required if a block is _not_ given)
    # params - Optional request parameters as a Hash
    # block  - A Bulk instance is passed to the block and is used to
    #          accumulate bulk operations.
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
    # A minimum request size can be set. As soon as the size of the request
    # body hits this threshold, a bulk request will be made to the search
    # cluster. This happens as operations are added.
    #
    # You can also use the `call` method explicitly to send a bulk requestion
    # immediately.
    #
    class Bulk

      # The target size for bulk requests: 9.9MB
      REQUEST_SIZE = 10*1024*1024 - 100*1024

      # Create a new bulk client for handling some of the details of
      # accumulating documents to index and then formatting them properly for
      # the bulk API command.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # params - Parameters Hash to pass to the Client#bulk method
      #   :request_size - the minimum request size in bytes
      #
      def initialize( client, params = {} )
        @client  = client
        @params  = params

        @actions = []
        @current_request_size = 0
        @request_size = params.delete(:request_size) || REQUEST_SIZE

        @response = {'took' => [], 'items' => []}
      end

      attr_reader :client, :response, :request_size

      # Add an index action to the list of bulk actions to be performed when
      # the bulk API call is made. The `_id` of the document cannot be `nil`
      # or empty. If this is the case then we remove the `_id` and allow
      # ElasticSearch to generate one.
      #
      # document - The document to index as a Hash or JSON encoded String
      # params   - Parameters for the index action (as a Hash)
      #
      # Returns this Bulk instance.
      def index( document, params = {} )
        unless String === document
          overrides = from_document(document)
          params = params.merge overrides
        end
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?

        add_to_actions({:index => params}, document)
      end
      alias :add :index

      # Add a create action to the list of bulk actions to be performed when
      # the bulk API call is made. The `_id` of the document cannot be `nil`
      # or empty.
      #
      # document - The document to create as a Hash or JSON encoded String
      # params   - Parameters for the index action (as a Hash)
      #
      # Returns this Bulk instance.
      def create( document, params )
        unless String === document
          overrides = from_document(document)
          params = params.merge overrides
        end
        params.delete(:_id) if params[:_id].nil? || params[:_id].to_s.empty?

        add_to_actions({:create => params}, document)
      end

      # Add a delete action to the list of bulk actions to be performed when
      # the bulk API call is made.
      #
      # params - Parameters for the delete action (as a Hash)
      #
      # Returns this Bulk instance.
      def delete( params )
        add_to_actions :delete => params
      end

      # Immediately execute a bulk API call with the currently accumulated
      # actions. The accumulated actions list will be cleared after the call
      # has been made.
      #
      # If the accumulated actions list is empty then no action is taken.
      #
      # Returns the merged response body Hash.
      def call
        return @response if @actions.empty?

        body = @actions.join("\n") + "\n"
        response = client.bulk(body, @params)
        merge_response response
      ensure
        @current_request_size = 0
        @actions.clear
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

        %w[_id _type _index _version _version_type _routing _parent _percolator _timestamp _ttl].each do |field|
          key = field.to_sym
          opts[key] = document.delete field if document[field]
          opts[key] = document.delete key   if document[key]
        end

        opts
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
      # Returns this Bulk instance.
      def add_to_actions( action, document = nil )
        action = ::JSON.dump action
        @actions << action
        @current_request_size += action.length

        unless document.nil?
          document = ::JSON.dump document unless String === document
          @actions << document
          @current_request_size += document.length
        end

        call if @current_request_size >= request_size

        self
      end

      # Internal: Consolidate the given `response` Hash with all the other
      # responses received from previous bulk requests.
      #
      # response - The response body (as a Hash) from the balk API call
      #
      # Returns our consolidated response Hash.
      def merge_response( response )
        @response['took'] << response['took']
        @response['items'].concat response['items']
        @response
      end

    end  # Bulk
  end  # Client
end  # Elastomer
