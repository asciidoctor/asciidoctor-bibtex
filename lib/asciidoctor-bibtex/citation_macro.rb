#
# CitationMacro.rb
#
# Copyright (c) Peter Lane, 2013.
# Copyright (c) Zhang Yang, 2019.
#
# Released under Open Works License, 0.9.2
#

module AsciidoctorBibtex
  # CitationItem
  #
  # A class to hold data for a single citation item.
  #
  class CitationItem
    attr_reader :key, :locator

    def initialize(key, locator)
      @key = key
      @locator = locator
      # clean up locator
      @locator ||= ''
      @locator = @locator.gsub('--', '-')
    end

    def to_s
      "#{@key}:#{@locator}"
    end
  end

  # CitationMacro
  #
  # Class to hold information about a citation macro.  A citation macro has
  # type, text and an array of citation items.
  #
  # This class also provides a class method to extract macros from a line of
  # text.
  #
  class CitationMacro
    #
    # Grammar for the citation macro: cite|citenp:[Key(locator)]
    #

    # matches a citation type
    CITATION_TYPE = /cite|citenp/.freeze
    # matches a citation item (key + locator), such as 'Dan2012(99-100)'
    CITATION_ITEM = /([^\s,()\[\]]+)(\([^)]*\))?/.freeze
    # matches a citation list
    CITATION_LIST_TAIL = /(\s*,\s*#{CITATION_ITEM})*/.freeze
    CITATION_LIST = /(?:#{CITATION_ITEM}#{CITATION_LIST_TAIL})/.freeze
    CITATION_PRETEXT = /[^\[]*/.freeze
    # matches the full citation macro
    CITATION_MACRO = /(#{CITATION_TYPE}):(#{CITATION_PRETEXT})\[(#{CITATION_LIST})\]/.freeze

    # Given a line, return a list of CitationData instances
    # containing information on each set of citation information
    def self.extract_citations(line)
      result = []
      full = CITATION_MACRO.match line
      while full
        text = full[0]
        type = full[1]
        pretext = full[2]
        items = []
        item = CITATION_ITEM.match full[3]
        while item
          locator = nil
          locator = item[2][1...-1] if item[2]
          items << CitationItem.new(item[1], locator)
          # look for next ref within citation
          item = CITATION_ITEM.match item.post_match
        end
        result << CitationMacro.new(text, type, pretext, items)
        # look for next citation on line
        full = CITATION_MACRO.match full.post_match
      end

      result
    end

    attr_reader :text, :type, :pretext, :items

    # Create a CitationMacro object
    #
    # text: the full macro text matched by CITATION_MACRO
    # type: cite or citenp
    # pretext: some small texts.
    # items: An array of citation items
    def initialize(text, type, pretext, items)
      @text = text
      @type = type
      @pretext = pretext
      @items = items
    end
  end
end
