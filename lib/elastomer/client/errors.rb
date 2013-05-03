
module Elastomer

  # Parent class for all Elastomer errors.
  Error = Class.new StandardError

  class Client

    # An exception factory method. In ruby, the `raise` method does not
    # directly create a new exception. Instead, it calls the `exception`
    # method on whatever object you pass to raise. We use this fact to
    # generate specific exceptions based on the response received from
    # ElasticSearch.
    #
    # response  - Faraday Response object
    # backtrace - Optional backtrace Array
    #
    # Returns a new Elastomer::Client::Error instance
    def self.exception( response, backtrace = nil )
      if response.respond_to? :body
        message = Hash === response.body && response.body['error'] || response.body.to_s
      else
        message, response = response, nil
      end

      # error = Error.new(message, response)
      error = create_error(message, response)
      error.set_backtrace backtrace unless backtrace.nil?
      error
    end

    # Internal: Given an ElasticSearch error message, try and construct a
    # specific Error based on the message. We create these new exception
    # classes on the fly as they are parsed out of the error messages. So the
    # first time we get `SearchPhaseExecutionException` message from
    # ElasticSearch we go ahead and create a SearchPhaseExecutionException
    # class that inherits from Elastomer::Client::Error. All these classes
    # reside under the Client namespace.
    #
    # message  - Error message String from ElasticSearch
    # response - Faraday Response object
    #
    # Examples
    #
    #   create_error('IndexMissingException[[users] missing]', response)
    #   #=> <Elastomer::Client::IndexMissingException: [users] missing>
    #
    # Returns a specific exception class based on the ElasticSearch error message
    def self.create_error( message, response )
      return Error.new(message) if response.nil?

      m = /\A(.*?Exception)(\[.*\];?)\s*\z/.match message
      return Error.new(message, response) if m.nil?

      message = m[2]
      classname = m[1]

      unless const_defined? classname
        const_set(classname, Class.new(Error))
      end

      clazz = const_get(classname)
      clazz.new(message, response)
    end

    # General error response from client requests.
    #
    class Error < ::Elastomer::Error

      # Construct a new Error from the given response object or a message
      # String. If a response object is given, the error message will be
      # extracted from the response body.
      #
      # response - Either a message String or a Faraday::Response
      #
      def initialize( message, response = nil )
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
