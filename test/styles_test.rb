require 'asciidoc-bib'
require 'minitest/autorun'

describe Styles do
  it "should recognise numeric styles" do
    Styles.is_numeric?("ieee").must_equal true
    Styles.is_numeric?("vancouver").must_equal true
    Styles.is_numeric?("vancouver-superscript").must_equal true
    Styles.is_numeric?("vancouver-brackets").must_equal true
    Styles.is_numeric?("apa").must_equal false

  end
end
