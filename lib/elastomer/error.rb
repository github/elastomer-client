
module Elastomer

  class Error < StandardError

    attr_reader :response

    #
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

    #
    #
    def status
      response ? response.status : nil
    end

  end  # Error

end  # Elastomer
