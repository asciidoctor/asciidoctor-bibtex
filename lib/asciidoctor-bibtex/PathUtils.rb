#
# PathUtils.rb
#
# High-level utilities for files.
#

module AsciidoctorBibtex
  module PathUtils
    # Locate a bibtex file to read in given dir
    def PathUtils.find_bibfile dir
      begin
        candidates = Dir.glob("#{dir}/*.bib")
        if candidates.empty?
          return ""
        else
          return candidates.first
        end
      rescue # catch all errors, and return empty string
        return ""
      end
    end
    def PathUtils.doBad
      return ""
    end
  end
end
