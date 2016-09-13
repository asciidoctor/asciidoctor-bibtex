#
# Treeprocessor extension for asciidoctor
#

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/reader'
require 'asciidoctor/parser'
require 'bibtex/filters'
require 'latex/decode/base'
require 'latex/decode/maths'
require 'latex/decode/accents'
require 'latex/decode/diacritics'
require 'latex/decode/punctuation'
require 'latex/decode/symbols'
require 'latex/decode/greek'
require_relative 'styles'
require_relative 'filehandlers'

module AsciidoctorBibtex
  module Asciidoctor

    # This filter extends the original latex filter in bibtex-ruby to handle
    # unknown latex macros more gracefully. We could have used latex-decode
    # gem together with our custom replacement rules, but latex-decode eats up
    # all braces after it finishes all decoding. So we hack over the
    # LaTeX.decode function and insert our rules before `strip_braces`.
    class LatexFilter < ::BibTeX::Filter
      def apply(value)
        text = value.to_s
        LaTeX::Decode::Base.normalize(text)
        LaTeX::Decode::Maths.decode!(text)
        LaTeX::Decode::Accents.decode!(text)
        LaTeX::Decode::Diacritics.decode!(text)
        LaTeX::Decode::Punctuation.decode!(text)
        LaTeX::Decode::Symbols.decode!(text)
        LaTeX::Decode::Greek.decode!(text)
        text.gsub!(/\\url\{(.+?)\}/, " \\1 ")
        text.gsub!(/\\\w+(?=\s+\w)/, "")
        text.gsub!(/\\\w+(?:\[.+?\])?\s*\{(.+?)\}/, "\\1")
        LaTeX::Decode::Base.strip_braces(text)
        LaTeX.normalize_C(text)
      end
    end

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
        bibtex_order = ((document.attr 'bibtex-order') || 'appearance').to_sym
        bibtex_format = ((document.attr 'bibtex-format') || 'asciidoc').to_sym

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

        bibtex = BibTeX.open bibtex_file, :filter => [LatexFilter]
        processor = Processor.new bibtex, true, bibtex_style, bibtex_order == :appearance, bibtex_format

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
        if bibtex_format == :latex
          references_asciidoc << %(+++\\bibliography{#{bibtex_file}}{}+++)
          references_asciidoc << %(+++\\bibliographystyle{#{bibtex_style}}+++)
        else
          processor.cites.each do |ref|
            references_asciidoc << processor.get_reference(ref)
            references_asciidoc << ''
          end
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
          reference_blocks = parse_asciidoc block.parent, references_asciidoc
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
