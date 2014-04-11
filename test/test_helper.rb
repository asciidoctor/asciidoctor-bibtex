if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Minitest'
  end
end

require 'asciidoc-bib'
require 'minitest/autorun'

include AsciidocBib

