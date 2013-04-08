# Some extension and other helper methods. 
#
# Copyright (c) Peter Lane, 2012-13.
# Released under Open Works License, 0.9.2

module AsciidocBibArrayExtensions

  require 'citeproc'

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

# Converts html output produced by citeproc to asciidoc markup
module StringHtmlToAsciiDoc
  def html_to_asciidoc
    r = self.gsub(/<\/?i>/, '_')
    r = r.gsub(/<\/?b>/, '*')
    r = r.gsub(/<\/?span.*?>/, '')
    r
  end
end

# Provides a check that a string is in integer
# Taken from:
# http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
module IntegerCheck
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end

# monkey patch the extension methods into String
class String
  include StringHtmlToAsciiDoc
  include IntegerCheck
end

module AsciidocBib

  # matches a single ref with optional pages
  CITATION = /(\w+)(,([\w\.\- ]+))?/
  # matches complete citation with multiple references
  CITATION_FULL = /\[(cite|citenp):(([\w\-\;\!\? ]+):)?(#{CITATION}(;#{CITATION})*)\]/

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

  # Retrieve text for reference in given style
  # - biblio is current bibliography
  # - ref is reference for item to give reference for
  # - links is true/false for adding a link reference
  # - style holds the current reference style
  def get_reference(biblio, ref, links, style)
    result = ""
    result << ". " if is_numeric?(style)

    item = biblio[ref]
    item = item.convert_latex unless item.nil?

    result << "[[#{ref}]]" if links
    return result+ref if item.nil?

    cptext = CiteProc.process item.to_citeproc, :style => style, :format => :html
    result << cptext unless cptext.nil?

    result.html_to_asciidoc
  end

  # retrieve citation text
  # - biblio is current bibliography
  # - type holds type of citation: cite, citenp
  # - pre is text to place before the citation
  # - refs is list of references for items to cite
  # - pages is list of page numbers for each ref, nil if no page given
  # - links is true/false for placing a link to reference
  # - sorted_cites is complete list of citations in document, sorted
  # - style holds the current reference style
  def get_citation(biblio, type, pre, refs, pages, links, sorted_cites, style)
    result = ""

    add_parens = 1

    (refs.zip(pages)).each_with_index do |ref_page_pair, index|
      ref = ref_page_pair[0]
      page = ref_page_pair[1]
      page.gsub!("--","-") unless page.nil?

      # before all items apart from the first, insert appropriate separator
      unless index.zero?
        if is_numeric?(style)
          result << ", "
        else
          result << "; "
        end
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

        page_str = ""
        unless page.nil? or page.empty?
          page_str << "," unless is_numeric? style
          page_str << " #{with_pp(page, style)}"
        end

        if is_numeric? style
          cite_text << page_str
        elsif type == "citenp"
          cite_text.gsub!(item.year, "#{fc}#{item.year}#{page_str}#{lc}")
          cite_text.gsub!(", #{fc}", " #{fc}")
        else 
          cite_text << page_str
        end

      else
        puts "Unknown reference: #{ref}"
        cite_text = "#{ref}"
      end

      cite_text.gsub!(",", "&#44;") if links # replace comma
      result << cite_text.html_to_asciidoc
      result << ">>" if links
    end

    pretext = "#{pre} " unless pre.nil? or pre.empty?
    if add_parens == 1
      ob = "("
      cb = ")"
    else
      ob = "["
      cb = "]"
    end

    unless links
      # combine numeric ranges
      if is_numeric?(style)
        result = combine_consecutive_numbers(result)
      end
    end

    if is_numeric?(style)
      result = "#{pretext}#{ob}#{result}#{cb}"
    elsif type == "cite" 
      result = "#{ob}#{pretext}#{result}#{cb}"
    else 
      result = "#{pretext}#{result}"
    end

    result
  end

  # Format pages with pp/p as appropriate
  def with_pp(pages, style)
    if pages.nil? or pages.empty?
      ""
    else
      pages.gsub!("--", "-")
      if style.include? "chicago"
        pages
      elsif pages.include? '-'
        "pp.&#160;#{pages}"
      else
        "p.&#160;#{pages}"
      end
    end
  end

  # Used with numeric styles to combine consecutive numbers into ranges
  # e.g. [1,2,3] -> [1-3], or [1,2,3,6,7,8,9,12] -> [1-3,6-8,9,12]
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

