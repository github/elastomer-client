# frozen_string_literal: true

module ElastomerClient

  # Parent class for all ElastomerClient errors.
  Error = Class.new StandardError

  class Client

    # General error response from client requests.
    class Error < ::ElastomerClient::Error

      # Construct a new Error from the given response object or a message
      # String. If a response object is given, the error message will be
      # extracted from the response body.
      #
      # response - Faraday::Response object or a simple error message String
      #
      def initialize(*args)
        @status = nil
        @error = nil

        case args.first
        when Exception
          exception = args.shift
          super("#{exception.message} :: #{args.join(' ')}")
          set_backtrace exception.backtrace

        when Faraday::Response
          response = args.shift
          @status = response.status

          body = response.body
          @error = body["error"] if body.is_a?(Hash) && body.key?("error")

          message = @error || body.to_s
          super(message)

        else
          super(args.join(" "))
        end
      end

      # Returns the status code from the `response` or nil if the Error was not
      # created with a response.
      attr_reader :status

      # Returns the Elasticsearch error from the `response` or nil if the Error
      # was not created with a response.
      attr_reader :error

      # Indicates that the error is fatal. The request should not be tried
      # again.
      def fatal?
        self.class.fatal?
      end

      # The inverse of the `fatal?` method. A request can be retried if this
      # method returns `true`.
      def retry?
        !fatal?
      end

      class << self
        # By default all client errors are fatal and indicate that a request
        # should not be retried. Only a few errors are retryable.
        def fatal
          return @fatal if defined? @fatal
          @fatal = true
        end
        attr_writer :fatal
        alias_method :fatal?, :fatal
      end

    end  # Error

    # Wrapper classes for specific Faraday errors.
    TimeoutError     = Class.new Error
    ConnectionFailed = Class.new Error
    ResourceNotFound = Class.new Error
    ParsingError     = Class.new Error
    SSLError         = Class.new Error
    ServerError      = Class.new Error
    RequestError     = Class.new Error
    RequestSizeError = Class.new Error

    # Provide some nice errors for common Elasticsearch exceptions. These are
    # all subclasses of the more general RequestError
    IndexNotFoundError = Class.new RequestError
    QueryParsingError = Class.new RequestError
    SearchContextMissing = Class.new RequestError
    RejectedExecutionError = Class.new RequestError
    DocumentAlreadyExistsError = Class.new RequestError

    ServerError.fatal            = false
    TimeoutError.fatal           = false
    ConnectionFailed.fatal       = false
    RejectedExecutionError.fatal = false

    # Define an ElastomerClient::Client exception class on the fly for
    # Faraday exception classes that we don't specifically wrap.
    Faraday::Error.constants.each do |error_name|
      next if ::ElastomerClient::Client.const_get(error_name) rescue nil

      error_class = Faraday::Error.const_get(error_name)
      next unless error_class < Faraday::Error::ClientError

      ::ElastomerClient::Client.const_set(error_name, Class.new(Error))
    end

    # Exception for operations that are unsupported with the version of
    # Elasticsearch being used.
    IncompatibleVersionException = Class.new Error

    # Exception for client-detected and server-raised invalid Elasticsearch
    # request parameter.
    IllegalArgument = Class.new Error

  end
end
