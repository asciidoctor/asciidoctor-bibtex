require 'asciidoctor/extensions'
require_relative 'bibextension'

Asciidoctor::Extensions.register do
  preprocessor AsciidoctorBibtex::Asciidoctor::AsciidoctorBibtexExtension
end
