# frozen_string_literal: true

module Elastomer
  class Client

    class Percolator

      # Create a new Percolator for managing a query.
      #
      # client     - Elastomer::Client used for HTTP requests to the server
      # index_name - The index name
      # id         - The _id for the query
      def initialize(client, index_name, id)
        @client = client
        @index_name = client.assert_param_presence(index_name, "index name")
        @id = client.assert_param_presence(id, "id")

        # COMPATIBILITY
        @percolator_type = client.version_support.percolator_type
      end

      attr_reader :client, :index_name, :id

      # Create a percolator query.
      #
      # Examples
      #
      #   percolator = $client.index("default-index").percolator "1"
      #   percolator.create query: { match_all: { } }
      #
      # Returns the response body as a Hash
      def create(body, params = {})
        response = client.put("/{index}/#{@percolator_type}/{id}", defaults.merge(params.merge(body: body, action: "percolator.create")))
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
        response = client.get("/{index}/#{@percolator_type}/{id}", defaults.merge(params.merge(action: "percolator.get")))
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
        response = client.delete("/{index}/#{@percolator_type}/{id}", defaults.merge(params.merge(action: "percolator.delete")))
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

      # Internal: Returns a Hash containing default parameters.
      def defaults
        {index: index_name, id: id}
      end

    end  # Percolator
  end  # Client
end  # Elastomer
