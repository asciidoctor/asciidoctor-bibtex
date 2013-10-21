# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'bibtex'
require 'minitest/autorun'

include AsciidocBib
exit 

describe AsciidocBib do

  let(:biblio) { BibTeX.open "test/data/test.bib" }

  it "must handle chicago style references with 'cite'" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "(Smith 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "(see Smith 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "(Smith 2010, 11)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "(see Smith 2010, 11)"
  end

  it "must handle chicago style references with 'citenp'" do
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "see Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "Smith (2010, 11)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "chicago-author-date"
    cite.must_equal "see Smith (2010, 11)"
  end

  it "must handle chicago style references with 'cite' and multiple authors" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "(Jones 2011; Smith 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
     false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "(see Jones 2011; Smith 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "(Jones 2011; Smith 2010, 11)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "(see Jones 2011, 11; Smith 2010)"
    # -- with links
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "(see <<jones11,Jones 2011&#44; 11>>; <<smith10,Smith 2010>>)"
  end

  it "must handle chicago style references with 'citenp' and multiple authors" do 
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "Jones (2011); Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "see Jones (2011); Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "Jones (2011); Smith (2010, 11)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "chicago-author-date"
    cite.must_equal "see Jones (2011, 11); Smith (2010)"
  end

  it "must handle numeric references with 'cite'" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "ieee"
    cite.must_equal "[1]"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "ieee"
    cite.must_equal "see [1]"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "ieee"
    cite.must_equal "[1 p.&#160;11]"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "ieee"
    cite.must_equal "see [1 p.&#160;11]"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], ["11-13"], 
      false, ["smith10"], "ieee"
    cite.must_equal "see [1 pp.&#160;11-13]"
  end
  
  it "must handle numeric references with 'citenp'" do
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "ieee"
    cite.must_equal "[1]"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "ieee"
    cite.must_equal "see [1]"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "ieee"
    cite.must_equal "[1 p.&#160;11]"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "ieee"
    cite.must_equal "see [1 p.&#160;11]"  end

  it "must handle numeric references with 'cite' and multiple authors" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "[1, 2]"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "see [1, 2]"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "[1, 2 p.&#160;11]"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "see [1 p.&#160;11, 2]"
    # -- with links
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "ieee"
    cite.must_equal "see [<<jones11,1 p.&#160;11>>, <<smith10,2>>]"
  end
  
  it "must handle numeric references with 'citenp' and multiple authors" do
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "[1, 2]"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "see [1, 2]"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "[1, 2 p.&#160;11]"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "ieee"
    cite.must_equal "see [1 p.&#160;11, 2]"
  end

  it "must handle harvard style references with 'cite'" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], [nil], 
      false, ["smith10"], "apa"
    cite.must_equal "(Smith, 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], [nil], 
      false, ["smith10"], "apa"
    cite.must_equal "(see Smith, 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["smith10"], ["11"], 
      false, ["smith10"], "apa"
    cite.must_equal "(Smith, 2010, p.&#160;11)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], ["11"], 
      false, ["smith10"], "apa"
    cite.must_equal "(see Smith, 2010, p.&#160;11)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["smith10"], ["11-13"], 
      false, ["smith10"], "apa"
    cite.must_equal "(see Smith, 2010, pp.&#160;11-13)"
  end

  it "must handle harvard style references with 'citenp'" do
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], [nil], 
      false, ["smith10"], "apa"
    cite.must_equal "Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], [nil], 
      false, ["smith10"], "apa"
    cite.must_equal "see Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["smith10"], ["11"], 
      false, ["smith10"], "apa"
    cite.must_equal "Smith (2010, p.&#160;11)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["smith10"], ["11"], 
      false, ["smith10"], "apa"
    cite.must_equal "see Smith (2010, p.&#160;11)"
  end
  
  it "must handle harvard style references with 'cite' and multiple authors" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "(Jones, 2011; Smith, 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "(see Jones, 2011; Smith, 2010)"
    cite = AsciidocBib.get_citation biblio, "cite", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "(Jones, 2011; Smith, 2010, p.&#160;11)"
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "(see Jones, 2011, p.&#160;11; Smith, 2010)"
    # -- with links
    cite = AsciidocBib.get_citation biblio, "cite", "see", ["jones11", "smith10"], ["11", nil], 
      true, ["jones11", "smith10"], "apa"
    cite.must_equal "(see <<jones11,Jones&#44; 2011&#44; p.&#160;11>>; <<smith10,Smith&#44; 2010>>)"
  end
  
  it "must handle harvard style references with 'citenp' and multiple authors" do
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "Jones (2011); Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], [nil, nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "see Jones (2011); Smith (2010)"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["jones11", "smith10"], [nil, "11"], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "Jones (2011); Smith (2010, p.&#160;11)"
    cite = AsciidocBib.get_citation biblio, "citenp", "see", ["jones11", "smith10"], ["11", nil], 
      false, ["jones11", "smith10"], "apa"
    cite.must_equal "see Jones (2011, p.&#160;11); Smith (2010)"
  end
  
  it "must handle references with no author but editor in biblio entry" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["brown09"], [nil],
                                    false, ["brown09"], "chicago-author-date"
    cite.must_equal "(Brown 2009)"
  end

  it "must handle citeproc styles" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["brown09"], [nil],
                                    false, ["brown09"], "apa"
    cite.must_equal "(Brown, 2009)"
    cite = AsciidocBib.get_citation biblio, "cite", "See", ["brown09"], [nil],
                                    false, ["brown09"], "apa"
    cite.must_equal "(See Brown, 2009)"
    cite = AsciidocBib.get_citation biblio, "citenp", "", ["brown09"], [nil],
                                    false, ["brown09"], "apa"
    cite.must_equal "Brown (2009)"
  end
  
  it "must combine numeric references, e.g. [1, 2, 3] -> [1-3]" do
    cite = AsciidocBib.get_citation biblio, "cite", "", ["brown09", "jones11", "smith10"], [nil, nil], false, ["brown09", "jones11", "smith10"], "ieee"
    cite.must_equal "[1-3]"
  end

  it "provides method to combine consecutive numbers" do
    combine_consecutive_numbers("1,2,3").must_equal "1-3"
    combine_consecutive_numbers("1,2,3,5,7,8,9,12").must_equal "1-3, 5, 7-9, 12"
  end
end

