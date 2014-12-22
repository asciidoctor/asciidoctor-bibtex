# Uses Asciidoctor extension mechanism to insert asciidoc-bib processing
# as a preprocessor step.  This provides single-pass compilation of 
# documents, including citations and references.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'asciidoctor'
require 'asciidoctor/extensions'

module AsciidocBib
  module Asciidoctor
    def Asciidoctor.AsciidocBibExtension options
      Class.new(::Asciidoctor::Extensions::Preprocessor) do
        @@options = options

        def process document, reader
          return reader if reader.eof?

          # -- read in all lines from reader, processing the lines

          lines = reader.readlines
          biblio = BibTeX.open @@options.bibfile

          processor = Processor.new biblio, @@options.links, @@options.style
          lines.each do |line|
            processor.citations.add_from_line line
          end

          # -- replace cites with correct text

          lines.each do |line|
            processor.citations.retrieve_citations(line).each do |citation|
              line.gsub!(citation.original, processor.complete_citation(citation))
            end
          end

          # -- add in bibliography

          biblio_index = lines.index "[bibliography]\n"
          unless biblio_index.nil?
            lines.delete_at biblio_index
            processor.sorted_cites.reverse.each do |ref|
              lines.insert biblio_index, "\n"
              lines.insert biblio_index, processor.get_reference(ref) + "\n"
            end
          end

          reader.unshift_lines lines
          reader
        end
      end
    end

    def Asciidoctor.setup_extension options
      ::Asciidoctor::Extensions.register do
        preprocessor Asciidoctor.AsciidocBibExtension(options)
      end
    end

    # TODO: Use CLI to include asciidoctor options
    def Asciidoctor.run options
      Asciidoctor.setup_extension options
      ::Asciidoctor.render_file options.filename, :safe => :safe, :in_place => true
    end
  end
end

