# Rakefile for managing asciidoc-bib project
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

desc 'run tests'
task :test do
  Dir.chdir("test") do
    sh "ruby -I.:../lib ts_tests.rb"
  end
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
