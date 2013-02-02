# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib/extensions'
require 'test/unit'
require 'bibtex'

include AsciidocBib

class TestReferenceFormat < Test::Unit::TestCase
  # check chicago style references
  def test_1
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "smith10", false, "authoryear")
    assert_equal("Smith, D. 2010. _Book title_, Mahwah, NJ: Lawrence Erlbaum.", cite)
  end
  def test_2
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "brown09", false, "authoryear")
    assert_equal("Brown, J. (ed.) 2009. _Book title_, OUP.", cite)
  end
  
  # check numeric style references
  def test_11
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "smith10", false, "numeric")
    assert_equal(". D. Smith, _Book title_, Mahwah, NJ: Lawrence Erlbaum, 2010.", cite)
  end
  def test_12
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "brown09", false, "numeric")
    assert_equal(". J. Brown (ed.), _Book title_, OUP, 2009.", cite)
  end

    # check harvard style references
  def test_21
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "smith10", false, "authoryear:harvard")
    assert_equal("Smith, D. (2010). _Book title_, Mahwah, NJ: Lawrence Erlbaum.", cite)
  end
  def test_22
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_reference(biblio, "brown09", false, "authoryear:harvard")
    assert_equal("Brown, J. (ed.) (2009). _Book title_, OUP.", cite)
  end
end

