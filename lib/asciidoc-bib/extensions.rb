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

# Provide a method on String to remove latex formatting, 
# so asciidoc/a2x do not fail on simple formatting issues.
# 
# Removes:
# - {
# - }
module StringDelatex
  def delatex
    self.gsub("{","").gsub("}","")
  end
end

# monkey patch the extension method into String
class String
  include StringDelatex
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

	# Arrange given author string into generic numeric format
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
    editor_done = false
    item = biblio[ref]

    return ref if item.nil? # escape if no entry for reference in biblio

    # add information for author/editor and year
  	if item.author.nil?
      unless item.editor.nil?
        result << "#{author_chicago(item.editor).comma_and_join} (ed.) "
        editor_done = true
      end
    else
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
			unless item.editor.nil? or editor_done
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
    editor_done = false
    item = biblio[ref]

    return ref if item.nil? # escape if no entry for reference in biblio

    # add information for author/editor and year
   	if item.author.nil?
      unless item.editor.nil?
        result << "#{author_numeric(item.editor).comma_and_join} (ed.) "
        editor_done = true
      end
    else
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
				result << "in _#{item.booktitle}_, "
			end
			unless item.editor.nil? or editor_done
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
    case style
    when "authoryear", "authoryear:chicago" then
      get_chicago_citation(biblio, type, pre, refs, pages, sorted_cites)
    when "numeric" then
      get_numeric_citation(biblio, type, pre, refs, pages, sorted_cites)
    when "authoryear:harvard" then
      get_harvard_citation(biblio, type, pre, refs, pages, sorted_cites)
    end
  end

  def get_chicago_citation(biblio, type, pre, refs, pages, sorted_cites)
		result = ""

		result << "(" if type == "cite" 
		result << "#{pre} " unless pre.nil? or pre.empty?

		(refs.zip(pages)).each_with_index do |ref_page_pair, index|
			ref = ref_page_pair[0]
			page = ref_page_pair[1]
      page.gsub!("--","-") unless page.nil?

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        result << "; " 
      end
      # insert reference information, if found
			unless biblio[ref].nil?
			  result << citation(biblio[ref].author, biblio[ref].year, type, page)
			else
				puts "Unknown reference: #{ref}"
				result << "#{ref}"
				result << " (unknown)"
			end
		end

		result << ")" if type == "cite"

    return result
	end
  
  def get_harvard_citation(biblio, type, pre, refs, pages, sorted_cites)
		result = ""

		result << "(" if type == "cite" 
		result << "#{pre} " unless pre.nil? or pre.empty?

		(refs.zip(pages)).each_with_index do |ref_page_pair, index|
			ref = ref_page_pair[0]
			page = ref_page_pair[1]
      page.gsub!("--","-") unless page.nil?

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        result << "; " 
      end
      # insert reference information, if found
			unless biblio[ref].nil?
			  result << citation_harvard(biblio[ref].author, biblio[ref].year, type, page)
			else
				puts "Unknown reference: #{ref}"
				result << "#{ref}"
				result << " (unknown)"
			end
		end

		result << ")" if type == "cite"

    return result
	end

  def get_numeric_citation(biblio, type, pre, refs, pages, sorted_cites)
		result = ""

		result << "#{pre} " unless pre.nil? or pre.empty?
		result << "[" 

		(refs.zip(pages)).each_with_index do |ref_page_pair, index|
			ref = ref_page_pair[0]
			page = ref_page_pair[1]
      page.gsub!("--","-") unless page.nil?

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        result << ", "
      end
      # insert reference information, if found
			unless biblio[ref].nil?
			  result << "#{sorted_cites.index(ref)+1}"
				result << " p.#{page}" unless page.nil? or page.empty?
			else
				puts "Unknown reference: #{ref}"
				result << "#{ref}"
			end
		end

		result << "]" 

    return result
	end

  # return an array of the author surnames extracted from author_string
  def author_surnames(author_string)
    author_string.split(/\band\b/).collect do |name|
			name.split(", ").first.strip
		end
  end

  # Chicago-style citations
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
  
  def citation_harvard(author, year, type, pages)
		result = ""

		result << author_surnames(author).comma_and_join
		result << ", " if type == "cite"
		result << " (" if type == "citenp"
		result << year
		result << ", p.#{pages}" unless pages.nil? or pages.empty?
		result << ")" if type == "citenp"

		return result
  end
end

