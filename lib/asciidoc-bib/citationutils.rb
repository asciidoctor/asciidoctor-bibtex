# Utility functions for citations class
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

module AsciidocBib
  # Some utility functions used in Citations class
  module CitationUtils

    # Given a line, return a list of CitationData instances
    # containing information on each set of citation information
    def retrieve_citations line
      result = []
      md = CITATION_FULL.match line
      while md
        data = CitationData.new md[0], md[1], md[3], []
        cm = CITATION.match md[4]
        while cm
          data.cites << Citation.new(cm[1], cm[3])
          # look for next ref within citation
          cm = CITATION.match cm.post_match 
        end
        result << data
        # look for next citation on line
        md = CITATION_FULL.match md.post_match 
      end

      return result
    end

    # arrange author string, flag for order of surname/initials
    def arrange_authors authors, surname_first 
      return [] if authors.nil?
      authors.split(/\band\b/).collect do |name|
        if name.include?(", ")
          parts = name.strip.rpartition(", ")
          if surname_first
            "#{parts.first}, #{parts.third}"
          else
            "#{parts.third} #{parts.first}"
          end
        else
          name
        end
      end
    end

    # Arrange given author string into Chicago format
    def author_chicago authors 
      arrange_authors authors, true 
    end

    # matches a single ref with optional pages
    CITATION = /(\w+)(,([\w\.\- ]+))?/
    # matches complete citation with multiple references
    CITATION_FULL = /\[(cite|citenp):(([\w\-\;\!\? ]+):)?(#{CITATION}(;#{CITATION})*)\]/
  end
end
