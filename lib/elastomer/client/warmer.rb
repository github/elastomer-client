module Elastomer
  class Client

    # DEPRECATED: Warmers have been removed from Elasticsearch as of 5.0.
    # See https://www.elastic.co/guide/en/elasticsearch/reference/5.0/indices-warmers.html
    class Warmer

      # Create a new Warmer helper for making warmer API requests.
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      # index_name - The name of the index as a String
      # name       - The name of the warmer as a String
      def initialize(client, index_name, name)
        @client     = client
        @index_name = @client.assert_param_presence(index_name, "index name")
        @name       = @client.assert_param_presence(name, "warmer name")
      end

      attr_reader :client, :index_name, :name

      # Create a warmer.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-warmers.html
      #
      # query  - The query the warmer should run
      # params - Parameters Hash
      #
      # Examples
      #
      #   warmer.create(:query => {:match_all => {}})
      #
      # Returns the response body as a Hash
      def create(query, params = {})
        response = client.put "/{index}{/type}/_warmer/{warmer}", defaults.update(params.update(:body => query))
        response.body
      end

      # Delete a warmer.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-warmers.html#removing
      #
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete "/{index}{/type}/_warmer/{warmer}", defaults.update(params)
        response.body
      end

      # Get a warmer.
      # See https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-warmers.html#warmer-retrieving
      #
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get "/{index}{/type}/_warmer/{warmer}", defaults.update(params)
        response.body
      end

      # Check whether a warmer exists. Also aliased as exist?
      #
      # Since there is no native warmer exists api, this method executes
      # a get and watches for an IndexWarmerMissingException error.
      #
      # Returns true if the warmer exists, false if not.
      #COMPATIBILITY warmer response differs in ES 1.0
      # ES 1.0: missing warmer returns {} with 200 status
      # ES 0.90: missing warmer returns IndexWarmerMissingException error
      # See https://github.com/elasticsearch/elasticsearch/issues/5155
      def exists?
        response = get

        response != {}
      rescue Elastomer::Client::Error => exception
        if exception.message =~ /IndexWarmerMissingException/
          false
        else
          raise exception
        end
      end
      alias_method :exist?, :exists?

      # Internal: Returns a Hash containing default parameters.
      def defaults
        {:index => index_name, :warmer => name}
      end
    end
  end
end
