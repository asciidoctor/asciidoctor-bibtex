#
# processor.rb
# Contains top-level definitions for asciidoc-bib
#

module AsciidocBib

  # Valid reference styles, first item of Styles is default
  Styles = [
    "apa",
    "bibtex",
    "chicago-annotated-bibliography",
    "chicago-author-date-basque",
    "chicago-author-date-de",
    "chicago-author-date",
    "chicago-dated-note-biblio-no-ibid",
    "chicago-fullnote-bibliography-bb",
    "chicago-fullnote-bibliography-delimiter-fixes",
    "chicago-fullnote-bibliography-no-ibid-delimiter-fixes",
    "chicago-fullnote-bibliography-no-ibid",
    "chicago-fullnote-bibliography",
    "chicago-library-list",
    "chicago-note-biblio-no-ibid",
    "chicago-note-bibliography",
    "chicago-quick-copy",
    "ieee",
    "mla-notes",
    "mla-underline",
    "mla-url",
    "mla",
    "vancouver-brackets",
    "vancouver-superscript-bracket-only-year",
    "vancouver-superscript",
    "vancouver"
  ]

  # Test here for any numeric styles for citeproc
  def is_numeric? style
    [
      "ieee",
      "vancouver-brackets",
      "vancouver-superscript-bracket-only-year",
      "vancouver-superscript",
      "vancouver"
    ].include? style
  end

  # Locate a bibliography file to read in given dir
  def find_bibliography dir
    begin
      candidates = Dir.glob("#{dir}/*.bib")
      if candidates.empty?
        return ""
      else
        return candidates.first
      end
    rescue # catch all errors, and return empty string
      return ""
    end
  end

  # Read in a given bibliography file and return a biblio instance
  def read_bibliography filename
    BibTeX.open(filename)
  end

  # Read given text to locate cites, return list of used references
  def read_citations filename
    puts "Reading file: #{filename}"
    cites_used = []
    files_to_process = [filename]
    files_done = []

    begin
      files_done << files_to_process.first
      File.new(files_to_process.shift).each_line do |line|
        if line.include?("include::")
          line.split("include::").drop(1).each do |filetxt|
            file = File.expand_path(filetxt.partition(/\s|\[/).first)
              files_to_process << file unless files_done.include?(file)
          end
        else
          extract_cites(line).each do |cite|
            unless cites_used.include? cite
              cites_used << cite
            end
          end
        end
      end
    end until files_to_process.empty?

    return cites_used
  end

  # Read given text to add cites and biblio to a new file
  # Order is always decided by author surname first with year.
  # If no author present, then use editor field.
  # Links indicates if internal links to be added
  def add_citations(filename, cites_used, biblio, links, style)
    files_to_process = [filename]
    files_done = []

    sorted_cites = cites_used.sort_by do |ref|
      unless biblio[ref].nil?
        # extract the reference, and uppercase. 
        # Remove { } from grouped names for sorting.
        author = biblio[ref].author
        if author.nil?
          author = biblio[ref].editor
        end
        author_chicago(author).collect {|s| s.upcase.gsub("{","").gsub("}","")} + [biblio[ref].year]
      else 
        [ref]
      end
    end

    begin
      curr_file = files_to_process.shift
      files_done << curr_file

      ref_filename = add_ref(curr_file)
      puts "Writing file:	#{ref_filename}"
      output = File.new(ref_filename, "w")

      File.new(curr_file).each_line do |line|
        begin # catch any errors, and ensure the lines of text are written
          if line.include?("include::")
            line.split("include::").drop(1).each do |filetxt|
              ifile = filetxt.partition(/\s|\[/).first
                file = File.expand_path(ifile)
                files_to_process << file unless files_done.include?(file)
                # make sure included file points to the -ref version
                line.gsub!("include::#{ifile}", "include::#{add_ref(file)}")
            end
            output.puts line
          elsif line.strip == "[bibliography]"
            sorted_cites.each do |ref|
              reftext = get_reference(biblio, ref, links, style)
              output.puts reftext
              output.puts
            end
          else
            md = CITATION_FULL.match(line)
            while md
              cite_refs, cite_pages = extract_refs_pages md[4]
              # replace text on line
              line.gsub!(md[0],
                         get_citation(biblio, md[1], md[3], 
                                      cite_refs, cite_pages, 
                                      links, sorted_cites, style)
                        )
                        # look for next citation on line
                        md = CITATION_FULL.match(md.post_match)
            end

            output.puts line
          end
        rescue # Any errors, just output the line
          output.puts line
        end
      end

      output.close
    end until files_to_process.empty?
  end
end

