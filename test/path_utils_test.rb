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
require_relative '../lib/asciidoctor-bibtex/path_utils'
include AsciidoctorBibtex

describe AsciidoctorBibtex do
  describe PathUtils do
    it 'should find biblio file' do
      PathUtils.find_bibfile('test/data').wont_be_empty
      PathUtils.find_bibfile('test/data').must_match %r/test\/data\/.+\.bib$/
      PathUtils.find_bibfile('test').must_be_empty
    end
  end
end
