# citationdata class
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

module AsciidoctorBibtex
  # Class to hold information about a citation in text:
  # the text forming the citation, its type, pretext, and enclosed cites
  class CitationData 
    attr_reader :original, :type, :pretext, :cites 

    def initialize original, type, pretext, cites
      @original = original
      @type = type
      @pretext = if pretext.nil?
                   ''
                 else
                   pretext
                 end
      @cites = cites
    end
  end
end
