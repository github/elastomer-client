# Basic test environment.
#
# This should set up the load path for testing only. Don't require any support libs
# or gitrpc stuff in here.

# blah fuck this
require 'rubygems' if !defined?(Gem)
require 'bundler/setup'

# bring in minitest
require 'minitest/autorun'

# put lib and test dirs directly on load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('..', __FILE__)
