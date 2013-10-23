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

    def separator
      if Styles.is_numeric? @style
        ","
      else
        ";"
      end
    end

    # Format pages with pp/p as appropriate
    def with_pp pages
      return "" if pages.nil? or pages.empty?

      if @style.include? "chicago"
        pages
      elsif pages.include? '-'
        "pp.&#160;#{pages}"
      else
        "p.&#160;#{pages}"
      end
    end

    # Return the complete citation text for given cite_data
    def complete_citation cite_data
      result = ""

      add_parens = 1

      cite_data.cites.each_with_index do |cite, index|
        # before all items apart from the first, insert appropriate separator
        result << "#{separator} " unless index.zero?

        # @links requires adding hyperlink to reference
        result << "<<#{cite.ref}," if @links

        # if found, insert reference information
        unless @biblio[cite.ref].nil?
          item = @biblio[cite.ref].clone
          item['citation-number'] = @citations.cites_used.index(cite) + 1
          cite_text = CiteProc.process item.to_citeproc, :style => @style, :format => :html, :mode => 'citation'
          cite_text = cite_text[0]

          fc = cite_text[0,1]
          lc = cite_text[-1,1]
          if fc == '(' and lc == ')'
            cite_text = cite_text[1..-2]
          elsif fc == '[' and lc == ']'
            add_parens = 2
            cite_text = cite_text[1..-2]
          end

          page_str = ""
          unless cite.pages.empty?
            page_str << "," unless is_numeric?
            page_str << " #{with_pp(cite.pages)}"
          end

          if is_numeric? @style
            cite_text << page_str
          elsif cite.type == "citenp"
            cite_text.gsub!(item.year, "#{fc}#{item.year}#{page_str}#{lc}")
            cite_text.gsub!(", #{fc}", " #{fc}")
          else 
            cite_text << page_str
          end

        else
          puts "Unknown reference: #{cite.ref}"
          cite_text = "#{cite.ref}"
        end

        cite_text.gsub!(",", "&#44;") if @links # replace comma

          result << cite_text.html_to_asciidoc
        # @links requires finish hyperlink
        result << ">>" if @links
      end

      pretext = "#{pre} " unless pre.nil? or pre.empty?
      if add_parens == 1
        ob = "("
        cb = ")"
      else
        ob = "["
        cb = "]"
      end

      unless @links
        # combine numeric ranges
        if is_numeric?(@style)
          result = combine_consecutive_numbers result
        end
      end

      if is_numeric?(@style)
        result = "#{pretext}#{ob}#{result}#{cb}"
      elsif type == "cite" 
        result = "#{ob}#{pretext}#{result}#{cb}"
      else 
        result = "#{pretext}#{result}"
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

    # Used with numeric styles to combine consecutive numbers into ranges
    # e.g. 1,2,3 -> 1-3, or 1,2,3,6,7,8,9,12 -> 1-3,6-9,12
    # leave references with page numbers alone
    def combine_consecutive_numbers str
      nums = str.split(",").collect(&:strip)
      res = ""
      # Loop through ranges
      start_range = 0
      while start_range < nums.length do
        end_range = start_range
        while (end_range < nums.length-1 and
               nums[end_range].is_i? and
               nums[end_range+1].is_i? and
               nums[end_range+1].to_i == nums[end_range].to_i + 1) do
                 end_range += 1
               end
               if end_range - start_range >= 2
                 res += "#{nums[start_range]}-#{nums[end_range]}, "
               else
                 start_range.upto(end_range) do |i|
                   res += "#{nums[i]}, "
                 end
               end
               start_range = end_range + 1
        end
        # finish by removing last comma
        res.gsub(/, $/, '')
      end

    end

    CitationData = Struct.new :original, :type, :pretext, :cites 
  end
