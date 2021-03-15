#
# test_Utils.rb
#
# Test cases for general utilities
#

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/string_utils'

include AsciidoctorBibtex

describe AsciidoctorBibtex do
  it 'provides method to  recognise integers in strings' do
    _(StringUtils.is_i?('123')).must_equal true
    _(StringUtils.is_i?('12.3')).must_equal false
    _(StringUtils.is_i?('abc')).must_equal false
  end
  it "provides method to combine consecutive numbers" do
    _(StringUtils.combine_consecutive_numbers("1,2,3")).must_equal "1-3"
    _(StringUtils.combine_consecutive_numbers("1,2,3,5,7,8,9,12")).must_equal "1-3, 5, 7-9, 12"
  end
end
