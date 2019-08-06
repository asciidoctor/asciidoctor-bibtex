require 'minitest/autorun'
require_relative 'helpers'

describe StyleUtils do
  it "should recognise numeric styles" do
    StyleUtils.is_numeric?("ieee").must_equal true
    StyleUtils.is_numeric?("vancouver").must_equal true
    StyleUtils.is_numeric?("vancouver-superscript").must_equal true
    StyleUtils.is_numeric?("vancouver-brackets").must_equal true
    StyleUtils.is_numeric?("apa").must_equal false
  end
end
