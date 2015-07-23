require 'asciidoctor/extensions'
require_relative 'bibextension'

Asciidoctor::Extensions.register do
  preprocessor AsciidocBib::Asciidoctor::AsciidocBibExtension
end
