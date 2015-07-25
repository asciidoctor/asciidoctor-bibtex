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
and a reference list for an asciidoc file, using a bibtex file as a source of
citation information. The citation syntax tries to assemble asciidoc inline
macros and block macros, with `cite:[bibref]` for in-text citation and
`bibliography::[]` for reference list. It can be used standalone or as an
asciidoctor extension. See the README for more examples and further options.
The references are formatted using styles provided by CSL.
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
  s.add_runtime_dependency('bibtex-ruby', '~>4.0', '>=4.0.11')
  s.add_runtime_dependency('citeproc-ruby', '~>1.0', '>=1.0.5')
  s.add_runtime_dependency('csl-styles', '~>1.0', '>=1.0.1.6')
end

