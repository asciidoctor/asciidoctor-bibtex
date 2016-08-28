require 'asciidoctor/extensions'
require_relative 'bibextension'

Asciidoctor::Extensions.register do
  block_macro AsciidoctorBibtex::Asciidoctor::BibliographyBlockMacro
  treeprocessor AsciidoctorBibtex::Asciidoctor::CitationProcessor
end
