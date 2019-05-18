require File.expand_path('lib/asciidoctor-bibtex/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'asciidoctor-bibtex'
  s.platform = Gem::Platform::RUBY
  s.author = 'Zhang YANG'
  s.version = AsciidoctorBibtex::VERSION
  s.email = 'zyangmath@gmail.com'
  s.homepage = 'https://github.com/asciidoctor/asciidoctor-bibtex'
  s.summary = 'Adding bibtex functionality to asciidoc'
  s.license = 'OWL'
  s.description = <<-END
asciidoctor-bibtex adds bibtex support for asciidoc documents by introducing
two new macros: `cite:[KEY]` and `bibliography::[]`. Citations are parsed and
replaced with formatted inline texts, and reference lists are automatically
generated and inserted into where `bibliography::[]` is placed.  The
references are formatted using styles provided by CSL.
END
  s.files = Dir['lib/**/*'] + ['LICENSE.txt', 'README.md']
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency('asciidoctor', '>= 1.5.0', '< 3.0.0')
  s.add_runtime_dependency('bibtex-ruby', "~> 4")
  s.add_runtime_dependency('citeproc-ruby', "~> 1")
  s.add_runtime_dependency('csl-styles', '~> 1')
  s.add_runtime_dependency('latex-decode', '~> 0.2')
end
