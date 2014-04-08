# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'minitest/autorun'

include AsciidocBib

describe AsciidocBib do
  it "must return Chicago style references" do
    p = Processor.new BibTeX.open('test/data/test.bib'), false, 'chicago-author-date'
    p.get_reference('smith10').must_equal "Smith, D. 2010. _Book Title_. Mahwah, NJ: Lawrence Erlbaum."
    p.get_reference('brown09').must_equal "Brown, J., ed. 2009. _Book Title_. OUP."
  end

  it "must return numeric style (IEEE) references" do
    p = Processor.new BibTeX.open('test/data/test.bib'), false, 'ieee'
    p.get_reference('smith10').must_equal ". D. Smith, _Book title_. Mahwah, NJ: Lawrence Erlbaum, 2010."
    p.get_reference('brown09').must_equal ". J. Brown, Ed., _Book title_. OUP, 2009."
  end

  it "must return harvard style (APA) references" do
    p = Processor.new BibTeX.open('test/data/test.bib'), false, 'apa'
    p.get_reference('smith10').must_equal "Smith, D. (2010). _Book title_. Mahwah, NJ: Lawrence Erlbaum."
    p.get_reference('brown09').must_equal "Brown, J. (Ed.). (2009). _Book title_. OUP."
  end
end

