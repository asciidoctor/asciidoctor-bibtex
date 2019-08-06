# Test cases for file utilities
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require_relative 'helpers'
require_relative '../lib/asciidoctor-bibtex/FileUtils'

describe AsciidoctorBibtex do
  it "should find biblio file" do
    FileUtils.find_bibliography('test/data').must_equal 'test/data/test.bib'
    FileUtils.find_bibliography('test').must_equal ''
  end
end
