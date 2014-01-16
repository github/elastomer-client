module Elastomer
  class Adapter

    attr_accessor :index

    def initialize
    end

    #TODO model, adapt

    #TODO to_hash

    #TODO each or similar

    #TODO store/remove

    module Routing
      def register_as(type)
        Elastomer.router.register_adapter_class(type, self)
      end
    end
    extend Routing
  end
end
