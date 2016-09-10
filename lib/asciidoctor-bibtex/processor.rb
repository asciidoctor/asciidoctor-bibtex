#
# Manage the current set of citations, the document settings,
# and main operations.
#

module AsciidoctorBibtex

  # Class used through utility method to hold data about citations for
  # current document, and run the different steps to add the citations
  # and bibliography
  class Processor
    include ProcessorUtils

    # Top-level method to include citations in given asciidoc file
    def Processor.run options
      processor = Processor.new (BibTeX.open(options.bibfile, :filter => :latex), options.links, options.style, options.numeric_in_appearance_order?, options.output, options.bibfile
      processor.read_filenames options.filename
      processor.read_citations
      processor.add_citations
    end

    attr_reader :biblio, :links, :style, :citations

    def initialize biblio, links, style, numeric_in_appearance_order = false, output = :asciidoc, bibfile = ""
      @biblio = biblio
      @links = links
      @numeric_in_appearance_order = numeric_in_appearance_order
      @style = style
      @citations = Citations.new
      @filenames = Set.new
      @output = output
      @bibfile = bibfile

      if output != :latex
        @citeproc = CiteProc::Processor.new style: @style, format: :html
        @citeproc.import @biblio.to_citeproc
      end
    end

    # Given an asciidoc filename, reads in all dependent files based on 'include::' statements
    # Leaving a list of files in @filenames
    def read_filenames filename
      puts "Reading file: #{filename}"
      files_to_process = [filename]

      begin
        @filenames.add files_to_process.first
        File.new(files_to_process.shift).each_line do |line|
          if line.include?("include::")
            line.split("include::").drop(1).each do |filetxt|
              file = File.expand_path(filetxt.partition(/\s|\[/).first)
              files_to_process << file unless @filenames.include?(file)
            end
          end
        end
      end until files_to_process.empty?
    end

    # Scans each filename and extracts citations
    def read_citations
      @filenames.each do |file|
        IO.foreach(file) do |line|
          @citations.add_from_line line
        end
      end
    end

    # Read given text to add cites and biblio to a new file
    # Order is always decided by author surname first with year.
    # If no author present, then use editor field.
    # Links indicates if internal links to be added.
    # Assumes @filenames has been set to list of filenames to process.
    def add_citations
      @filenames.each do |curr_file|
        ref_filename = FileHandlers.add_ref(curr_file)
        puts "Writing file: #{ref_filename}"
        output = File.new(ref_filename, "w")

        IO.foreach(curr_file) do |line|
          begin # catch any errors, and ensure the lines of text are written
            case
            when line.include?('include::')
              output_include_line output, line
            when (line =~ BIBMACRO_FULL) != nil
              output_bibliography output
            else
              output_cite_completed_line output, line
            end
          rescue # Any errors, just output the line
            output.puts line
          end
        end

        output.close
      end
    end

    # Output bibliography to given output
    def output_bibliography output
      if @output == :asciidoc
        cites = if Styles.is_numeric?(@style) and @numeric_in_appearance_order
                  @citations.cites_used
                else
                  sorted_cites
                end
        cites.each do |ref|
          output.puts get_reference(ref)
          output.puts
        end
      else
        output.puts "++\\bibliography{#{@bibfile}}++"
        output.puts "++\\bibliographystyle{#{@style}}++"
      end
    end

    def output_include_line output, line
      line.split("include::").drop(1).each do |filetxt|
        ifile = filetxt.partition(/\s|\[/).first
        file = File.expand_path ifile
        # make sure included file points to the -ref version
        line.gsub!("include::#{ifile}", "include::#{FileHandlers.add_ref(file)}")
      end
      output.puts line
    end

    # For each citation in given line, expand into complete citation text
    # before outputting the line
    def output_cite_completed_line output, line
      @citations.retrieve_citations(line).each do |citation|
        line.gsub!(citation.original, complete_citation(citation))
      end
      output.puts line
    end

    # Return the complete citation text for given cite_data
    def complete_citation cite_data

      if @output == :latex
        result = '+++'
        cite_data.cites.each do |cite|
          # NOTE: xelatex does not support "\citenp", so we output all
          # references as "cite" here.
          # result << "\\" << cite_data.type
          result << "\\" << 'cite'
          if cite.pages != ''
            result << "[p. " << cite.pages << "]"
          end
          result << "{" << "#{cite.ref}" << "},"
        end
        if result[-1] == ','
          result = result[0..-2]
        end
        result << "+++"
        return result
      else
        result = ''
        ob, cb = '(', ')'

        cite_data.cites.each_with_index do |cite, index|
          # before all items apart from the first, insert appropriate separator
          result << "#{separator} " unless index.zero?

          # @links requires adding hyperlink to reference
          result << "<<#{cite.ref}," if @links

          # if found, insert reference information
          unless biblio[cite.ref].nil?
            item = biblio[cite.ref].clone
            cite_text, ob, cb = make_citation item, cite.ref, cite_data, cite
          else
            puts "Unknown reference: #{cite.ref}"
            cite_text = "#{cite.ref}"
          end

          result << cite_text.html_to_asciidoc
          # @links requires finish hyperlink
          result << ">>" if @links
        end

        unless @links
          # combine numeric ranges
          if Styles.is_numeric? @style
            result = combine_consecutive_numbers result
          end
        end

        return include_pretext result, cite_data, ob, cb
      end
    end

    # Retrieve text for reference in given style
    # - ref is reference for item to give reference for
    def get_reference ref
      result = ""
      result << ". " if Styles.is_numeric? @style

      begin
        cptext = @citeproc.render :bibliography, id: ref
      rescue Exception => e
        puts "Failed to render #{ref}: #{e}"
      end
      result << "[[#{ref}]]" if @links
      if cptext.nil?
        return result+ref
      else
        result << cptext.first
      end

      return result.html_to_asciidoc
    end

    def separator
      if Styles.is_numeric? @style
        ','
      else
        ';'
      end
    end

    # Format pages with pp/p as appropriate
    def with_pp pages
      return '' if pages.empty?

      if @style.include? "chicago"
        pages
      elsif pages.include? '-'
        "pp.&#160;#{pages}"
      else
        "p.&#160;#{pages}"
      end
    end

    # Return page string for given cite
    def page_str cite
      result = ''
      unless cite.pages.empty?
        result << "," unless Styles.is_numeric? @style
        result << " #{with_pp(cite.pages)}"
      end

      return result
    end

    def include_pretext result, cite_data, ob, cb
      pretext = cite_data.pretext
      pretext += ' ' unless pretext.empty? # add space after any content

      if Styles.is_numeric? @style
        "#{pretext}#{ob}#{result}#{cb}"
      elsif cite_data.type == "cite"
        "#{ob}#{pretext}#{result}#{cb}"
      else
        "#{pretext}#{result}"
      end
    end

    # Numeric citations are handled by computing the position of the reference
    # in the list of used citations.
    # Other citations are formatted by citeproc.
    def make_citation item, ref, cite_data, cite
      if Styles.is_numeric? @style
        cite_text = if @numeric_in_appearance_order
                      "#{@citations.cites_used.index(cite.ref) + 1}"
                    else
                      "#{sorted_cites.index(cite.ref) + 1}"
                    end
        fc = '['
        lc = ']'
      else
        cite_text = @citeproc.process id: ref, mode: :citation

        fc = cite_text[0,1]
        lc = cite_text[-1,1]
        cite_text = cite_text[1..-2]
      end

      if Styles.is_numeric? @style
        cite_text << "#{page_str(cite)}"
      elsif cite_data.type == "citenp"
        cite_text.gsub!(item.year, "#{fc}#{item.year}#{page_str(cite)}#{lc}")
        cite_text.gsub!(", #{fc}", " #{fc}")
      else
        cite_text << page_str(cite)
      end

      cite_text.gsub!(",", "&#44;") if @links # replace comma

      return cite_text, fc, lc
    end

    def sorted_cites
      @citations.sorted_cites @biblio
    end

    def cites
      if Styles.is_numeric?(@style) and @numeric_in_appearance_order
        @citations.cites_used
      else
        sorted_cites
      end
    end

    BIBMACRO_FULL = /bibliography::(.*?)\[(\w+)?\]/
  end
end


