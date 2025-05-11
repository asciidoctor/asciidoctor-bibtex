begin
  require_relative 'lib/asciidoctor-bibtex/version'
rescue LoadError
  require 'asciidoctor-bibtex/version'
end

Gem::Specification.new do |s|
  s.name = 'asciidoctor-bibtex'
  s.version = AsciidoctorBibtex::VERSION
  s.authors = ['Zhang YANG']
  s.email = ['zyangmath@gmail.com']
  s.homepage = 'https://github.com/asciidoctor/asciidoctor-bibtex'
  s.summary = 'An Asciidoctor extension that adds bibtex integration to AsciiDoc'
  s.license = 'OWL'
  s.description = 'asciidoctor-bibtex is an Asciidocotor extension that adds bibtex support for AsciiDoc documents. It does so by introducing two new macros: `cite:[KEY]` and `bibliography::[]`. Citations are parsed and replaced with formatted inline text, and reference lists are automatically generated and inserted where the `bibliography::[]` macro is placed. The references are formatted using styles provided by CSL.'
  s.required_ruby_version = '>= 2.4.0'
  s.files = Dir['lib/**/*'] + ['LICENSE.txt', 'README.adoc']
  s.add_runtime_dependency 'asciidoctor', '~> 2.0'
  s.add_runtime_dependency 'bibtex-ruby', '~> 6.1'
  s.add_runtime_dependency 'citeproc-ruby', '~> 1'
  s.add_runtime_dependency 'csl-styles', '~> 1'
  s.add_runtime_dependency 'latex-decode', '~> 0.2'
  s.add_runtime_dependency 'rexml', '3.2.6' # lock rexml to 3.2.6 since >= 3.2.7 breaks JRuby and adds installation requirements for CRuby

  s.add_development_dependency 'minitest', '~> 5.15.0'
  s.add_development_dependency 'rake', '~> 13.2.0'
end
