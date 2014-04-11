# Rakefile for managing asciidoc-bib project
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

desc 'Generates a coverage report'
task :coverage do
  `rm -rf coverage`
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

desc 'run lib code on sample'
task :samples do
  Dir.chdir("samples") do
    sh "ruby -I../lib ../bin/asciidoc-bib sample-1.txt"
  end
end

directory 'release'

desc 'build gem: keeps generated gems in release/'
task :build_gem => 'release' do
  sh "gem build asciidoc-bib.gemspec"
  sh "mv *.gem release"
end

desc 'build documentation'
task :doc do
  sh "rdoc -t asciidoc-bib README.rdoc lib/"
end
