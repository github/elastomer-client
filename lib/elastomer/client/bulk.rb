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

        @response = {'took' => 0, 'items' => []}
      end

      attr_reader :client, :response, :request_size

      #
      #
      def index( document, params = {} )
        overrides = from_document(document)
        add_to_actions({:index => params.merge(overrides)}, document)
      end
      alias :add :index

      #
      #
      def delete( params )
        add_to_actions :delete => params
      end

      #
      #
      def call
        body = @actions.join("\n") + "\n"

        response = client.bulk(body, @params)
        merge_response response
      ensure
        @actions.clear
        @current_request_size = 0
      end


      # Internal:
      #
      def from_document( document )
        opts = {}

        %w[_id _type _index _version _version_type _routing _parent _percolator _timestamp _ttl].each do |field|
          key = field.to_sym
          opts[key] = document.delete field if document.key? field
          opts[key] = document.delete key   if document.key? key
        end

        opts
      end

      # Internal:
      #
      def add_to_actions( action, document = nil )
        action = ::JSON.dump action
        @actions << action
        @current_request_size += action.length

        unless document.nil?
          document = ::JSON.dump document
          @actions << document
          @current_request_size += document.length
        end

        call if @current_request_size >= request_size

        self
      end

      #
      #
      def merge_response( response )
        @response['took'] += response['took']
        @response['items'].concat response['items']
        @response
      end

    end  # Docs
  end  # Client
end  # Elastomer
