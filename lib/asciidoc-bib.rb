#  asciidoc-bib.rb
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

require 'bibtex'
require 'citeproc'
require 'csl/styles'
require 'set'

# Only require asciidoctor file if asciidoctor gem is installed
unless Gem::Specification.find_all_by_name('asciidoctor').empty?
  require_relative 'asciidoc-bib/asciidoctor'
end
require_relative 'asciidoc-bib/citation'
require_relative 'asciidoc-bib/citationdata'
require_relative 'asciidoc-bib/citationutils'
require_relative 'asciidoc-bib/citations'
require_relative 'asciidoc-bib/extensions'
require_relative 'asciidoc-bib/filehandlers'
require_relative 'asciidoc-bib/options'
require_relative 'asciidoc-bib/processorutils'
require_relative 'asciidoc-bib/processor'
require_relative 'asciidoc-bib/styles'
require_relative 'asciidoc-bib/version'
