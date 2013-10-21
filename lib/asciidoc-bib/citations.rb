#
# Class to hold and manage citations
#
# TODO: Create a class with <=> for individual citation,
# replace @cites_used with SortedSet
#

module AsciidocBib
  class Citations
    attr_reader :cites_used

    def initialize
      @cites_used = Set.new
    end

    # Given a line of text, extract any citations and include new citations in current list
    def add_from_line line
      md = CITATION_FULL.match(line)
      while md
        cite_text = md[4]
        cm = CITATION.match(cite_text)
        while cm
          @cites_used.add Citation.new(cm[1], cm[3])
          # look for next ref within citation
          cm = CITATION.match(cm.post_match)
        end
        # look for next citation on line
        md = CITATION_FULL.match(md.post_match)
      end
    end

    def to_a
      @cites_used.to_a
    end

    def size
      @cites_used.size
    end

    private

    # matches a single ref with optional pages
    CITATION = /(\w+)(,([\w\.\- ]+))?/
    # matches complete citation with multiple references
    CITATION_FULL = /\[(cite|citenp):(([\w\-\;\!\? ]+):)?(#{CITATION}(;#{CITATION})*)\]/
    
  end
end
