module Elastomer

  def self.router
    Router.instance
  end

  class Router
    include Singleton

    attr_accessor :clients

    #TODO should adapter and index routing be delegated to sub-objects?

    # What local maps do we need?
    # cluster name => uri maybe?
    # cluster name => client maybe?
    # adapter type => adapter class
    # index name => client
    # index name => index class
    # index name => physical location maybe?

    #TODO use HashWithIndifferentAccess?

    def initialize
      @index_classes = {}
      @adapter_classes = {}
      @indices = {}
    end

    def register_index_class(name, klass)
      @index_classes[name] = klass
    end

    def index_for(name)
      @indices[name] ||= begin
        if klass = @index_classes[name]

          #TODO determine proper client and physical name
          client = Elastomer::Client.new
          physical_name = klass.physical_name

          klass.new(client.index(name))
        end
      end
    end

    def register_adapter_class(type, klass)
      @adapter_classes[type] = klass
    end

    def adapter_for(type)
      if klass = @adapter_classes[type]
        klass.new
      end
    end
  end
end
