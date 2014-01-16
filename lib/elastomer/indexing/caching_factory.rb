module Elastomer
  class CachingFactory < Factory
    def initialize
      super
      @objects = {}
    end

    def object_for(name, *args)
      @objects[name] ||= super
    end

    def clear
      @objects.clear
    end
  end
end
