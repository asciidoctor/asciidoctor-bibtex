# Test cases for file utilities
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'test_helper'

describe AsciidocBib do
  it "should add ref to end of filename" do
    FileHandlers.add_ref('/tmp/example.txt').must_equal '/tmp/example-ref.txt'
  end

  it "should find biblio file" do
    FileHandlers.find_bibliography('test/data').must_equal 'test/data/test.bib'
    FileHandlers.find_bibliography('test').must_equal ''
  end
end
