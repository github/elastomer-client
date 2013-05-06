
module Elastomer

  # Parent class for all Elastomer errors.
  Error = Class.new StandardError

  class Client

    # General error response from client requests.
    #
    class Error < ::Elastomer::Error

      # Construct a new Error from the given response object or a message
      # String. If a response object is given, the error message will be
      # extracted from the response body.
      #
      # args - A two element array containing an error message String followed
      #        by an optional Faraday::Response object
      #
      # Examples
      #
      #   raise Elastomer::Client::Error, [message, response]
      #
      def initialize( args )
        if Array === args
          message, @response = args
        else
          message = args
        end

        super message
      end

      attr_reader :response

      # Returns the status code from the `response` or nil if the Error was not
      # created with a response.
      def status
        response ? response.status : nil
      end
    end  # Error

  end  # Client
end  # Elastomer
