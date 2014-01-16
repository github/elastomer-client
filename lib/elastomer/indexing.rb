require 'singleton'
require 'forwardable'

require 'elastomer/client'

require 'elastomer/indexing/index'
require 'elastomer/indexing/router'
require 'elastomer/indexing/adapter'

module Elastomer
  def self.router
    Router.instance
  end
end
