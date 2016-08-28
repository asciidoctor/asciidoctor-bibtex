#
# Treeprocessor extension for asciidoctor
#

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/reader'
require 'asciidoctor/parser'
require_relative 'styles'

module AsciidoctorBibtex
  module Asciidoctor

    class AsciidoctorBibtexExtension < ::Asciidoctor::Extensions::Treeprocessor
      LineFeed = %(\n)
      BibBlockMacroRx = /bibliography::(.*?)\[(\w+)?\]/

      def process document
        bibtex_file = (document.attr 'bibtex-file').to_s
        bibtex_style = ((document.attr 'bibtex-style') || 'ieee').to_s
        bibtex_order = ((document.attr 'bibtex-order') || 'alphabetical').to_sym

        bibtex = BibTeX.open bibtex_file
        processor = Processor.new bibtex, true, bibtex_style, bibtex_order

        prose_blocks = document.find_by {|b| b.content_model == :simple}
        prose_blocks.each do |block|
          block.lines.each do |line|
            processor.citations.add_from_line line
          end
        end

        prose_blocks.each do |block|
          block.lines.each do |line|
            processor.citations.retrieve_citations(line).each do |citation|
              line.gsub!(citation.original, processor.complete_citation(citation))
            end
          end
        end

        references_asciidoc = []
        processor.cites.each do |ref|
          references_asciidoc << processor.get_reference(ref)
          references_asciidoc << ''
        end

        prose_blocks.each do |block|
          is_bib_block_macro = (block.lines * LineFeed =~ BibBlockMacroRx) != nil
          if is_bib_block_macro
            block_index = block.parent.blocks.index do |b|
              b == block
            end
            reference_blocks = parse_asciidoc block.parent, references_asciidoc
            reference_blocks.reverse.each do |b|
              block.parent.blocks.insert block_index, b
            end
            block.parent.blocks.delete_at block_index + reference_blocks.size
          end
        end

        nil
      end

      # This is an adapted version of Asciidoctor::Extension::parse_content,
      # where resultant blocks are returned as a list instead of attached to
      # the parent.
      def parse_asciidoc parent, content, attributes = {}
        result = []
        reader = ::Asciidoctor::Reader.new content
        while reader.has_more_lines?
          block = ::Asciidoctor::Parser.next_block reader, parent, attributes
          result << block if block
        end
        result
      end

    end

  end
end
