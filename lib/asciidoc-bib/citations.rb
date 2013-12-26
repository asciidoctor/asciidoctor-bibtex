#
# Class to hold and manage citations
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

module AsciidocBib
  # Class to store list of citations used in document
  class Citations
    include CitationUtils

    attr_reader :cites_used

    def initialize
      @cites_used = []
    end

    # Given a line of text, extract any citations and include new citation references in current list
    def add_from_line line
      retrieve_citations(line).each do |citation|
        @cites_used += citation.cites.collect {|cite| cite.ref}
      end
      @cites_used.uniq! {|item| item.to_s} # only keep each reference once
    end

    # Return a list of citation references in document, sorted into order
    def sorted_cites biblio
      @cites_used.sort_by do |ref|
        bibitem = biblio[ref]

        unless bibitem.nil?
          # extract the reference, and uppercase.
          # Remove { } from grouped names for sorting.
          author = bibitem.author
          if author.nil?
            author = bibitem.editor
          end
          author_chicago(author).collect {|s| s.upcase.gsub("{","").gsub("}","")} + [bibitem.year]
        else
          [ref]
        end
      end
    end
  end
end
