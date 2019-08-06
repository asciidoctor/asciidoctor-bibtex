#
# test_Utils.rb
#
# Test cases for general utilities
#

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/utils'

describe AsciidoctorBibtex do
  it 'should do comma/join on arrays' do
    ['1'].comma_and_join.must_equal '1'
    %w[1 2].comma_and_join.must_equal '1 and 2'
    %w[1 2 3].comma_and_join.must_equal '1, 2 and 3'
    %w[1 2 3 4].comma_and_join.must_equal '1, 2, 3 and 4'
  end

  it 'should recognise integers in strings' do
    '123'.is_i?.must_equal true
    '12.3'.is_i?.must_equal false
    'abc'.is_i?.must_equal false
  end
end
