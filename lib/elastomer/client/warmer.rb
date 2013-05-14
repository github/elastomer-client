module Elastomer
  class Client

    # Provides access to warmer API commands.
    # See http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/
    #
    # index_name  - The name of the index as a String
    # warmer_name - The name of the warmer as a String
    #
    # Returns a Warmer instance.
    def warmer(index_name, warmer_name)
      Warmer.new(self, index_name, warmer_name)
    end

    class Warmer

      # Create a new Warmer helper for making warmer API requests.
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      # index_name - The name of the index as a String
      # name       - The name of the warmer as a String
      def initialize(client, index_name, name)
        raise ArgumentError, 'index name cannot be nil' if index_name.nil?

        @client = client
        @index_name = index_name
        @name = name
      end

      attr_reader :client, :index_name, :name

      # Create a warmer.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/
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
        response = client.put '/{index}{/type}/_warmer/{warmer}', defaults.update(params.update(:body => query))
        response.body
      end

      # Delete a warmer.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/
      #
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete '/{index}{/type}/_warmer/{warmer}', defaults.update(params)
        response.body
      end

      # Get a warmer.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/
      #
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get '/{index}{/type}/_warmer/{warmer}', defaults.update(params)
        response.body
      end

      # Check whether a warmer exists. Also aliased as exist?
      #
      # Since there is no native warmer exists api, this method executes
      # a get and watches for an IndexWarmerMissingException error.
      #
      # Returns true if the warmer exists, false if not.
      def exists?
        begin
          get
          true
        rescue Elastomer::Client::Error => exception
          if exception.message =~ /IndexWarmerMissingException/
            false
          else
            raise exception
          end
        end
      end
      alias :exist? :exists?

      # Internal: Returns a Hash containing default parameters.
      def defaults
        {:index => index_name, :warmer => name}
      end
    end
  end
end
