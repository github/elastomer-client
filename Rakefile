require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
    t.pattern = "test/**/*_test.rb"
end

task :default => :test

namespace :actions do
  desc "list valid actions"
  task :list do
    list = %x(grep '\\[\\?:action\\]\\?\\s\\+=' `find lib -name '*.rb'`).split("\n")
    list.map! do |line|
      m = /\A.*?\[?:action\]?\s+=>?\s+'(.*?)'.*\Z/.match line
      m.nil? ? nil : m[1]
    end

    list.compact.sort.uniq.each do |action|
      STDOUT.puts "- #{action}"
    end
  end
end
