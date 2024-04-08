# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elastomer_client/version"

Gem::Specification.new do |spec|
  spec.name          = "elastomer-client"
  spec.version       = ElastomerClient::VERSION
  spec.authors       = ["Tim Pease", "Grant Rodgers"]
  spec.email         = ["tim.pease@github.com", "grant.rodgers@github.com"]
  spec.summary       = %q{A library for interacting with Elasticsearch}
  spec.description   = %q{ElastomerClient is a low level API client for the
                          Elasticsearch HTTP interface.}
  spec.homepage      = "https://github.com/github/elastomer-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.5"
  spec.add_dependency "faraday",     ">= 0.8"
  spec.add_dependency "faraday_middleware", ">= 0.12"
  spec.add_dependency "multi_json",  "~> 1.12"
  spec.add_dependency "semantic",    "~> 1.6"
end
