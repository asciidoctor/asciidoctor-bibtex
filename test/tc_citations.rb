# Test cases for extracting citations from lines of text
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib/extensions'
require 'test/unit'

include AsciidocBib

class TestCitations < Test::Unit::TestCase
  def test_1
    cites = extract_cites("some text [cite:author12] more text")
    assert_equal(1, cites.length)
    assert_equal("author12", cites[0])
  end

  def test_2
    cites = extract_cites("some text [cite:author12;another11] more text")
    assert_equal(2, cites.length)
    assert_equal("author12", cites[0])
    assert_equal("another11", cites[1])
  end

  def test_3
    cites = extract_cites("some text [cite:author12;another11] more text [cite:third10]")
    assert_equal(3, cites.length)
    assert_equal("author12", cites[0])
    assert_equal("another11", cites[1])
    assert_equal("third10", cites[2])
  end

  def test_4
    cites = extract_cites("some text [citenp:author12,1-20;another11,15]")
    assert_equal(2, cites.length)
    assert_equal("author12", cites[0])
    assert_equal("another11", cites[1])
  end

  def test_5
    refs, pages = extract_refs_pages("author12;another11,15-30;third10,14")
    assert_equal(3, refs.length)
    assert_equal(3, pages.length)
    assert_equal("author12", refs[0])
    assert_equal("another11", refs[1])
    assert_equal("third10", refs[2])
    assert_equal(nil, pages[0])
    assert_equal("15-30", pages[1])
    assert_equal("14", pages[2])
  end
end
