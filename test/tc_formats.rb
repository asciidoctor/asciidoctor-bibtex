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
  # -- with 'cite'
  def test_1
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      "authoryear", ["smith10"])
    assert_equal("(Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      "authoryear", ["smith10"])
    assert_equal("(see Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      "authoryear", ["smith10"])
    assert_equal("(Smith 2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      "authoryear", ["smith10"])
    assert_equal("(see Smith 2010, 11)", cite)
  end
  # -- with 'citenp'
  def test_2
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      "authoryear", ["smith10"])
    assert_equal("Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      "authoryear", ["smith10"])
    assert_equal("see Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      "authoryear", ["smith10"])
    assert_equal("Smith (2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      "authoryear", ["smith10"])
    assert_equal("see Smith (2010, 11)", cite)
  end
  # -- with 'cite' and multiple authors
  def test_3
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("(Jones 2011; Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("(see Jones 2011; Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("(Jones 2011; Smith 2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("(see Jones 2011, 11; Smith 2010)", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_4
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("see Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("Jones (2011); Smith (2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      "authoryear", ["jones11", "smith10"])
    assert_equal("see Jones (2011, 11); Smith (2010)", cite)
  end
  # check numeric references
  # -- with 'cite'
  def test_5
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      "numeric", ["smith10"])
    assert_equal("[1]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      "numeric", ["smith10"])
    assert_equal("see [1]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      "numeric", ["smith10"])
    assert_equal("[1 p.11]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      "numeric", ["smith10"])
    assert_equal("see [1 p.11]", cite)
  end
  # -- with 'citenp'
  def test_6
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      "numeric", ["smith10"])
    assert_equal("[1]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      "numeric", ["smith10"])
    assert_equal("see [1]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      "numeric", ["smith10"])
    assert_equal("[1 p.11]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      "numeric", ["smith10"])
    assert_equal("see [1 p.11]", cite)  end
  # -- with 'cite' and multiple authors
  def test_7
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("[1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("see [1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      "numeric", ["jones11", "smith10"])
    assert_equal("[1, 2 p.11]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("see [1 p.11, 2]", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_8
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("[1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("see [1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      "numeric", ["jones11", "smith10"])
    assert_equal("[1, 2 p.11]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      "numeric", ["jones11", "smith10"])
    assert_equal("see [1 p.11, 2]", cite)
  end

  # check harvard style references
  # -- with 'cite'
  def test_9
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      "authoryear:harvard", ["smith10"])
    assert_equal("(Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      "authoryear:harvard", ["smith10"])
    assert_equal("(see Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      "authoryear:harvard", ["smith10"])
    assert_equal("(Smith, 2010, p.11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      "authoryear:harvard", ["smith10"])
    assert_equal("(see Smith, 2010, p.11)", cite)
  end
  # -- with 'citenp'
  def test_10
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      "authoryear:harvard", ["smith10"])
    assert_equal("Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      "authoryear:harvard", ["smith10"])
    assert_equal("see Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      "authoryear:harvard", ["smith10"])
    assert_equal("Smith (2010, p.11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      "authoryear:harvard", ["smith10"])
    assert_equal("see Smith (2010, p.11)", cite)
  end
  # -- with 'cite' and multiple authors
  def test_11
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("(Jones, 2011; Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("(see Jones, 2011; Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("(Jones, 2011; Smith, 2010, p.11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("(see Jones, 2011, p.11; Smith, 2010)", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_12
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("see Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("Jones (2011); Smith (2010, p.11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      "authoryear:harvard", ["jones11", "smith10"])
    assert_equal("see Jones (2011, p.11); Smith (2010)", cite)
  end
end

