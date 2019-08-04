require 'asciidoctor/extensions'
require_relative 'extensions_impl'

Asciidoctor::Extensions.register do
  block_macro AsciidoctorBibtex::Asciidoctor::BibliographyBlockMacro
  treeprocessor AsciidoctorBibtex::Asciidoctor::CitationProcessor
end
