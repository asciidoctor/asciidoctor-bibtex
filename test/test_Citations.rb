# Test cases for extracting citations from lines of text
#
# Copyright (c) Peter Lane, 2012.
# Copyright (c) Zhang Yang, 2019.
# Released under Open Works License, 0.9.2

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/Citations'

include AsciidoctorBibtex

describe AsciidoctorBibtex do

  it "should extract a simple citation from text" do
    cites = Citations.new
    cites.add_from_line "some text cite:[author12] more text"
    cites.cites_used.size.must_equal 1
    cites.cites_used[0].must_equal "author12"
  end

  it "should extract combinations of citations from text" do 
    cites = Citations.new
    cites.add_from_line "some text cite:[author12,another11] more text"
    cites.cites_used.size.must_equal 2
    cites.cites_used[0].must_equal "author12"
    cites.cites_used[1].must_equal "another11"
  end

  it "should extract separate groups of citations" do
    cites = Citations.new
    cites.add_from_line "some text cite:[author12,another11] more text cite:[third10]"
    cites.cites_used.size.must_equal 3
    cites.cites_used[0].must_equal "author12"
    cites.cites_used[1].must_equal "another11"
    cites.cites_used[2].must_equal "third10"
  end

  it "should extract citations with page numbers" do
    cites = Citations.new
    citationdata = cites.retrieve_citations "some text citenp:[author12(1-20),another11(15)]"
    citationdata.size.must_equal 1
    citationdata.first.cites.size.must_equal 2
    citationdata.first.cites[0].ref.must_equal "author12"
    citationdata.first.cites[0].pages.must_equal "1-20"
    citationdata.first.cites[1].ref.must_equal "another11"
    citationdata.first.cites[1].pages.must_equal "15"
    citationdata.first.cites[0].to_s.must_equal 'author12:1-20'
  end

  it "should extract page numbers as well as refs" do
    cites = Citations.new
    citationdata = cites.retrieve_citations "citenp:[author12,another11(15-30),third10(14)]"
    citationdata.size.must_equal 1
    citationdata.first.cites.size.must_equal 3
    citationdata.first.cites[0].ref.must_equal "author12"
    citationdata.first.cites[0].pages.must_equal ''
    citationdata.first.cites[1].ref.must_equal "another11"
    citationdata.first.cites[1].pages.must_equal "15-30"
    citationdata.first.cites[2].ref.must_equal "third10"
    citationdata.first.cites[2].pages.must_equal "14"
  end

  it "should keep each citation once only" do
    cites = Citations.new
    cites.add_from_line "citenp:[author12,another11,author12]"
    cites.cites_used.size.must_equal 2
  end

  it 'should work with dash in citation' do
    cites = Citations.new
    cites.add_from_line "cite:[some-author]"
    cites.cites_used.size.must_equal 1
    cites.cites_used[0].must_equal 'some-author'
  end
end
