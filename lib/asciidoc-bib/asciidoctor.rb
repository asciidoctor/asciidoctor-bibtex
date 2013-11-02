
require 'asciidoctor'
require 'asciidoctor/extensions'

module AsciidocBib
  module Asciidoctor
    def Asciidoctor.AsciidocBibExtension options
      Class.new(::Asciidoctor::Extensions::Preprocessor) do
        @@options = options

        def process reader, lines
          return reader if lines.empty?

          # -- read in all lines from reader, processing the lines

          lines = []
          while reader.has_more_lines?
            lines << reader.read_line
          end

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
          # TODO: need to process the inserted lines, e.g. to number numeric references

          biblio_index = lines.index "[bibliography]\n"
          unless biblio_index.nil?
            lines.delete_at biblio_index
            processor.sorted_cites.reverse.each do |ref|
              lines.insert biblio_index, "\n"
              lines.insert biblio_index, "[[#{ref}]]" + processor.get_reference(ref) + "\n"
            end
          end

          return ::Asciidoctor::Reader.new lines
        end
      end
    end

    def Asciidoctor.setup_extension options
      ::Asciidoctor::Extensions.register do |document|
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

