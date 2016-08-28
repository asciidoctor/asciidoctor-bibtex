#
# Treeprocessor extension for asciidoctor
#

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/reader'
require 'asciidoctor/parser'
require_relative 'styles'
require_relative 'filehandlers'

module AsciidoctorBibtex
  module Asciidoctor
    BibliographyBlockMacroPlaceholder = %(BIBLIOGRAPHY BLOCK MACRO PLACEHOLDER)

    # This macro processor does only half the work. It just parse the macro
    # and set bibtex file and style if found in the macro. The macro is then
    # expanded to a special paragraph, which is then replaced with generated
    # references by the treeprocessor.
    class BibliographyBlockMacro < ::Asciidoctor::Extensions::BlockMacroProcessor
      use_dsl
      named :bibliography
      positional_attributes :style

      def process parent, target, attrs
        # NOTE: bibtex-file and bibtex-style set by this macro shall be
        # overridable by document attributes and commandline arguments. So we
        # respect the convention here.
        if target and not parent.document.attr? 'bibtex-file'
          parent.document.set_attribute 'bibtex-file', target
        end
        if attrs.key? :style and not parent.document.attr? 'bibtex-style'
          parent.document.set_attribute 'bibtex-style', attrs[:style]
        end
        create_paragraph parent, BibliographyBlockMacroPlaceholder, {}
      end
    end

    # This processor scans the document, generates a list of citations,
    # replace each citation with correct text and the reference block macro
    # placeholder with the final reference list. It relys on the block macro
    # processor to generate the place holder.
    class CitationProcessor < ::Asciidoctor::Extensions::Treeprocessor

      def process document
        bibtex_file = (document.attr 'bibtex-file').to_s
        bibtex_style = ((document.attr 'bibtex-style') || 'ieee').to_s
        bibtex_order = ((document.attr 'bibtex-order') || 'alphabetical').to_sym
        bibtex_output = ((document.attr 'bibtex-output') || 'asciidoc').to_sym

        if bibtex_file.empty?
          bibtex_file = AsciidoctorBibtex::FileHandlers.find_bibliography "."
        end
        if bibtex_file.empty?
          bibtex_file = AsciidoctorBibtex::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
        if bibtex_file.empty?
          puts "Error: bibtex-file is not set and automatic search failed"
          exit
        end

        bibtex = BibTeX.open bibtex_file
        processor = Processor.new bibtex, true, bibtex_style, bibtex_order == :appearance, bibtex_output

        prose_blocks = document.find_by {|b| b.content_model == :simple or b.context == :list_item}
        prose_blocks.each do |block|
          if block.context == :list_item
            line = block.instance_variable_get :@text
            processor.citations.add_from_line line
          else
            block.lines.each do |line|
              processor.citations.add_from_line line
            end
          end
        end

        prose_blocks.each do |block|
          if block.context == :list_item
            line = block.instance_variable_get :@text
            processor.citations.retrieve_citations(line).each do |citation|
              line.gsub!(citation.original, processor.complete_citation(citation))
            end
            block.instance_variable_set :@text, line
          else
            block.lines.each do |line|
              processor.citations.retrieve_citations(line).each do |citation|
                line.gsub!(citation.original, processor.complete_citation(citation))
              end
            end
          end
        end

        references_asciidoc = []
        processor.cites.each do |ref|
          references_asciidoc << processor.get_reference(ref)
          references_asciidoc << ''
        end

        biblio_blocks = document.find_by do |b|
          # for fast search (since most searches shall fail)
          b.content_model == :simple and b.lines.size == 1 \
            and b.lines[0] == BibliographyBlockMacroPlaceholder
        end
        biblio_blocks.each do |block|
          block_index = block.parent.blocks.index do |b|
            b == block
          end
          if bibtex_output == :latex
            content = []
            content << %(+++\\bibliography{#{bibtex_file}}{}+++)
            content << %(+++\\bibliographystyle{#{bibtex_style}}+++)
            reference_blocks = parse_asciidoc block.parent, content
          else
            reference_blocks = parse_asciidoc block.parent, references_asciidoc
          end
          reference_blocks.reverse.each do |b|
            block.parent.blocks.insert block_index, b
          end
          block.parent.blocks.delete_at block_index + reference_blocks.size
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
