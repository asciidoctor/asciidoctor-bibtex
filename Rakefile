require 'rake/clean'
require 'rake/testtask'

default_tasks = []

begin
  require 'bundler/gem_tasks'
  default_tasks << :build
rescue LoadError
  warn 'asciidoctor-bibtex: Bundler is required to build this gem. 
  You can install Bundler using `gem install` command:
  
  $ [sudo] gem install bundler' + %(\n\n)
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end

task :default => default_tasks unless default_tasks.empty?
