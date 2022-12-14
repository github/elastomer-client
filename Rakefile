require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

namespace :actions do
  desc "list valid actions"
  task :list do
    # there are two distinct :action declarations we need to find
    # the regular expressions below capture both
    #
    #   [:action] = 'some.value'
    #   :action => 'some.value'
    #
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
