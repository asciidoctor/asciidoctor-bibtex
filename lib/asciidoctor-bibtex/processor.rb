#
# Manage the current set of citations, the document settings,
# and main operations.
#

require 'bibtex'
require 'bibtex/filters'
require 'citeproc'
require 'csl/styles'
require 'latex/decode/base'
require 'latex/decode/maths'
require 'latex/decode/accents'
require 'latex/decode/diacritics'
require 'latex/decode/punctuation'
require 'latex/decode/symbols'
require 'latex/decode/greek'
require 'set'

require_relative 'citation_macro'
require_relative 'citation_utils'
require_relative 'string_utils'
require_relative 'style_utils'

module AsciidoctorBibtex
  # This filter extends the original latex filter in bibtex-ruby to handle
  # unknown latex macros more gracefully. We could have used latex-decode
  # gem together with our custom replacement rules, but latex-decode eats up
  # all braces after it finishes all decoding. So we hack over the
  # LaTeX.decode function and insert our rules before `strip_braces`.
  class LatexFilter < ::BibTeX::Filter
    def apply(value)
      text = value.to_s
      LaTeX::Decode::Base.normalize(text)
      LaTeX::Decode::Maths.decode!(text)
      LaTeX::Decode::Accents.decode!(text)
      LaTeX::Decode::Diacritics.decode!(text)
      LaTeX::Decode::Punctuation.decode!(text)
      LaTeX::Decode::Symbols.decode!(text)
      LaTeX::Decode::Greek.decode!(text)
      text = text.gsub(/\\url\{(.+?)\}/, ' \\1 ').gsub(/\\\w+(?=\s+\w)/, '').gsub(/\\\w+(?:\[.+?\])?\s*\{(.+?)\}/, '\\1')
      LaTeX::Decode::Base.strip_braces(text)
      LaTeX.normalize_C(text)
    end
  end

  # Class used through utility method to hold data about citations for
  # current document, and run the different steps to add the citations
  # and bibliography
  class Processor
    def initialize(bibfile, links = false, style = 'ieee', locale = 'en-US',
                   numeric_in_appearance_order = false, output = :asciidoc,
                   throw_on_unknown = false)
      raise "File '#{bibfile}' is not found" unless FileTest.file? bibfile

      bibtex = BibTeX.open bibfile, filter: [LatexFilter]
      @biblio = bibtex
      @links = links
      @numeric_in_appearance_order = numeric_in_appearance_order
      @style = style
      @locale = locale
      @citations = []
      @filenames = Set.new
      @output = output
      @throw_on_unknown = throw_on_unknown

      if (output != :latex) && (output != :bibtex) && (output != :biblatex)
        @citeproc = CiteProc::Processor.new style: @style, format: :html, locale: @locale
        @citeproc.import @biblio.to_citeproc
      end
    end

    # Scan a line and process citation macros.
    #
    # As this function being called iteratively on the lines of the document,
    # processor will build a list of all citation keys in the same order as they
    # appear in the original document.
    def process_citation_macros(line)
      CitationMacro.extract_citations(line).each do |citation|
        @citations += citation.items.collect(&:key)
      end
    end

    # Finalize citation macro processing and build internal citation list.
    #
    # As this function being called, processor will clean up the list of
    # citation keys to form a correct ordered citation list.
    def finalize_macro_processing
      @citations = @citations.uniq(&:to_s) # only keep the first occurance
      return if StyleUtils.is_numeric?(@style) && @numeric_in_appearance_order

      @citations = @citations.sort_by do |ref|
        bibitem = @biblio[ref]
        if bibitem.nil?
          [ref]
        else
          # extract the reference, and uppercase.
          # Remove { } from grouped names for sorting.
          author = bibitem.author
          author = bibitem.editor if author.nil?
          CitationUtils.author_chicago(author).collect { |s| s.upcase.gsub('{', '').gsub('}', '') } + [bibitem.year]
        end
      end
      nil
    end

    # Replace citation macros with corresponding citation texts.
    #
    # Return new text with all macros replaced.
    def replace_citation_macros(line)
      CitationMacro.extract_citations(line).each do |citation|
        line = line.gsub(citation.text, build_citation_text(citation))
      end
      line
    end

    # Build the bibliography list just as bibtex.
    #
    # Return an array of texts representing an asciidoc list.
    def build_bibliography_list
      result = []
      @citations.each do |ref|
        result << build_bibliography_item(ref)
        result << ''
      end
      result
    end

    #
    # Internal functions
    #

    # Build bibliography text for a given reference
    def build_bibliography_item(key)
      result = ''
      result << '. ' if StyleUtils.is_numeric? @style

      begin
        cptext = @citeproc.render :bibliography, id: key
      rescue Exception => e
        puts "Failed to render #{key}: #{e}"
      end
      result << "[[#{key}]]" if @links
      if cptext.nil?
        return result + key
      else
        result << cptext.first
      end

      StringUtils.html_to_asciidoc(result)
    end

    # Build the complete citation text for given citation macro
    def build_citation_text(macro)
      if (@output == :latex) || (@output == :bibtex) || (@output == :biblatex)
        result = '+++'
        macro.items.each do |cite|
          # NOTE: xelatex does not support "\citenp", so we output all
          # references as "cite" here unless we're using biblatex.
          result << '\\' << if @output == :biblatex
                              if macro.type == 'citenp'
                                'textcite'
                              else
                                'parencite'
                                                end
                            else
                              'cite'
                            end
          result << '[p. ' << cite.locator << ']' if cite.locator != ''
          result << '{' << cite.key.to_s << '},'
        end
        result = result[0..-2] if result[-1] == ','
        result << '+++'
        result
      else
        result = ''
        if StyleUtils.is_numeric? @style
          ob = '+[+'
          cb = '+]+'
          separator = ','
        elsif macro.type == 'cite'
          ob = '('
          cb = ')'
          separator = ';'
        else
          ob = ''
          cb = ''
          separator = ';'
        end

        macro.items.each_with_index do |cite, index|
          # before all items apart from the first, insert appropriate separator
          result << "#{separator} " unless index.zero?

          # @links requires adding hyperlink to reference
          result << "<<#{cite.key}," if @links

          # if found, insert reference information
          if @biblio[cite.key].nil?
            if @throw_on_unknown
              raise "Unknown reference: #{cite.ref}"
            else
              puts "Unknown reference: #{cite.ref}"
              cite_text = cite.ref.to_s
            end
          else
            cite_text = citation_text(macro, cite)
           end

          result << StringUtils.html_to_asciidoc(cite_text)
          result << '>>' if @links
        end

        if StyleUtils.is_numeric?(@style) && !@links
          result = StringUtils.combine_consecutive_numbers(result)
        end

        include_pretext result, macro, ob, cb
      end
    end

    # Format locator with pp/p as appropriate
    def format_locator(cite)
      result = ''
      unless cite.locator.empty?
        result << ',' unless StyleUtils.is_numeric? @style
        result << ' '
        # use p.x for single numerical page and pp.x for all others. This will
        # produce pp. 1 seq for complex locators, which is the correct behavior.
        if @style.include? 'chicago'
          result << cite.locator
        elsif /^\d+$/ =~ cite.locator
          result << "p.&#160;#{cite.locator}"
        else
          result << "pp.&#160;#{cite.locator}"
        end
      end

      result
    end

    def include_pretext(result, macro, ob, cb)
      pretext = macro.pretext
      pretext += ' ' unless pretext.empty? # add space after any content

      if StyleUtils.is_numeric? @style
        "#{pretext}#{ob}#{result}#{cb}"
      elsif macro.type == 'cite'
        "#{ob}#{pretext}#{result}#{cb}"
      else
        "#{pretext}#{result}"
      end
    end

    # Generate a raw citation text for a single citation item
    def citation_text(macro, cite)
      if StyleUtils.is_numeric? @style
        cite_text = (@citations.index(cite.key) + 1).to_s
        cite_text << format_locator(cite)
      else
        # We generate the citation without locator using citeproc, then strip
        # the surrounding braces, finally add the locator and add braces for
        # `citenp`.
        cite_text = @citeproc.render :citation, id: cite.key
        cite_text = cite_text.gsub('(', '')
        cite_text = cite_text.gsub(')', '')
        cite_text = cite_text + format_locator(cite)
        year = @biblio[cite.key].year
        if !year.nil? && macro.type == 'citenp'
          segs = cite_text.partition(year.to_s)
          head = segs[0].gsub(', ', ' ')
          tail = segs[1..-1].join
          cite_text = "#{head}(#{tail})"
        end
        # finally escape some special chars
        cite_text = cite_text.gsub(',', '&#44;') if @links # replace comma
      end

      cite_text
    end
  end
end
