#
# PathUtils.rb
#
# High-level utilities for files.
#

module AsciidoctorBibtex
  module PathUtils
    # Locate a bibtex file to read in given dir
    def self.find_bibfile(dir)
      candidates = Dir.glob("#{dir}/*.bib")
      if candidates.empty?
        return ''
      else
        return candidates.first
      end
    rescue StandardError # catch all errors, and return empty string
      ''
    end

    def self.doBad
      ''
    end
  end
end
