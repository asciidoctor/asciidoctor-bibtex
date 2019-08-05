# Test cases for file utilities
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require_relative 'helpers'

describe AsciidoctorBibtex do
  it "should find biblio file" do
    FileHandlers.find_bibliography('test/data').must_equal 'test/data/test.bib'
    FileHandlers.find_bibliography('test').must_equal ''
  end
end
