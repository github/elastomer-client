module Elastomer
  class Client


    def warmer(index_name, warmer_name)
      Warmer.new(self, index_name, warmer_name)
    end

    # XXX docs
    class Warmer

      def initialize(client, index_name, name)
        raise ArgumentError, 'index name cannot be nil' if index_name.nil?

        @client = client
        @index_name = index_name
        @name = name
      end

      attr_reader :client, :index_name, :name

      def create(body, params = {})
        response = client.put '/{index}{/type}/_warmer/{warmer}', defaults.update(params.update(:body => body))
        response.body
      end

      def delete(params = {})
        response = client.delete '/{index}{/type}/_warmer/{warmer}', defaults.update(params)
        response.body
      end

      def get(params = {})
        response = client.get '/{index}{/type}/_warmer/{warmer}', defaults.update(params)
        response.body
      end

      def defaults
        {:index => index_name, :warmer => name}
      end
    end
  end
end
