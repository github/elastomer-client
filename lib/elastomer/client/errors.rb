
module Elastomer

  # Parent class for all Elastomer errors.
  Error = Class.new StandardError

  class Client

    # General error response from client requests.
    class Error < ::Elastomer::Error

      # Construct a new Error from the given response object or a message
      # String. If a response object is given, the error message will be
      # extracted from the response body.
      #
      # response - Faraday::Response object or a simple error message String
      def initialize( response )
        if response.respond_to? :body
          message = Hash === response.body && response.body['error'] || response.body.to_s
        else
          message, response = response.to_s, nil
        end

        @status = response.nil? ? nil : response.status

        super message
      end

      # Returns the status code from the `response` or nil if the Error was not
      # created with a response.
      attr_reader :status

    end  # Error

    # Timeout specific error class.
    class TimeoutError < ::Elastomer::Error

      # Wrap a Farday TimeoutError with our own class and include the HTTP
      # path where the error originated.
      #
      # exception - The originating Faraday::Error::TimeoutError
      # path      - The path portion of the HTTP request
      #
      def initialize( exception, path )
        super "#{exception.message}: #{path}"
        set_backtrace exception.backtrace
      end
    end  # TimeoutError

  end  # Client
end  # Elastomer
