
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
      #
      def initialize( *args )
        @status = nil

        case args.first
        when Exception
          exception = args.shift
          super("#{exception.message}: #{args.join(' ')}")
          set_backtrace exception.backtrace

        when Faraday::Response
          response = args.shift
          message = Hash === response.body && response.body['error'] || response.body.to_s
          @status = response.status
          super message

        else
          super args.join(' ')
        end
      end

      # Returns the status code from the `response` or nil if the Error was not
      # created with a response.
      attr_reader :status

    end  # Error

    # Wrapper classes for specific Faraday errors.
    TimeoutError     = Class.new Error
    ConnectionFailed = Class.new Error
    ResourceNotFound = Class.new Error
    ParsingError     = Class.new Error
    SSLError         = Class.new Error

  end  # Client
end  # Elastomer
