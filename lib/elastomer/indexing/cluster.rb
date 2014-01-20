module Elastomer
  class Cluster
    attr_accessor :name, :options, :client

    def self.default_name
      'default'
    end

    def initialize(name, options = {})
      @name = name
      @options = options
      @client = Elastomer::Client.new(options)
    end
  end
end
