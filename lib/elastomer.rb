
# Elastomer provides an interface for indexing documents into a search engine
# and, subsequently, searching those documents.
#
module Elastomer

  # Parent class for all Elastomer errors.
  Error = Class.new StandardError

end  # Elastomer

require File.expand_path('../elastomer/version', __FILE__) unless defined? Elastomer::VERSION
