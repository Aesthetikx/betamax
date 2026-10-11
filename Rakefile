require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new :spec

Rake::TestTask.new :test do |task|
  task.libs << 'lib'
  task.pattern = 'test/**/*_test.rb'
end

RuboCop::RakeTask.new

task default: %i[spec test rubocop]
