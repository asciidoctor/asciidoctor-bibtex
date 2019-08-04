#  asciidoctor-bibtex.rb
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

require 'bibtex'
require 'citeproc'
require 'csl/styles'
require 'set'

# Requires utils first since it monkey-patches string and array.
require_relative 'asciidoctor-bibtex/utils'

require_relative 'asciidoctor-bibtex/extensions_impl'
require_relative 'asciidoctor-bibtex/citation'
require_relative 'asciidoctor-bibtex/citationdata'
require_relative 'asciidoctor-bibtex/citationutils'
require_relative 'asciidoctor-bibtex/citations'
require_relative 'asciidoctor-bibtex/filehandlers'
require_relative 'asciidoctor-bibtex/processorutils'
require_relative 'asciidoctor-bibtex/processor'
require_relative 'asciidoctor-bibtex/styles'
require_relative 'asciidoctor-bibtex/version'
