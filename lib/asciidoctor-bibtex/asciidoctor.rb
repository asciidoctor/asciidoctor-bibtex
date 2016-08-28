require 'asciidoctor/extensions'
require_relative 'bibextension'

Asciidoctor::Extensions.register do
  treeprocessor AsciidoctorBibtex::Asciidoctor::AsciidoctorBibtexExtension
end
