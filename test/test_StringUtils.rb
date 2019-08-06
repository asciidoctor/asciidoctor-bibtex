#
# test_Utils.rb
#
# Test cases for general utilities
#

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/StringUtils'

include AsciidoctorBibtex

describe AsciidoctorBibtex do
  it 'provides method to  recognise integers in strings' do
    StringUtils.is_i?('123').must_equal true
    StringUtils.is_i?('12.3').must_equal false
    StringUtils.is_i?('abc').must_equal false
  end
  it "provides method to combine consecutive numbers" do
    StringUtils.combine_consecutive_numbers("1,2,3").must_equal "1-3"
    StringUtils.combine_consecutive_numbers("1,2,3,5,7,8,9,12").must_equal "1-3, 5, 7-9, 12"
  end
end
