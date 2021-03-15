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
    cites = CitationMacro.extract_macros 'some text cite:[author12] more text'
    _(cites.size).must_equal 1
    _(cites[0].items[0].key).must_equal 'author12'
  end

  it 'should extract combinations of citations from text' do
    cites = CitationMacro.extract_macros 'some text cite:[author12,another11] more text'
    _(cites.size).must_equal 1
    _(cites[0].items.size).must_equal 2
    _(cites[0].items[0].key).must_equal 'author12'
    _(cites[0].items[1].key).must_equal 'another11'
  end

  it 'should extract separate groups of citations' do
    cites = CitationMacro.extract_macros 'some text cite:[author12,another11] more text cite:[third10]'
    _(cites.size).must_equal 2
    _(cites[0].items.size).must_equal 2
    _(cites[1].items.size).must_equal 1
    _(cites[0].items[0].key).must_equal 'author12'
    _(cites[0].items[1].key).must_equal 'another11'
    _(cites[1].items[0].key).must_equal 'third10'
  end

  it 'should extract citations with page numbers' do
    cites = CitationMacro.extract_macros 'some text citenp:[author12(1-20),another11(15)]'
    _(cites.size).must_equal 1
    _(cites.first.items.size).must_equal 2
    _(cites.first.items[0].key).must_equal 'author12'
    _(cites.first.items[0].locator).must_equal '1-20'
    _(cites.first.items[1].key).must_equal 'another11'
    _(cites.first.items[1].locator).must_equal '15'
    _(cites.first.items[0].to_s).must_equal 'author12:1-20'
  end

  it 'should extract page numbers as well as refs' do
    cites = CitationMacro.extract_macros 'citenp:[author12,another11(15-30),third10(14)]'
    _(cites.size).must_equal 1
    _(cites.first.items.size).must_equal 3
    _(cites.first.items[0].key).must_equal 'author12'
    _(cites.first.items[0].locator).must_equal ''
    _(cites.first.items[1].key).must_equal 'another11'
    _(cites.first.items[1].locator).must_equal '15-30'
    _(cites.first.items[2].key).must_equal 'third10'
    _(cites.first.items[2].locator).must_equal '14'
  end

  it 'should work with dash in citation' do
    cites = CitationMacro.extract_macros 'cite:[some-author]'
    _(cites.size).must_equal 1
    _(cites.first.items[0].key).must_equal 'some-author'
  end
end
