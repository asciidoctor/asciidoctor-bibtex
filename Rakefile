require 'rake/clean'

default_tasks = []

begin
  require 'rake/testtask'
  Rake::TestTask.new :test do |t|
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
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


JS_FILE = 'build/asciidoctor-bibtex.js'
DIST_FILE = 'dist/main.js'

task :js do
  require 'opal'

  builder = Opal::Builder.new(compiler_options: {
    dynamic_require_severity: :error,
  })
  builder.append_paths 'lib'
  builder.build 'asciidoctor-bibtex'

  FileUtils.mkdir_p([File.dirname(JS_FILE), File.dirname(DIST_FILE)])
  File.open(JS_FILE, 'w') do |file|
    file << builder.to_s
  end
  File.binwrite "#{JS_FILE}.map", builder.source_map

  FileUtils.cp JS_FILE, DIST_FILE, :verbose => true
end