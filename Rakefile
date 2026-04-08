# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/audit/task'
require 'rake/testtask'
require 'rubocop/rake_task'

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'klaus/version'

Bundler::Audit::Task.new
RuboCop::RakeTask.new

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.warning = false
  t.verbose = true
  t.pattern = 'test/**/*_test.rb'
end

desc 'Run code quality checks'
task code_quality: %i[bundle:audit rubocop]

task default: %i[code_quality test]

desc 'Build gem and create git tag'
task :release do
  version = Klaus::VERSION
  tag = "v#{version}"
  sh 'gem build klaus.gemspec'
  sh "git tag -a #{tag} -m 'Release #{tag}'"
  puts "\nTagged #{tag}. Push with: git push origin #{tag}"
end
