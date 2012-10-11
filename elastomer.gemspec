require './lib/elastomer/version'

Gem::Specification.new do |s|
  s.name = %q{elastomer}
  s.version = Elastomer::VERSION
  s.authors = ["Tim Pease", "Brian Lopez"]
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.email = %q{tim@github.com brian@github.com}
  s.extensions = ["ext/elastomer/extconf.rb"]
  s.files = `git ls-files`.split("\n")
  s.homepage = %q{http://github.com/github/elastomer}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{A library for interacting with the GitHub Search infrastructure}
  s.test_files = `git ls-files test`.split("\n")

  # tests
  s.add_runtime_dependency 'tire', "~> 0.4.3"
  s.add_runtime_dependency 'minitest', "~> 4.1.0"
end

