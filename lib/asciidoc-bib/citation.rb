# citation class
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

module AsciidocBib
  # Class to hold information about a single citation:
  # its reference and any page numbers
  class Citation
    attr_reader :ref, :pages

    def initialize ref, pages
      @ref = ref
      @pages = pages
      # clean up pages
      @pages = '' unless @pages
      @pages.gsub!("--","-") unless @pages.nil?
    end

    def == other
      @ref == other.ref && @pages == other.pages
    end
  end
end

