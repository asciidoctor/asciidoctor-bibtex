# Some extension and helper methods. 
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

module AsciidocBibArrayExtensions

  # Retrieve the third item of an array
  # Note: no checks for validity
  def third
    self[2]
  end

  # Join items in array using commas and 'and' on last item
  def comma_and_join
    if size < 2
      return self.join("")
    end
    result = ""
    self.each_with_index do |item, index|
      if index.zero?
        result << item
      elsif index == size-1
        result << " and #{item}"
      else
        result << ", #{item}"
      end
    end

    return result
  end
end

# monkey patch the extension methods to Array
class Array
  include AsciidocBibArrayExtensions
end

# Converts html output produced by citeproc to asciidoc markup
module StringHtmlToAsciiDoc
  def html_to_asciidoc
    r = self.gsub(/<\/?i>/, '_')
    r = r.gsub(/<\/?b>/, '*')
    r = r.gsub(/<\/?span.*?>/, '')
    r = r.gsub(/\{|\}/, '')
    r
  end
end

# Provides a check that a string is in integer
# Taken from:
# http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
module IntegerCheck
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end

# monkey patch the extension methods into String
class String
  include StringHtmlToAsciiDoc
  include IntegerCheck
end

