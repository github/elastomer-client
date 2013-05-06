
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
      # response - Faraday::Response object or a simple error message String
      #
      def initialize( response )
        if response.respond_to? :body
          message = Hash === response.body && response.body['error'] || response.body.to_s
        else
          message, response = response.to_s, nil
        end

        @response = response
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
