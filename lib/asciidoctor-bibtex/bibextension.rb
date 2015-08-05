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

module AsciidoctorBibtex
  module Asciidoctor

    class AsciidoctorBibtexExtension < ::Asciidoctor::Extensions::Preprocessor

      ASCIIDOC_ATTR_ENTRY = /^:([^\s:]+):(.*)$/
      BIB_ATTR_NAMES = ['bib-file', 'bib-style', 'bib-numeric-order', 'bib-no-links']
      BIBLIOGRAPHY_BLOCK_MACRO = /^bibliography::(.*?)\[([^\s\]]+)?\]$/
      
      def extract_bib_attrs_from_source lines
        attrs = Hash.new
        lines.each do |line|
          if (m = ASCIIDOC_ATTR_ENTRY.match line)
            name, value = m[1], m[2].strip
            if not ([name] & BIB_ATTR_NAMES).empty?
              attrs[name] = value
            end
          elsif (m = BIBLIOGRAPHY_BLOCK_MACRO.match line)
            bibfile, style = m[1], m[2]
            if not bibfile.empty?
              attrs['bib-file'] = bibfile.strip
            end
            if style and not style.empty?
              attrs['bib-style'] = style.strip
            end
          end
        end
        attrs
      end

      def extract_bib_attrs_from_cli document
        attrs = Hash.new
        BIB_ATTR_NAMES.each do |x|
          if document.attributes.has_key? x
            attrs[x] = document.attributes[x]
          end
        end
        attrs
      end

      def process document, reader
        return reader if reader.eof?

        # -- parse options from document attributes and document source

        lines = reader.readlines

        attrs_src = extract_bib_attrs_from_source lines
        attrs_cli = extract_bib_attrs_from_cli document

        options = Options.new
        options.parse_attributes attrs_cli, attrs_src

        # -- read in all lines from reader, processing the lines

        biblio = BibTeX.open options.bibfile
        processor = Processor.new biblio, options.links, options.style, options.numeric_in_appearance_order?

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
          processor.cites.reverse.each do |ref|
            lines.insert biblio_index, "\n"
            lines.insert biblio_index, processor.get_reference(ref)
            lines.insert biblio_index, "[normal]\n" # ? needed to force paragraph breaks
          end
        end

        reader.unshift_lines lines

        return reader
      end

      BIBMACRO_FULL = /bibliography::(.*?)\[(\w+)?\]/
    end

  end
end
