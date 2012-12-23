
Gem::Specification.new do |s|
  s.name = "asciidoc-bib"
  s.platform = Gem::Platform::RUBY
  s.author = "Peter Lane"
  s.version = "1.0.0"
  s.email = "peter@peterlane.info"
  s.homepage = "https://github.com/petercrlane/asciidoc-bib"
  s.summary = "asciidoc-bib adds references from a bibtex file to an asciidoc file."
  s.license = "OWL"
  s.description = <<-END
asciidoc-bib generates in-text references and a reference list from an asciidoc
file, using a bibtex file as a source of citation information.  The syntax for
an in-text reference is simply [cite:bibref], and a line containing
[bibliography] inserts a complete reference list.  Currently, the reference
format is author-year, in a style after that in 'The Chicago Manual of Style'.
END
  s.files = [
    "LICENSE.txt",
    "README.md",
    "bin/asciidoc-bib",
    "lib/asciidoc-bib.rb",
  ]
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files << "README.md"
  s.executables << "asciidoc-bib"
end

