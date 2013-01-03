# Some extension and other helper methods. 
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

module AsciidocBibArrayExtensions

# Retrieve the third item of an array
  # Note: no checks for validity
	def third
		self[2]
	end

  # Join items in array using commas and 'and' on last item
	def comma_and_join
		if size < 2
			return self.join("")
		end
		result = ""
		self.each_with_index do |item, index|
			if index.zero?
				result << item
			elsif index == size-1
				result << " and #{item}"
			else
				result << ", #{item}"
			end
		end

		return result
	end
end

# monkey patch the extension methods to Array
class Array
  include AsciidocBibArrayExtensions
end

module AsciidocBib

	# matches a single ref with optional pages
	CITATION = /(\w+)(,([\w\.\- ]+))?/
	# matches complete citation with multiple references
	CITATION_FULL = /\[(cite|citenp):(([\w ]+):)?(#{CITATION}(;#{CITATION})*)\]/

	# -- utility functions
	
	def extract_cites line
		cites_used = []
		md = CITATION_FULL.match(line)
		while md
			cite_text = md[4]
			cm = CITATION.match(cite_text)
			while cm
				cites_used << cm[1]
				# look for next ref within citation
        cm = CITATION.match(cm.post_match)
			end
			# look for next citation on line
			md = CITATION_FULL.match(md.post_match)
		end
		return cites_used
	end

  # Given the text for one or more references (i.e. the ... in [cite:...])
  # return two arrays, the first of the references, and the second of the pages
  def extract_refs_pages cite_text
		refs = []
		pages = []
		cm = CITATION.match(cite_text)
		while cm
			# process ref 
			refs << cm[1]
			pages << cm[3]
			# look for next ref within citation
			cm = CITATION.match(cm.post_match)
		end
    return refs, pages
  end

  # Add '-ref' before the extension of a filename
  def add_ref filename
    file_dir = File.dirname(File.expand_path(filename))
    file_base = File.basename(filename, ".*")
    file_ext = File.extname(filename)
    return "#{file_dir}#{File::SEPARATOR}#{file_base}-ref#{file_ext}"
  end

  # Arrange given author string into Chicago format
  def author_chicago(authors)
		return [] if authors.nil?
		authors.split(/\band\b/).collect do |name|
      if name.include?(", ")
  			parts = name.strip.rpartition(", ")
	  		"#{parts.first}, #{parts.third}"
      else
        name
      end
		end
	end

	# Arrange given author string into Springer LNCS numeric format
  def author_numeric(authors)
		return [] if authors.nil?
		authors.split(/\band\b/).collect do |name|
      if name.include?(", ")
  			parts = name.strip.rpartition(", ")
	  		"#{parts.third} #{parts.first}"
      else
        name
      end
		end
	end

  # Based on type of bibitem, format the reference in chicago style
  def get_reference_authoryear(biblio, ref)
		result = ""
    item = biblio[ref]

    return ref if item.nil? # escape if no entry for reference in biblio

    # add information for author and year
  	unless item.author.nil?
			result << "#{author_chicago(item.author).comma_and_join} "
		end
		unless item.year.nil?
			result << "#{item.year}. "
		end
	
    # add information which varies on document type
    if item.article?
			unless item.title.nil?
				result << "\"#{item.title},\" "
			end 
			unless item.journal.nil?
				result << "_#{item.journal}_, "
			end
			unless (not item.respond_to?(:volume)) or item.volume.nil?
				result << "#{item.volume}:"
			end
			unless (not item.respond_to?(:pages)) or item.pages.nil?
				result << "#{item.pages.gsub("--","-")}"
			end
			result << "."
    elsif item.book?
			unless item.title.nil?
				result << "_#{item.title}_, "
			end 
			unless item.publisher.nil?
				result << "#{item.publisher}"
			end
			result << "."
    elsif item.collection? or (not item.title.nil? and not item.booktitle.nil?)
  		unless item.title.nil?
				result << "\"#{item.title},\" "
			end 
			unless item.booktitle.nil?
				result << "In _#{item.booktitle}_, "
			end
			unless item.editor.nil?
				result << "ed. #{author_chicago(item.editor).comma_and_join}, "
			end
			unless item.pages.nil?
				result << "#{item.pages.gsub("--","-")}."
			end
			unless item.publisher.nil?
				result << "#{item.publisher}."
			end
    else
  		unless item.title.nil?
				result << "\"#{item.title},\" "
			end
      school = if item.respond_to?(:school) then item.school else "" end
      howpublished = if item.respond_to?(:howpublished) then item.howpublished else "" end
      note = if item.respond_to?(:note) then item.note else "" end
      unless school.nil? and howpublished.nil? and note.nil?
        result << "("
        space = ""
    		unless school.nil? or school.empty?
  				result << "#{school}"
          space = "; "
			  end 
  	  	unless howpublished.nil? or howpublished.empty?
	  			result << "#{space}#{howpublished}"
          space = "; "
  			end 
  		  unless note.nil? or note.empty?
		  		result << "#{space}#{note}"
	  		end 
        result << ")."
      end
	  end

  	return result
  end

	# Based on type of bibitem, format the reference in numeric style
  def get_reference_numeric(biblio, ref)
		result = ""
    item = biblio[ref]

    return ref if item.nil? # escape if no entry for reference in biblio

    # add information for author and year
  	unless item.author.nil?
			result << "#{author_numeric(item.author).comma_and_join} "
		end
	
    # add information which varies on document type
    if item.article?
			unless item.title.nil?
				result << "\"#{item.title},\" "
			end 
			unless item.journal.nil?
				result << "_#{item.journal}_, "
			end
			unless (not item.respond_to?(:volume)) or item.volume.nil?
				result << "#{item.volume}:"
			end
			unless (not item.respond_to?(:pages)) or item.pages.nil?
				result << "#{item.pages.gsub("--","-")}"
			end
			result << ", "
    elsif item.book?
			unless item.title.nil?
				result << "_#{item.title}_, "
			end 
			unless item.publisher.nil?
				result << "#{item.publisher}"
			end
			result << ", "
    elsif item.collection? or (not item.title.nil? and not item.booktitle.nil?)
  		unless item.title.nil?
				result << "\"#{item.title},\" "
			end 
			unless item.booktitle.nil?
				result << "In _#{item.booktitle}_, "
			end
			unless item.editor.nil?
				result << "ed. #{author_numeric(item.editor).comma_and_join}, "
			end
			unless item.pages.nil?
				result << "#{item.pages.gsub("--","-")}."
			end
			unless item.publisher.nil?
				result << "#{item.publisher}, "
			end
    else
  		unless item.title.nil?
				result << "\"#{item.title},\" "
			end
      school = if item.respond_to?(:school) then item.school else "" end
      howpublished = if item.respond_to?(:howpublished) then item.howpublished else "" end
      note = if item.respond_to?(:note) then item.note else "" end
      unless school.nil? and howpublished.nil? and note.nil?
        result << "("
        space = ""
    		unless school.nil? or school.empty?
  				result << "#{school}"
          space = "; "
			  end 
  	  	unless howpublished.nil? or howpublished.empty?
	  			result << "#{space}#{howpublished}"
          space = "; "
  			end 
  		  unless note.nil? or note.empty?
		  		result << "#{space}#{note}"
	  		end 
        result << "), "
      end
	  end
		unless item.year.nil?
			result << "#{item.year}. "
		end

  	return result
  end

	# retrieve citation text
	def get_citation(biblio, type="cite", 
									 pre="", refs=[], pages=[], 
									 style, sorted_cites)
		result = ""

		result << "(" if type == "cite" and style == "authoryear"
		result << "#{pre} " unless pre.nil? or pre.empty?
		result << "[" if style == "numeric"

		(refs.zip(pages)).each_with_index do |ref_page_pair, index|
			ref = ref_page_pair[0]
			page = ref_page_pair[1].gsub("--","-")

			result << "; " unless index.zero?
			unless biblio[ref].nil?
				case style
				when "authoryear" then
					result << citation(biblio[ref].author, biblio[ref].year, type, page)
				when "numeric" then
					result << "#{sorted_cites.index(ref)+1}"
					result << ",#{page}" unless page.nil? or page.empty?
				end
			else
				puts "Unknown reference: #{ref}"
				result << "#{ref}"
				result << " (unknown)" if style == "authoryear"
			end
		end

		result << "]" if style == "numeric"
		result << ")" if type == "cite" and style == "authoryear"

    return result
	end

  # return an array of the author surnames extracted from author_string
  def author_surnames(author_string)
    author_string.split(/\band\b/).collect do |name|
			name.split(", ").first.strip
		end
  end

  def citation(author, year, type, pages)
		result = ""

		result << author_surnames(author).comma_and_join
		result << " "
		result << "(" if type == "citenp"
		result << year
		result << ", #{pages}" unless pages.nil? or pages.empty?
		result << ")" if type == "citenp"

		return result
  end
end

