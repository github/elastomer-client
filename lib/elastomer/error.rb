
module Elastomer

  # General error response from client requests.
  #
  class Error < StandardError

    attr_reader :response

    # Construct a new Error from the given response object or a message
    # String. If a response object is given, the error message will be
    # extracted from the response body.
    #
    # response - Either a message String or a Faraday::Response
    #
    def initialize( response )
      message =
        if response.respond_to? :body
          @response = response
          response.body['error'] || response.body
        else
          response
        end

      super(message)
    end

    # Returns the status code from the `response` or nil if the Error was not
    # created with a response.
    def status
      response ? response.status : nil
    end

  end  # Error
end  # Elastomer
