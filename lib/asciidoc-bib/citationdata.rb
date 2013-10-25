# citationdata struct
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

module AsciidocBib
  # Structure to hold information about a citation in text:
  # the text forming the citation, its type, pretext, and constituent cites
  CitationData = Struct.new :original, :type, :pretext, :cites 
end
