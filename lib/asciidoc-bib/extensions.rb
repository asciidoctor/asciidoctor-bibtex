# Some extension and other helper methods. 
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

module AsciidocBibArrayExtensions

  require 'citeproc'
  require 'latex/decode'

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
# - \. (escaped Latex characters)
module StringDelatex
  def delatex
    LaTeX.decode self
  end
end

# Converts html output produced by citeproc to asciidoc markup
module StringHtmlToAsciiDoc
  def html_to_asciidoc
    r = self.gsub(/<\/?i>/, '_')
    r = r.gsub(/<\/?b>/, '*')
    r = r.gsub(/<\/?span.*?>/, '')
    r
  end
end

# monkey patch the extension methods into String
class String
  include StringDelatex
  include StringHtmlToAsciiDoc
end

module AsciidocBib

  # matches a single ref with optional pages
  CITATION = /(\w+)(,([\w\.\- ]+))?/
  # matches complete citation with multiple references
  CITATION_FULL = /\[(cite|citenp):(([\w\- ]+):)?(#{CITATION}(;#{CITATION})*)\]/

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

  # Arrange given author string into generic numeric format
  def author_numeric(authors)
    arrange_authors(authors, false)
  end

  def get_reference_citeproc(biblio, ref, links, style)
    result = ""
    result << ". " if is_numeric?(style)

    item = biblio[ref]

    result << "[[#{ref}]]" if links
    return result+ref if item.nil?

    cptext = CiteProc.process item.to_citeproc, :style => style, :format => :html
    result << cptext unless cptext.nil?

    result.html_to_asciidoc
  end

  # Based on type of bibitem, format the reference in specified format
  def get_reference(biblio, ref, links, style)
    result = ""
    editor_done = false
    item = biblio[ref]

    result << ". " if style == "numeric"

    result << "[[#{ref}]]" if links
    return result+ref if item.nil? # escape if no entry for reference in biblio

    # add information for author/editor and year
    if item.author.nil?
      unless item.editor.nil?
        result << "#{with_author(item.editor, style)} (ed.)"
        result << "," if style == "numeric"
        result << " "
        editor_done = true
      end
    else
      result << "#{with_author(item.author, style)}"
      result << "," if style == "numeric"
      result << " "
    end
    unless item.year.nil? or style == "numeric"
      result << "(" if style == "authoryear:harvard"
      result << "#{item.year}"
      result << ")" if style == "authoryear:harvard"
      result << ". "
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
        result << "#{item.volume}"
        result << ":" unless style == "authoryear:harvard"
      end
      unless (not item.respond_to?(:pages)) or item.pages.nil?
        result << ", " if style == "authoryear:harvard"
        result << "#{item.pages.gsub("--","-")}"
      end
      result << "."
    elsif item.book?
      unless item.title.nil?
        result << "_#{item.title}_, "
      end 
      result << with_publisher(item)
      if style == "numeric"
        result << ", "
      else
        result << "."
      end
    elsif item.collection? or (not item.title.nil? and not item.booktitle.nil?)
      unless item.title.nil?
        result << "\"#{item.title},\" "
      end 
      unless item.booktitle.nil?
        if style == "numeric"
          result << "in "
        else
          result << "In "
        end
        result << "_#{item.booktitle}_, "
      end
      unless item.editor.nil? or editor_done
        result << "ed. #{author_chicago(item.editor).comma_and_join}, "
      end
      unless item.pages.nil?
        result << "#{item.pages.gsub("--","-")}."
      end
      result << with_publisher(item)
      unless item.publisher.nil? # if we added something
        if style == "numeric"
          result << ", "
        else 
          result << "."
        end
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
        result << ")"
        if style == "numeric"
          result << ", "
        else
          result << "."
        end
      end
    end
    if style == "numeric"
      unless item.year.nil?
        result << "#{item.year}."
      end
    end

    return result
  end

  # Retrieve string for given authors, using style
  def with_author(authors, style)
    case style
    when "numeric" then
      author_numeric(authors).comma_and_join
    else
      author_chicago(authors).comma_and_join
    end
  end

  def with_pp pages
    if pages.nil? or pages.empty?
      ""
    else
      pages.gsub!("--", "-")
      if pages.include? '-'
        " pp.#{pages}"
      else
        " p.#{pages}"
      end
    end
  end

  # Retrieve string for publisher with optional address
  def with_publisher item
    result = ""
    if item.respond_to? :address
      unless item.address.nil?
        result << "#{item.address}"
        result << ":" unless item.publisher.nil?
        result << " "
      end
    end
    unless item.publisher.nil?
      result << "#{item.publisher}"
    end
    return result
  end

  # retrieve citation text
  def get_citation(biblio, type, 
                   pre, refs, pages, 
                   links, style, sorted_cites)
    case style
    when "authoryear", "authoryear:chicago" then
      get_chicago_citation(biblio, type, pre, refs, pages, links, sorted_cites)
    when "numeric" then
      get_numeric_citation(biblio, type, pre, refs, pages, links, sorted_cites)
    when "authoryear:harvard" then
      get_harvard_citation(biblio, type, pre, refs, pages, links, sorted_cites)
    else
      get_citeproc_citation(biblio, type, pre, refs, pages, links, sorted_cites, style)
    end
  end

  def get_chicago_citation(biblio, type, pre, refs, pages, links, sorted_cites)
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
      result << "<<#{ref}," if links
      cite_text = ""
      unless biblio[ref].nil?
        author = if biblio[ref].author.nil?
                   biblio[ref].editor
                 else
                   biblio[ref].author
                 end
        cite_text = citation(author, biblio[ref].year, type, page)
      else
        puts "Unknown reference: #{ref}"
        cite_text = "#{ref}"
        cite_text << " (unknown)"
      end
      cite_text.gsub!(",", "&#44;") if links # replace comma
        result << cite_text
      result << ">>" if links
    end

    result << ")" if type == "cite"

    return result.delatex
  end

  def get_harvard_citation(biblio, type, pre, refs, pages, links, sorted_cites)
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
      result << "<<#{ref}," if links
      cite_text = ""
      unless biblio[ref].nil?
        author = if biblio[ref].author.nil?
                   biblio[ref].editor
                 else
                   biblio[ref].author
                 end
        cite_text = citation_harvard(author, biblio[ref].year, type, page)
      else
        puts "Unknown reference: #{ref}"
        cite_text = "#{ref}"
        cite_text << " (unknown)"
      end
      cite_text.gsub!(",", "&#44;") if links # replace comma
        result << cite_text
      result << ">>" if links
    end

    result << ")" if type == "cite"

    return result.delatex
  end

  def get_numeric_citation(biblio, type, pre, refs, pages, links, sorted_cites)
    result = ""

    result << "#{pre} " unless pre.nil? or pre.empty?
    result << "[" 

    (refs.zip(pages)).each_with_index do |ref_page_pair, index|
      ref = ref_page_pair[0]
      page = ref_page_pair[1]

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        result << ", "
      end
      # insert reference information, if found
      result << "<<#{ref}," if links
      cite_text = ""
      unless biblio[ref].nil?
        cite_text = "#{sorted_cites.index(ref)+1}"
        cite_text << with_pp(page) 
      else
        puts "Unknown reference: #{ref}"
        cite_text = "#{ref}"
      end
      cite_text.gsub!(",", "&#44;") if links # replace comma
        result << cite_text
      result << ">>" if links
    end

    result << "]" 

    return result.delatex
  end

  def get_citeproc_citation(biblio, type, pre, refs, pages, links, sorted_cites, style)
    result = ""

    add_parens = 1

    (refs.zip(pages)).each_with_index do |ref_page_pair, index|
      ref = ref_page_pair[0]
      page = ref_page_pair[1]
      page.gsub!("--","-") unless page.nil?

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        result << ", "
      end

      # insert reference information, if found
      result << "<<#{ref}," if links

      unless biblio[ref].nil?
        item = biblio[ref].clone
        item['citation-number'] = sorted_cites.index(ref) + 1
        cite_text = CiteProc.process item.to_citeproc, :style => style, :format => :html, :mode => 'citation'
        cite_text = cite_text[0]

        fc = cite_text[0,1]
        lc = cite_text[-1,1]
        if fc == '(' and lc == ')'
          cite_text = cite_text[1..-2]
        elsif fc == '[' and lc == ']'
          add_parens = 2
          cite_text = cite_text[1..-2]
        end

        if type == "citenp"
          cite_text.gsub!(item.year, "#{fc}#{item.year}#{lc}")
          cite_text.gsub!(", #{fc}", " #{fc}")
        end

        unless page.nil? or page.empty?
          cite_text << ", #{with_pp(page)}"
        end
      else
        puts "Unknown reference: #{ref}"
        cite_text = "#{ref}"
      end

      cite_text.gsub!(",", "&#44;") if links # replace comma
      result << cite_text.html_to_asciidoc
      result << ">>" if links
    end

    result = "#{pre} #{result}" unless pre.nil? or pre.empty?
    if type == "cite"
      case add_parens
      when 1 then
        result = "(#{result})"
      when 2 then
        result = "[#{result}]"
      end
    end

    result.delatex 
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
    unless pages.nil? or pages.empty?
      if pages.include? '-'
        pp = "pp"
      else
        pp = "p"
      end
      result << ", #{pp}.#{pages}"
    end
    result << ")" if type == "citenp"

    return result
  end
end

