require 'rubygems' unless defined? Gem
require 'bundler/setup'

require 'minitest/spec'
require 'minitest/autorun'

# push the lib folder onto the load path
$LOAD_PATH.unshift 'lib'
require 'elastomer'
