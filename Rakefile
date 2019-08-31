require 'rake/clean'

default_tasks = []

begin
  require 'rake/testtask'
  Rake::TestTask.new :test do |t|
    t.libs << 'test'
    t.pattern = 'test/**/test_*.rb'
    t.verbose = true
    t.warning = true
  end
rescue LoadError
  warn $!.message
end

begin
  require 'bundler/gem_tasks'
  default_tasks << :build
rescue LoadError
  warn 'asciidoctor-bibtex: Bundler is required to build this gem. 
  You can install Bundler using `gem install` command:
  
  $ [sudo] gem install bundler' + %(\n\n)
end

task :default => default_tasks unless default_tasks.empty?
