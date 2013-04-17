require 'json' unless defined? ::JSON

module Elastomer
  class Client

    # Provides access to bulk API command.
    #
    # body   - The bulk requst body as a String
    # params - The document type as a String
    #
    # Returns a Docs instance.
    def bulk( body = nil, params = nil )

      if block_given?

        params, body = (body || {}), nil

        yield bulk_obj = Bulk.new(self, params)
        bulk_obj.call

      else

        raise 'bulk request body cannot be nil' if body.nil?
        params ||= {}

        response = self.post '{/index}{/type}/_bulk', params.merge(:body => body)
        response.body
      end

    end

    class Bulk

      # The target size for bulk requests: 9.9MB
      REQUEST_SIZE = 10*1024*1024 - 100*1024

      #
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
      # the bulk API call is made.
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
        add_to_actions({:index => params}, document)
      end
      alias :add :index

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
        return @response if @actions.empty

        body = @actions.join("\n") + "\n"
        response = client.bulk(body, @params)
        merge_response response
      ensure
        @current_request_size = 0
        @actions.clear
      end


      # Internal: Extract special keys for bulk indexing from the given
      # `document`. The keys and their values are returned as a Hash from this
      # method.
      #
      # document - The document Hash
      #
      # Returns extracted key/value pairs as a Hash.
      def from_document( document )
        opts = {}

        %w[_id _type _index _version _version_type _routing _parent _percolator _timestamp _ttl].each do |field|
          key = field.to_sym
          opts[key] = document.delete field if document.key? field
          opts[key] = document.delete key   if document.key? key
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

    end  # Docs
  end  # Client
end  # Elastomer
