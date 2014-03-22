module Elastomer
  class Factory
    def initialize
      @classes = {}
    end

    def register(name, klass)
      @classes[name] = klass
    end

    def class_for(name)
      @classes[name]
    end

    def object_for(name, *args)
      instantiate(@classes[name], *args) if @classes[name]
    end

    def instantiate(klass, *args)
      klass.new(*args)
    end
  end
end
