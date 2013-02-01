# Test cases for extensions code
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require 'asciidoc-bib/extensions'
require 'test/unit'

include AsciidocBib

class TestAuthorSplit < Test::Unit::TestCase
  def test_1
    names = author_chicago("Lane, P.C.R. and Gobet, F.")
    assert_equal(2, names.length)
    assert_equal("Lane, P.C.R.", names[0])
    assert_equal("Gobet, F.", names[1])
    assert_equal("Lane, P.C.R. and Gobet, F.", names.comma_and_join)
  end
  
  def test_2
    names = author_chicago("Lane, P.C.R. and Gobet, F. and Hovland, D. and Smith, E.")
    assert_equal(4, names.length)
    assert_equal("Lane, P.C.R.", names[0])
    assert_equal("Gobet, F.", names[1])
    assert_equal("Hovland, D.", names[2])
    assert_equal("Smith, E.", names[3])
    assert_equal("Lane, P.C.R., Gobet, F., Hovland, D. and Smith, E.", names.comma_and_join)
  end

  def test_3 
    names = author_chicago("Aristotle")
    assert_equal(1, names.length)
    assert_equal("Aristotle", names[0])
    assert_equal("Aristotle", names.comma_and_join)
  end

  def test_4
    names = author_surnames("Lane, P.C.R. and Gobet, F. and Hovland, D. and Smith, E.")
    assert_equal(4, names.length)
    assert_equal("Lane", names[0])
    assert_equal("Gobet", names[1])
    assert_equal("Hovland", names[2])
    assert_equal("Smith", names[3])
  end
end

class TestStringExtension < Test::Unit::TestCase
  def test_1
    assert_equal("two names", "{two names}".delatex)
  end
  
  def test_2
    e1 = ["00c9".to_i(16)].pack("U*")
    e2 = ["00e9".to_i(16)].pack("U*")
    assert_equal("Champs-#{e1}lys#{e2}e", 'Champs-\\\'{E}lys\\\'{e}e'.delatex)
  end
end
