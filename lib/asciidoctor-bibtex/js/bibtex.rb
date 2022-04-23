module AsciidoctorBibtex
  module BibTeX
    def self.open(file, options = {})
      return Bibliography.new()
    end

    class Bibliography
      def to_citeproc(options = {})
      end
    end
  end
end