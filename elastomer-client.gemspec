# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elastomer/version"

Gem::Specification.new do |spec|
  spec.name          = "elastomer-client"
  spec.version       = Elastomer::VERSION
  spec.authors       = ["Tim Pease", "Grant Rodgers"]
  spec.email         = ["tim.pease@github.com", "grant.rodgers@github.com"]
  spec.summary       = %q{A library for interacting with Elasticsearch}
  spec.description   = %q{Elastomer is a low level API client for the
                          Elasticsearch HTTP interface.}
  spec.homepage      = "https://github.com/github/elastomer-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.5"
  spec.add_dependency "faraday",     "~> 0.8"
  spec.add_dependency "faraday_middleware", "~> 0.12"
  spec.add_dependency "multi_json",  "~> 1.12"
  spec.add_dependency "semantic",    "~> 1.6"

  spec.add_development_dependency "bundler",            "~> 2.3"
  spec.add_development_dependency "activesupport",      "~> 7.0"
  spec.add_development_dependency "minitest",           "~> 5.16"
  spec.add_development_dependency "minitest-focus",     "~> 1.3"
  spec.add_development_dependency "webmock",            "~> 3.18"
  spec.add_development_dependency "debug",              "~> 1.7.0"
  spec.add_development_dependency "spy",                "~> 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-github"
  spec.add_development_dependency "rubocop-minitest"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
end
