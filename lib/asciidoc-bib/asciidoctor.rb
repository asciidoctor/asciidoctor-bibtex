# Uses Asciidoctor extension mechanism to insert asciidoc-bib processing
# as a preprocessor step.  This provides single-pass compilation of 
# documents, including citations and references.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/cli'
require 'asciidoc-bib/options'

module AsciidocBib
  module Asciidoctor
    def Asciidoctor.AsciidocBibExtension
      Class.new(::Asciidoctor::Extensions::Preprocessor) do
        @@options = Options.new

        def process document, reader
          return reader if reader.eof?

          @@options.parse_attributes document.attributes

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

          biblio_index = lines.index do |line|
            # find [bibliography] on line by itself, with or without newline
            (line =~ /\[bibliography\](\n)?/) != nil
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
      end
    end

    def Asciidoctor.setup_extension
      ::Asciidoctor::Extensions.register do
        preprocessor Asciidoctor.AsciidocBibExtension
      end
    end

    # Use standard asciidoctor CLI mechanism to call asciidoctor, so we can
    # accept all asciidoctor options. Note that we only accept asciidoctor
    # options here.
    def Asciidoctor.run options
      Asciidoctor.setup_extension
      invoker = ::Asciidoctor::Cli::Invoker.new options
      GC.start
      invoker.invoke!
      exit invoker.code
    end
  end
end

