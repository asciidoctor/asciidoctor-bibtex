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
  require 'asciidoc-bib/asciidoctor'
end
require 'asciidoc-bib/citation'
require 'asciidoc-bib/citationdata'
require 'asciidoc-bib/citationutils'
require 'asciidoc-bib/citations'
require 'asciidoc-bib/extensions'
require 'asciidoc-bib/filehandlers'
require 'asciidoc-bib/options'
require 'asciidoc-bib/processorutils'
require 'asciidoc-bib/processor'
require 'asciidoc-bib/styles'
require 'asciidoc-bib/version'
