module Elastomer
  class Client

    class Percolator

      # Create a new Percolator for managing a query.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # index  - The index name
      # id     - The _id for the query
      def initialize(client, index, id)
        @client = client
        @index = index
        @id = id
      end

      attr_reader :client, :index, :id

      # Create a percolator query.
      #
      # Examples
      #
      #   percolator = $client.index("default-index").percolator "1"
      #   percolator.create :query => { :match_all => { } }
      #
      # Returns the response body as a Hash
      def create(body, params = {})
        response = client.put("/#{@index}/.percolator/#{@id}", params.merge(:body => body, :action => 'percolator.create'))
        response.body
      end

      # Gets a percolator query.
      #
      # Examples
      #
      #   percolator = $client.index("default-index").percolator "1"
      #   percolator.get
      #
      # Returns the response body as a Hash
      def get(params = {})
        response = client.get("/#{@index}/.percolator/#{@id}", params.merge(:action => 'percolator.get'))
        response.body
      end

      # Delete a percolator query.
      #
      # Examples
      #
      #   percolator = $client.index("default-index").percolator "1"
      #   percolator.delete
      #
      # Returns the response body as a Hash
      def delete(params = {})
        response = client.delete("/#{@index}/.percolator/#{@id}", params.merge(:action => 'percolator.delete'))
        response.body
      end

      # Checks for the existence of a percolator query.
      #
      # Examples
      #
      #   percolator = $client.index("default-index").percolator "1"
      #   percolator.exists?
      #
      # Returns a boolean
      def exists?(params = {})
        get(params)["found"]
      end

    end  # Percolator
  end  # Client
end  # Elastomer
