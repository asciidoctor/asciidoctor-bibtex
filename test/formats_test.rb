# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

require 'test_helper'

describe AsciidocBib do

  def check_complete_citation style, line, result, links = false
    p = Processor.new BibTeX.open('test/data/test.bib'), links, style
    p.citations.add_from_line line
    p.complete_citation(p.citations.retrieve_citations(line).first).must_equal result
  end

  it "must handle chicago style references with 'cite'" do
    check_complete_citation 'chicago-author-date', '[cite:smith10]', '(Smith 2010)'
    check_complete_citation 'chicago-author-date', '[cite:see:smith10]', '(see Smith 2010)'
    check_complete_citation 'chicago-author-date', '[cite:smith10,11]', '(Smith 2010, 11)'
    check_complete_citation 'chicago-author-date', '[cite:see:smith10,11]', '(see Smith 2010, 11)'
  end

  it "must handle chicago style references with 'citenp'" do
    check_complete_citation 'chicago-author-date', '[citenp:smith10]', 'Smith (2010)'
    check_complete_citation 'chicago-author-date', '[citenp:see:smith10]', 'see Smith (2010)'
    check_complete_citation 'chicago-author-date', '[citenp:smith10,11]', 'Smith (2010, 11)'
    check_complete_citation 'chicago-author-date', '[citenp:see:smith10,11]', 'see Smith (2010, 11)'
  end

  it "must handle chicago style references with 'cite' and multiple authors" do
    check_complete_citation 'chicago-author-date', '[cite:jones11;smith10]', '(Jones 2011; Smith 2010)'
    check_complete_citation 'chicago-author-date', '[cite:see:jones11;smith10]', '(see Jones 2011; Smith 2010)'
    check_complete_citation 'chicago-author-date', '[cite:jones11;smith10,11]', '(Jones 2011; Smith 2010, 11)'
    check_complete_citation 'chicago-author-date', '[cite:see:jones11,11;smith10]', '(see Jones 2011, 11; Smith 2010)'
    check_complete_citation 'chicago-author-date', '[cite:see:jones11,11;smith10]', '(see <<jones11,Jones 2011&#44; 11>>; <<smith10,Smith 2010>>)', true
  end
  
  it "must handle chicago style references with 'citenp' and multiple authors" do 
    check_complete_citation 'chicago-author-date', '[citenp:jones11;smith10]', 'Jones (2011); Smith (2010)'
    check_complete_citation 'chicago-author-date', '[citenp:see:jones11;smith10]', 'see Jones (2011); Smith (2010)'
    check_complete_citation 'chicago-author-date', '[citenp:jones11;smith10,11]', 'Jones (2011); Smith (2010, 11)'
    check_complete_citation 'chicago-author-date', '[citenp:see:jones11;smith10,11]', 'see Jones (2011); Smith (2010, 11)'
  end

  it "must handle numeric references with 'cite'" do
    check_complete_citation 'ieee', '[cite:smith10]', '[1]'
    check_complete_citation 'ieee', '[cite:see:smith10]', 'see [1]'
    check_complete_citation 'ieee', '[cite:smith10,11]', '[1 p.&#160;11]'
    check_complete_citation 'ieee', '[cite:see:smith10,11]', 'see [1 p.&#160;11]'
    check_complete_citation 'ieee', '[cite:see:smith10,11-13]', 'see [1 pp.&#160;11-13]'
  end
  
  it "must handle numeric references with 'citenp'" do
    check_complete_citation 'ieee', '[citenp:smith10]', '[1]'
    check_complete_citation 'ieee', '[citenp:see:smith10]', 'see [1]'
    check_complete_citation 'ieee', '[citenp:smith10,11]', '[1 p.&#160;11]'
    check_complete_citation 'ieee', '[citenp:see:smith10,11]', 'see [1 p.&#160;11]'
  end

  it "must handle numeric references with 'cite' and multiple authors" do
    check_complete_citation 'ieee', '[cite:jones11;smith10]', '[1, 2]'
    check_complete_citation 'ieee', '[cite:see:jones11;smith10]', 'see [1, 2]'
    check_complete_citation 'ieee', '[cite:jones11;smith10,11]', '[1, 2 p.&#160;11]'
    check_complete_citation 'ieee', '[cite:see:jones11,11;smith10]', 'see [1 p.&#160;11, 2]'
    # -- with links
    check_complete_citation 'ieee', '[cite:see:jones11,11;smith10]', 'see [<<jones11,1 p.&#160;11>>, <<smith10,2>>]', true
  end
  
  it "must handle numeric references with 'citenp' and multiple authors" do
    check_complete_citation 'ieee', '[citenp:jones11;smith10]', '[1, 2]'
    check_complete_citation 'ieee', '[citenp:see:jones11;smith10]', 'see [1, 2]'
    check_complete_citation 'ieee', '[citenp:jones11;smith10,11]', '[1, 2 p.&#160;11]'
    check_complete_citation 'ieee', '[citenp:see:jones11,11;smith10]', 'see [1 p.&#160;11, 2]'
  end

  it "must handle harvard style references with 'cite'" do
    check_complete_citation 'apa', '[cite:smith10]', '(Smith, 2010)'
    check_complete_citation 'apa', '[cite:see:smith10]', '(see Smith, 2010)'
    check_complete_citation 'apa', '[cite:smith10,11]', '(Smith, 2010, p.&#160;11)'
    check_complete_citation 'apa', '[cite:see:smith10,11]', '(see Smith, 2010, p.&#160;11)'
    check_complete_citation 'apa', '[cite:see:smith10,11-13]', '(see Smith, 2010, pp.&#160;11-13)'
  end

  it "must handle harvard style references with 'citenp'" do
    check_complete_citation 'apa', '[citenp:smith10]', 'Smith (2010)'
    check_complete_citation 'apa', '[citenp:see:smith10]', 'see Smith (2010)'
    check_complete_citation 'apa', '[citenp:smith10,11]', 'Smith (2010, p.&#160;11)'
    check_complete_citation 'apa', '[citenp:see:smith10,11]', 'see Smith (2010, p.&#160;11)'
  end
  
  it "must handle harvard style references with 'cite' and multiple authors" do
    check_complete_citation 'apa', '[cite:jones11;smith10]', '(Jones, 2011; Smith, 2010)'
    check_complete_citation 'apa', '[cite:see:jones11;smith10]', '(see Jones, 2011; Smith, 2010)'
    check_complete_citation 'apa', '[cite:jones11;smith10,11]', '(Jones, 2011; Smith, 2010, p.&#160;11)'
    check_complete_citation 'apa', '[cite:see:jones11,11;smith10]', '(see Jones, 2011, p.&#160;11; Smith, 2010)'
    check_complete_citation 'apa', '[cite:see:jones11,11;smith10]', '(see <<jones11,Jones&#44; 2011&#44; p.&#160;11>>; <<smith10,Smith&#44; 2010>>)', true
  end
  
  it "must handle harvard style references with 'citenp' and multiple authors" do
    check_complete_citation 'apa', '[citenp:jones11;smith10]', 'Jones (2011); Smith (2010)'
    check_complete_citation 'apa', '[citenp:see:jones11;smith10]', 'see Jones (2011); Smith (2010)'
    check_complete_citation 'apa', '[citenp:jones11;smith10,11]', 'Jones (2011); Smith (2010, p.&#160;11)'
    check_complete_citation 'apa', '[citenp:see:jones11,11;smith10]', 'see Jones (2011, p.&#160;11); Smith (2010)'
  end
  
  it "must handle references with no author but editor in biblio entry" do
    check_complete_citation 'chicago-author-date', '[cite:brown09]', '(Brown 2009)'
  end

  it "must combine numeric references, e.g. [1, 2, 3] -> [1-3]" do
    check_complete_citation 'ieee', '[cite:brown09;jones11;smith10]', '[1-3]'
  end

  it "provides method to combine consecutive numbers" do
    p = Processor.new BibTeX.open('test/data/test.bib'), nil, :apa
    p.combine_consecutive_numbers("1,2,3").must_equal "1-3"
    p.combine_consecutive_numbers("1,2,3,5,7,8,9,12").must_equal "1-3, 5, 7-9, 12"
  end
end

