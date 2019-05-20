# Some extension and helper methods. 
#
# Copyright (c) Peter Lane, 2012-13.
# Copyright (c) Zhang YANG, 2016-09.
# Released under Open Works License, 0.9.2

module AsciidoctorBibtex
  module Utils

    def find_bibtex_database dir
      begin
        candidates = Dir.glob("#{dir}/*.bib")
        if candidates.empty?
          return ""
        else
          return candidates.first
        end
      rescue # catch all errors, and return empty string
        return ""
      end
    end

    # Used with numeric styles to combine consecutive numbers into ranges
    # e.g. 1,2,3 -> 1-3, or 1,2,3,6,7,8,9,12 -> 1-3,6-9,12
    # leave references with page numbers alone
    def combine_consecutive_numbers str
      nums = str.split(",").collect(&:strip)
      res = ""
      # Loop through ranges
      start_range = 0
      while start_range < nums.length do
        end_range = start_range
        while (end_range < nums.length-1 and
               nums[end_range].is_i? and
               nums[end_range+1].is_i? and
               nums[end_range+1].to_i == nums[end_range].to_i + 1) do
          end_range += 1
        end
        if end_range - start_range >= 2
          res += "#{nums[start_range]}-#{nums[end_range]}, "
        else
          start_range.upto(end_range) do |i|
            res += "#{nums[i]}, "
          end
        end
        start_range = end_range + 1
      end
      # finish by removing last comma
      res.gsub(/, $/, '')
    end
  end
end

module AsciidoctorBibtexArrayExtensions

  # Retrieve the third item of an array
  # Note: no checks for validity
  def third
    self[2]
  end

  # Join items in array using commas and 'and' on last item
  def semantic_join
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
  include AsciidoctorBibtexArrayExtensions
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
