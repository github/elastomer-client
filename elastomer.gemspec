require './lib/elastomer/version'

Gem::Specification.new do |s|
  s.name     = 'elastomer'
  s.summary  = 'A library for interacting with the GitHub Search infrastructure'
  s.homepage = 'http://github.com/github/elastomer'
  s.version  = Elastomer::VERSION
  s.authors  = ['Tim Pease', 'Brian Lopez']
  s.date     = Time.now.utc.strftime('%Y-%m-%d')
  s.email    = %w[tim.pease@github.com brian@github.com]

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files test`.split("\n")

  s.rdoc_options     = %w[--charset=UTF-8]
  s.require_paths    = %w[lib]
  s.rubygems_version = '1.4.2'

  # tests
  s.add_development_dependency 'minitest', '~> 4.1.0'
end

