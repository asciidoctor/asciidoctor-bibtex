require File.expand_path('lib/asciidoctor-bibtex/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'asciidoctor-bibtex'
  s.platform = Gem::Platform::RUBY
  s.author = 'Zhang YANG'
  s.version = AsciidoctorBibtex::VERSION
  s.email = 'zyangmath@gmail.com'
  s.homepage = 'https://github.com/ProgramFan/asciidoctor-bibtex'
  s.summary = 'asciidoctor-bibtex adds bibtex references to an asciidoc file.'
  s.license = 'OWL'
  s.description = <<-END
asciidoctor-bibtex is a fork of asciidoc-bib. It generates in-text references
and reference lists for asciidoc files, using specified bibtex file as
ciatation source.  The citation syntax follows asciidoc inline and block macro
idiom and resembles bibtex macros, with `cite:[bibref]` or `citenp:[bibref]`
for in-text citation and `bibliography::[]` for reference list. It can be used
standalone or as an asciidoctor extension. See the README for more examples
and further options.  The references are formatted using styles provided by
CSL.
END
  s.files = Dir['lib/**/*'] + Dir['samples/*'] + [
    'LICENSE.txt',
    'README.rdoc',
    'bin/asciidoctor-bibtex',
    'bin/asciidoc-bibtex'
  ]
  s.has_rdoc = true
  s.extra_rdoc_files << 'README.rdoc'
  s.executables << 'asciidoctor-bibtex'
  s.executables << 'asciidoc-bibtex'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency('bibtex-ruby', "~> 4")
  s.add_runtime_dependency('citeproc-ruby', "~> 1")
  s.add_runtime_dependency('csl-styles', '~> 1')
end

