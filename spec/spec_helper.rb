require 'rubygems' if !defined?(Gem)
require 'bundler/setup'
require 'rspec'

# push the lib folder onto the load path
$LOAD_PATH.unshift 'lib'
require 'elastomer'

RSpec.configure do |config|
  # config.formatter = 'documentation'
  # config.order = 'random'

  # makes it so we can use `test` instead of `it` when defining test cases
  # config.alias_example_to :test

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

