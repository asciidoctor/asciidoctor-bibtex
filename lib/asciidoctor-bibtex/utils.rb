# frozen_string_literal: true

# Some extension and helper methods.
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

module AsciidoctorBibtexArrayExtensions
  # Retrieve the third item of an array
  # Note: no checks for validity
  def third
    self[2]
  end

  # Join items in array using commas and 'and' on last item
  def comma_and_join
    return join('') if size < 2

    result = ''
    each_with_index do |item, index|
      result << if index.zero?
                  item
                elsif index == size - 1
                  " and #{item}"
                else
                  ", #{item}"
                end
    end

    result
  end
end

# monkey patch the extension methods to Array
class Array
  include AsciidoctorBibtexArrayExtensions
end

# Converts html output produced by citeproc to asciidoc markup
module StringHtmlToAsciiDoc
  def html_to_asciidoc
    r = gsub(%r{</?i>}, '_')
    r = r.gsub(%r{</?b>}, '*')
    r = r.gsub(%r{</?span.*?>}, '')
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

module NumberList
  def combine_consecutive_numbers
    nums = self.split(',').collect(&:strip)
    res = ''
    # Loop through ranges
    start_range = 0
    while start_range < nums.length
      end_range = start_range
      while (end_range < nums.length - 1) &&
            nums[end_range].is_i? &&
            nums[end_range + 1].is_i? &&
            (nums[end_range + 1].to_i == nums[end_range].to_i + 1)
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

# monkey patch the extension methods into String
class String
  include StringHtmlToAsciiDoc
  include IntegerCheck
  include NumberList
end
