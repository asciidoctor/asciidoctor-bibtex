require File.expand_path('lib/asciidoc-bib/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'asciidoc-bib'
  s.platform = Gem::Platform::RUBY
  s.author = 'Peter Lane'
  s.version = AsciidocBib::VERSION
  s.email = 'peter@peterlane.info'
  s.homepage = 'https://github.com/petercrlane/asciidoc-bib'
  s.summary = 'asciidoc-bib adds references from a bibtex file to an asciidoc file.'
  s.license = 'OWL'
  s.description = <<-END
asciidoc-bib generates in-text references and a reference list from an asciidoc
file, using a bibtex file as a source of citation information.  The syntax for
an in-text reference is simply [cite:bibref], and a line containing
[bibliography] inserts a complete reference list.  See the README for more
examples and further options.  The references are formatted using styles provided 
by CSL.
END
  s.files = Dir['lib/**/*'] + Dir['samples/*'] + [
    'LICENSE.txt',
    'README.rdoc',
    'bin/asciidoc-bib',
    'bin/asciidoctor-bib'
  ]
  s.has_rdoc = true
  s.extra_rdoc_files << 'README.rdoc'
  s.executables << 'asciidoc-bib'
  s.executables << 'asciidoctor-bib'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency('bibtex-ruby', '~>4.0', '>=4.0.11')
  s.add_runtime_dependency('citeproc-ruby', '~>1.0', '>=1.0.5')
  s.add_runtime_dependency('csl-styles', '~>1.0', '>=1.0.1.6')
end

