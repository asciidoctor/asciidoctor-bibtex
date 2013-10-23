#
# Manage the current set of citations, the document settings, and 
# and main operations.
#

module AsciidocBib
  class Processor

    # Top-level method to include citations in given asciidoc file
    def Processor.run filename, bibfile, links, style
      processor = Processor.new BibTeX.open(bibfile), links, style
      processor.read_filenames filename
      processor.read_citations 
      processor.add_citations
    end

    attr_reader :biblio, :links, :style, :citations

    def initialize biblio, links, style
      @biblio = biblio
      @links = links
      @style = style
      @citations = Citations.new
      @filenames = Set.new
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
        ref_filename = FileUtils.add_ref(curr_file)
        puts "Writing file:	#{ref_filename}"
        output = File.new(ref_filename, "w")

        IO.foreach(curr_file) do |line|
          begin # catch any errors, and ensure the lines of text are written
            case line.strip 
            when "[bibliography]"
              output_bibliography output
            else
              output_cite_completed_line line, output
            end
          rescue # Any errors, just output the line
            output.puts line
          end
        end

        output.close
      end 
    end

    def output_bibliography output
      @citations.cites_used.each do |ref|
        reftext = @citations.get_reference(@biblio, ref, @links, @style)
        output.puts reftext
        output.puts
      end
    end

    # Retrieve text for reference in given style
    # - ref is reference for item to give reference for
    def get_reference ref
      result = ""
      result << ". " if Styles.is_numeric?(@style)

      item = @biblio[ref]
      item = item.convert_latex unless item.nil?

      result << "[[#{ref}]]" if @links
      return result+ref if item.nil?

      cptext = CiteProc.process item.to_citeproc, :style => @style, :format => :html
      result << cptext unless cptext.nil?

      result.html_to_asciidoc
    end

    # For each citation in given line, expand into complete citation text
    # before outputting the line
    def output_cite_completed_line output, line
      @citations.retrieve_citations(line).each do |citation|
        line.gsub!(citation.original, @citations.complete_citation(citation))
      end
      output.puts line
    end
  end
end

