# Uses Asciidoctor extension mechanism to insert asciidoc-bib processing
# as a preprocessor step.  This provides single-pass compilation of 
# documents, including citations and references.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/cli'
require_relative 'options'

module AsciidocBib
  module Asciidoctor

    class AsciidocBibExtension < ::Asciidoctor::Extensions::Preprocessor

      def process document, reader
        return reader if reader.eof?

        options = Options.new
        options.parse_attributes document.attributes

        # -- read in all lines from reader, processing the lines

        lines = reader.readlines
        biblio = BibTeX.open options.bibfile

        processor = Processor.new biblio, options.links, options.style
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

        biblio_index = lines.index do |line|
          # find bibliography macro on line by itself, with or without newline
          (line =~ BIBMACRO_FULL) != nil
        end
        unless biblio_index.nil?
          lines.delete_at biblio_index
          processor.sorted_cites.reverse.each do |ref|
            lines.insert biblio_index, "\n"
            lines.insert biblio_index, processor.get_reference(ref)
            lines.insert biblio_index, "[normal]\n" # ? needed to force paragraph breaks
          end
        end

        reader.unshift_lines lines

        return reader
      end

      BIBMACRO_FULL = /bibliography::(.*?)\[(\w+)\]/
    end

  end
end
