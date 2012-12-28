# Classes for use in asciidoc-bib
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

module AsciidocBib
  # -- class for handling a bibliography

  class Biblio

    def initialize
      @store = {}
    end

		# retrieve citation text
		def get_citation(type="cite", pre="", refs=[], pages=[])
			result = ""

			result << "(" if type == "cite" 
			result << "#{pre} " unless pre.nil? or pre.empty?

			(refs.zip(pages)).each_with_index do |ref_page_pair, index|
				ref = ref_page_pair[0]
				page = ref_page_pair[1]

				result << "; " unless index.zero?
				if contains?(ref)
					result << @store[ref].citation(type, page)
				else
					puts "Unknown reference: #{ref}"
					result << "#{ref} (unknown)"
				end
			end
			result << ")" if type == "cite"

			return result
		end

		# retrieve full reference text
		def get_reference ref
			if contains?(ref)
				return @store[ref].reference
			else
				return ref
			end
		end

    # store given ref/bibitem pair
    def []=(ref, bibitem)
      @store[ref] = bibitem
    end

    # look up given reference value, returns nil if not found
    def [](ref)
      @store[ref]
    end

    # check if given reference present
    def contains? ref
      @store.has_key? ref
    end
  end

  # -- classes for storing different bibitems

	class BibItem
		attr_accessor :author, :title, :year

		def author_surnames
			@author.split("and").collect do |name|
				name.split(" ").last.strip
			end
		end

		def author_chicago(authors=@author)
			authors.split("and").collect do |name|
				parts = name.strip.rpartition(" ")
				"#{parts.third}, #{parts.first}"
			end
		end

		def citation(type, pages)
			result = ""

			result << author_surnames.comma_and_join
			result << " "
			result << "(" if type == "citenp"
			result << @year
			result << ", #{pages}" unless pages.nil? or pages.empty?
			result << ")" if type == "citenp"

			return result
		end
	end

  class Article < BibItem
    attr_accessor :journal, :volume, :number, :pages

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "\"#{@title},\" "
			end 
			unless @journal.nil?
				result << "_#{@journal}_, "
			end
			unless @volume.nil?
				result << "#{@volume}:"
			end
			unless @pages.nil?
				result << "#{@pages}"
			end
			result << "."
			return result
		end
  end

  class Book < BibItem
    attr_accessor :publisher

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "_#{@title}_, "
			end 
			unless @publisher.nil?
				result << "#{@publisher}"
			end
			result << "."
			return result
		end

  end

  class InCollection < BibItem
    attr_accessor :pages, :editor, :booktitle, :publisher

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "\"#{@title},\" "
			end 
			unless @booktitle.nil?
				result << "In _#{@booktitle}_, "
			end
			unless @editor.nil?
				result << "ed. #{author_chicago(editor).comma_and_join}, "
			end
			unless @pages.nil?
				result << "#{@pages}."
			end
			unless @publisher.nil?
				result << "#{@publisher}."
			end
			return result
		end
  end

  class Manual < BibItem
    attr_accessor :note

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "\"#{@title},\" "
			end 
			unless @note.nil?
				result << "(#{@note})"
			end
			result << "."
			return result
		end
  end

  class Misc < BibItem
    attr_accessor :howpublished

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "\"#{@title}\""
			end 
			unless @howpublished.nil?
				result << " (#{@howpublished})"
			end
			result << "."
			return result
		end
  end

	class PhdThesis < BibItem
		attr_accessor :school

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_chicago.comma_and_join} "
			end
			unless @year.nil?
				result << "#{@year}. "
			end
			unless @title.nil?
				result << "\"#{@title},\" "
			end 
			unless @school.nil?
				result << "(#{@school})"
			end
			result << "."
			return result
		end
	end
	
end
