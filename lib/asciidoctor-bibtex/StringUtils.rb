# frozen_string_literal: true

#
# StringUtils.rb
#
# Some utilities for strings.
#
# Copyright (c) Peter Lane, 2012-13.
# Copyright (c) Zhang Yang, 2019.
#
# Released under Open Works License, 0.9.2
#

module AsciidoctorBibtex
  module StringUtils
    # Converts html output produced by citeproc to asciidoc markup
    def self.html_to_asciidoc(s)
      s = s.gsub(%r{</?i>}, '_')
      s = s.gsub(%r{</?b>}, '*')
      s = s.gsub(%r{</?span.*?>}, '')
      s = s.gsub(/\{|\}/, '')
      s
    end

    # Provides a check that a string is in integer
    def self.is_i?(s)
      !!(s =~ /^[-+]?[0-9]+$/)
    end

    # Merge consecutive number so that "1,2,3,5" becomes "1-3,5"
    def self.combine_consecutive_numbers(str)
      nums = str.split(',').collect(&:strip)
      res = ''
      # Loop through ranges
      start_range = 0
      while start_range < nums.length
        end_range = start_range
        while (end_range < nums.length - 1) &&
              is_i?(nums[end_range]) &&
              is_i?(nums[end_range + 1]) &&
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
end
