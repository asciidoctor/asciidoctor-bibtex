
Gem::Specification.new do |s|
  s.name = "asciidoc-bib"
  s.platform = Gem::Platform::RUBY
  s.author = "Peter Lane"
  s.version = "1.6.0"
  s.email = "peter@peterlane.info"
  s.homepage = "https://github.com/petercrlane/asciidoc-bib"
  s.summary = "asciidoc-bib adds references from a bibtex file to an asciidoc file."
  s.license = "OWL"
  s.description = <<-END
asciidoc-bib generates in-text references and a reference list from an asciidoc
file, using a bibtex file as a source of citation information.  The syntax for
an in-text reference is simply [cite:bibref], and a line containing
[bibliography] inserts a complete reference list.  See the README for more
examples and further options.  The reference format supports styles provided 
by citeproc-ruby; see the README file for a complete list.
END
  s.files = Dir["lib/**/*"] + Dir["samples/*"] + [
    "LICENSE.txt",
    "README.rdoc",
    "bin/asciidoc-bib"
  ]
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files << "README.rdoc"
  s.executables << "asciidoc-bib"
  s.add_dependency("bibtex-ruby", ">=2.2.0")
  s.add_dependency("citeproc-ruby", ">=0.0.6")
end

