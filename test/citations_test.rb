# Test cases for extracting citations from lines of text
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'minitest/autorun'

include AsciidocBib

describe AsciidocBib do

  it "should extract a simple citation from text" do
    cites = extract_cites("some text [cite:author12] more text")
    cites.length.must_equal 1
    cites[0].must_equal "author12"
  end

  it "should extract combinations of citations from text" do 
    cites = extract_cites("some text [cite:author12;another11] more text")
    cites.length.must_equal 2
    cites[0].must_equal "author12"
    cites[1].must_equal "another11"
  end

  it "should extract separate groups of citations" do
    cites = extract_cites("some text [cite:author12;another11] more text [cite:third10]")
    cites.length.must_equal 3
    cites[0].must_equal "author12"
    cites[1].must_equal "another11"
    cites[2].must_equal "third10"
  end

  it "should extract citations with page numbers" do
    cites = extract_cites("some text [citenp:author12,1-20;another11,15]")
    cites.length.must_equal 2
    cites[0].must_equal "author12"
    cites[1].must_equal "another11"
  end

  it "should extract page numbers as well as refs" do
    refs, pages = extract_refs_pages("author12;another11,15-30;third10,14")
    refs.length.must_equal 3
    pages.length.must_equal 3
    refs[0].must_equal "author12"
    refs[1].must_equal "another11"
    refs[2].must_equal "third10"
    pages[0].must_be_nil
    pages[1].must_equal "15-30"
    pages[2].must_equal "14"
  end
end
