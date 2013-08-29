# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'bibtex'
require 'minitest/autorun'

include AsciidocBib

describe AsciidocBib do
  before do
    @biblio = BibTeX.open "test/data/test.bib"
  end

  it "must return Chicago style references" do
    cite = AsciidocBib.get_reference @biblio, "smith10", false, "chicago-author-date"
    cite.must_equal "Smith, D. 2010. _Book Title_. Mahwah, NJ: Lawrence Erlbaum."
    cite = AsciidocBib.get_reference @biblio, "brown09", false, "chicago-author-date"
    cite.must_equal "Brown, J., ed. 2009. _Book Title_. OUP."
  end

  it "must return numeric style (IEEE) references" do
    cite = AsciidocBib.get_reference @biblio, "smith10", false, "ieee"
    cite.must_equal ".  D. Smith, _Book title_. Mahwah, NJ: Lawrence Erlbaum, 2010."
    cite = AsciidocBib.get_reference @biblio, "brown09", false, "ieee"
    cite.must_equal ".  J. Brown, Ed., _Book title_. OUP, 2009."
  end

  it "must return harvard style (APA) references" do
    cite = AsciidocBib.get_reference @biblio, "smith10", false, "apa"
    cite.must_equal "Smith, D. (2010). _Book title_. Mahwah, NJ: Lawrence Erlbaum."
    cite = AsciidocBib.get_reference @biblio, "brown09", false, "apa"
    cite.must_equal "Brown, J. (Ed.). (2009). _Book title_. OUP."
  end
end

