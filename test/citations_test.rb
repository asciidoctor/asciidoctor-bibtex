# Test cases for extracting citations from lines of text
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib'
require 'minitest/autorun'

include AsciidocBib

describe AsciidocBib do

  it "should extract a simple citation from text" do
    cites = Citations.new
    cites.add_from_line "some text [cite:author12] more text"
    cites.size.must_equal 1
    cites.to_a[0].ref.must_equal "author12"
  end

  it "should extract combinations of citations from text" do 
    cites = Citations.new
    cites.add_from_line "some text [cite:author12;another11] more text"
    cites.size.must_equal 2
    cites.to_a[0].ref.must_equal "author12"
    cites.to_a[1].ref.must_equal "another11"
  end

  it "should extract separate groups of citations" do
    cites = Citations.new
    cites.add_from_line "some text [cite:author12;another11] more text [cite:third10]"
    cites.size.must_equal 3
    cites.to_a[0].ref.must_equal "author12"
    cites.to_a[1].ref.must_equal "another11"
    cites.to_a[2].ref.must_equal "third10"
  end

  it "should extract citations with page numbers" do
    cites = Citations.new
    cites.add_from_line "some text [citenp:author12,1-20;another11,15]"
    cites.size.must_equal 2
    cites.to_a[0].ref.must_equal "author12"
    cites.to_a[0].pages.must_equal "1-20"
    cites.to_a[1].ref.must_equal "another11"
    cites.to_a[1].pages.must_equal "15"
  end

  it "should extract page numbers as well as refs" do
    cites = Citations.new
    cites.add_from_line "[citenp:author12;another11,15-30;third10,14]"
    cites.size.must_equal 3
    cites.to_a[0].ref.must_equal "author12"
    cites.to_a[0].pages.must_be_nil
    cites.to_a[1].ref.must_equal "another11"
    cites.to_a[1].pages.must_equal "15-30"
    cites.to_a[2].ref.must_equal "third10"
    cites.to_a[2].pages.must_equal "14"
  end
end
