# Test cases for extracting citations from lines of text
#
# Copyright (c) Peter Lane, 2012.
# Copyright (c) Zhang Yang, 2019.
# Released under Open Works License, 0.9.2

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/citation_macro'

include AsciidoctorBibtex

describe AsciidoctorBibtex do
  it 'should extract a simple citation from text' do
    cites = CitationMacro.extract_citations 'some text cite:[author12] more text'
    cites.size.must_equal 1
    cites[0].items[0].key.must_equal 'author12'
  end

  it 'should extract combinations of citations from text' do
    cites = CitationMacro.extract_citations 'some text cite:[author12,another11] more text'
    cites.size.must_equal 1
    cites[0].items.size.must_equal 2
    cites[0].items[0].key.must_equal 'author12'
    cites[0].items[1].key.must_equal 'another11'
  end

  it 'should extract separate groups of citations' do
    cites = CitationMacro.extract_citations 'some text cite:[author12,another11] more text cite:[third10]'
    cites.size.must_equal 2
    cites[0].items.size.must_equal 2
    cites[1].items.size.must_equal 1
    cites[0].items[0].key.must_equal 'author12'
    cites[0].items[1].key.must_equal 'another11'
    cites[1].items[0].key.must_equal 'third10'
  end

  it 'should extract citations with page numbers' do
    cites = CitationMacro.extract_citations 'some text citenp:[author12(1-20),another11(15)]'
    cites.size.must_equal 1
    cites.first.items.size.must_equal 2
    cites.first.items[0].key.must_equal 'author12'
    cites.first.items[0].locator.must_equal '1-20'
    cites.first.items[1].key.must_equal 'another11'
    cites.first.items[1].locator.must_equal '15'
    cites.first.items[0].to_s.must_equal 'author12:1-20'
  end

  it 'should extract page numbers as well as refs' do
    cites = CitationMacro.extract_citations 'citenp:[author12,another11(15-30),third10(14)]'
    cites.size.must_equal 1
    cites.first.items.size.must_equal 3
    cites.first.items[0].key.must_equal 'author12'
    cites.first.items[0].locator.must_equal ''
    cites.first.items[1].key.must_equal 'another11'
    cites.first.items[1].locator.must_equal '15-30'
    cites.first.items[2].key.must_equal 'third10'
    cites.first.items[2].locator.must_equal '14'
  end

  it 'should work with dash in citation' do
    cites = CitationMacro.extract_citations 'cite:[some-author]'
    cites.size.must_equal 1
    cites.first.items[0].key.must_equal 'some-author'
  end
end
