#
# Class to hold and manage citations
#

module AsciidocBib
  class Citations
    def initialize
      @cites_used = []
      @cites_need_sorting = false
    end

    # Given a line of text, extract any citations and include new citations in current list
    def add_from_line line
      retrieve_citations(line).each do |citation|
        @cites_used += citation.cites
      end
      @cites_used.uniq!
      @cites_need_sorting = true
    end

    # Accessor to used citations - sorts citations before returning if necessary
    def cites_used
      if false # @cites_need_sorting
        @cites_used.sort_by! do |ref|
          unless @biblio[ref].nil?
            # extract the reference, and uppercase. 
            # Remove { } from grouped names for sorting.
            author = @biblio[ref].author
            if author.nil?
              author = @biblio[ref].editor
            end
            author_chicago(author).collect {|s| s.upcase.gsub("{","").gsub("}","")} + [@biblio[ref].year]
          else 
            [ref]
          end
        end
      end
      @cites_need_sorting = false

      return @cites_used
    end

    # Given a line, return a list of CitationData instances
    # containing information on each set of citation information
    def retrieve_citations line
      result = []
      md = CITATION_FULL.match line
      while md
        data = CitationData.new md[0], md[1], md[3], []
        cm = CITATION.match md[4]
        while cm
          data.cites << Citation.new(cm[1], cm[3])
          # look for next ref within citation
          cm = CITATION.match cm.post_match 
        end
        result << data
        # look for next citation on line
        md = CITATION_FULL.match md.post_match 
      end

      return result
    end


    private

    # matches a single ref with optional pages
    CITATION = /(\w+)(,([\w\.\- ]+))?/
      # matches complete citation with multiple references
      CITATION_FULL = /\[(cite|citenp):(([\w\-\;\!\? ]+):)?(#{CITATION}(;#{CITATION})*)\]/

      # -- utility functions

      # arrange author string, flag for order of surname/initials
      def arrange_authors(authors, surname_first)
        return [] if authors.nil?
        authors.split(/\band\b/).collect do |name|
          if name.include?(", ")
            parts = name.strip.rpartition(", ")
            if surname_first
              "#{parts.first}, #{parts.third}"
            else
              "#{parts.third} #{parts.first}"
            end
          else
            name
          end
        end
      end

    # Arrange given author string into Chicago format
    def author_chicago(authors)
      arrange_authors(authors, true)
    end
  end

  CitationData = Struct.new :original, :type, :pretext, :cites 
end
