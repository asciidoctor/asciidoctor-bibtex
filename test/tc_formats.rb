# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'test/unit'
require 'bibtex'

include AsciidocBib

class TestReferenceFormat < Test::Unit::TestCase
  # check chicago style references
  # -- with 'cite'
  def test_1
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("(Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("(see Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("(Smith 2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("(see Smith 2010, 11)", cite)
  end
  # -- with 'citenp'
  def test_2
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("see Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("Smith (2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date")
    assert_equal("see Smith (2010, 11)", cite)
  end
  # -- with 'cite' and multiple authors
  def test_3
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("(Jones 2011; Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
     false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("(see Jones 2011; Smith 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("(Jones 2011; Smith 2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("(see Jones 2011, 11; Smith 2010)", cite)
    # -- with links
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("(see <<jones11,Jones 2011&#44; 11>>; <<smith10,Smith 2010>>)", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_4
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("see Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("Jones (2011); Smith (2010, 11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "chicago-author-date")
    assert_equal("see Jones (2011, 11); Smith (2010)", cite)
  end
  # check numeric references
  # -- with 'cite'
  def test_5
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "ieee")
    assert_equal("[1]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "ieee")
    assert_equal("see [1]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "ieee")
    assert_equal("[1 p.&#160;11]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "ieee")
    assert_equal("see [1 p.&#160;11]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11-13"], 
      false, ["smith10"], "ieee")
    assert_equal("see [1 pp.&#160;11-13]", cite)
  end
  # -- with 'citenp'
  def test_6
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "ieee")
    assert_equal("[1]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "ieee")
    assert_equal("see [1]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "ieee")
    assert_equal("[1 p.&#160;11]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "ieee")
    assert_equal("see [1 p.&#160;11]", cite)  end
  # -- with 'cite' and multiple authors
  def test_7
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("[1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("see [1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("[1, 2 p.&#160;11]", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("see [1 p.&#160;11, 2]", cite)
    # -- with links
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "ieee")
    assert_equal("see [<<jones11,1 p.&#160;11>>, <<smith10,2>>]", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_8
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("[1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("see [1, 2]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("[1, 2 p.&#160;11]", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "ieee")
    assert_equal("see [1 p.&#160;11, 2]", cite)
  end

  # check harvard style references
  # -- with 'cite'
  def test_9
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "apa")
    assert_equal("(Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "apa")
    assert_equal("(see Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "apa")
    assert_equal("(Smith, 2010, p.&#160;11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "apa")
    assert_equal("(see Smith, 2010, p.&#160;11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["smith10"], ["11-13"], 
      false, ["smith10"], "apa")
    assert_equal("(see Smith, 2010, pp.&#160;11-13)", cite)
  end
  # -- with 'citenp'
  def test_10
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "apa")
    assert_equal("Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "apa")
    assert_equal("see Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "apa")
    assert_equal("Smith (2010, p.&#160;11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "apa")
    assert_equal("see Smith (2010, p.&#160;11)", cite)
  end
  # -- with 'cite' and multiple authors
  def test_11
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("(Jones, 2011; Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("(see Jones, 2011; Smith, 2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("(Jones, 2011; Smith, 2010, p.&#160;11)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("(see Jones, 2011, p.&#160;11; Smith, 2010)", cite)
    # -- with links
    cite = AsciidocBib.get_citation(biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "apa")
    assert_equal("(see <<jones11,Jones&#44; 2011&#44; p.11>>; <<smith10,Smith&#44; 2010>>)", cite)
  end
  # -- with 'citenp' and multiple authors
  def test_12
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("see Jones (2011); Smith (2010)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("Jones (2011); Smith (2010, p.&#160;11)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "apa")
    assert_equal("see Jones (2011, p.&#160;11); Smith (2010)", cite)
  end
  # -- with no author but editor in biblio entry
  def test_13
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["brown09"], [nil],
                                    false, ["brown09"], "chicago-author-date")
    assert_equal("(Brown 2009)", cite)
  end
  # -- with citeproc styles
  def test_14
    biblio = BibTeX.open("test.bib")
    cite = AsciidocBib.get_citation(biblio, "cite", "", ["brown09"], [nil],
                                    false, ["brown09"], "apa")
    assert_equal("(Brown, 2009)", cite)
    cite = AsciidocBib.get_citation(biblio, "cite", "See", ["brown09"], [nil],
                                    false, ["brown09"], "apa")
    assert_equal("(See Brown, 2009)", cite)
    cite = AsciidocBib.get_citation(biblio, "citenp", "", ["brown09"], [nil],
                                    false, ["brown09"], "apa")
    assert_equal("Brown (2009)", cite)
  end
end

