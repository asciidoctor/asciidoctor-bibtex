#
# test_PathUtils
#
# Test cases for PathUtils
#
# Copyright (c) Peter Lane, 2012.
# Copyright (c) Zhang Yang, 2019.
#
# Released under Open Works License, 0.9.2
#

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/PathUtils'
include AsciidoctorBibtex

describe AsciidoctorBibtex do
  describe PathUtils do
    it 'should find biblio file' do
      PathUtils.find_bibfile('test/data').must_equal 'test/data/test.bib'
      PathUtils.find_bibfile('test').must_equal ''
    end
  end
end
