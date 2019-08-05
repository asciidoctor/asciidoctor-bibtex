#
# filehandlers.rb
#
# Contains top-level file utility methods
#

module AsciidoctorBibtex

  module FileUtils
    # Locate a bibliography file to read in given dir
    def FileUtils.find_bibliography dir
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

  end
end
