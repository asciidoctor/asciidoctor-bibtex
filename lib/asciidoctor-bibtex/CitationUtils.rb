# Utility functions for citations class
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2
#

module AsciidoctorBibtex
  # Some utility functions used in Citations class
  module CitationUtils
    # arrange author string, flag for order of surname/initials
    def arrange_authors(authors, surname_first)
      return [] if authors.nil?

      authors.split(/\band\b/).collect do |name|
        if name.include?(', ')
          parts = name.strip.rpartition(', ')
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
    def author_chicago(authors)
      arrange_authors authors, true
    end
  end
end