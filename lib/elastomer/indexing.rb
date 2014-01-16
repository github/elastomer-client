require 'singleton'
require 'forwardable'

require 'elastomer/client'

require 'elastomer/indexing/index'
require 'elastomer/indexing/router'

module Elastomer
  def self.router
    Router.instance
  end
end
