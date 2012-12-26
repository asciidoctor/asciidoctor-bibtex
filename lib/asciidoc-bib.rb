# asciidoc-bib.rb
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

require_relative "lib/asciidoc_classes.rb"
require_relative "lib/asciidoc_helpers.rb"

module AsciidocBib

  # -- locate a bibliography file to read in given dir

  def AsciidocBib.find_bibliography dir
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

  # -- read in a given bibliography file and return a biblio instance

  def AsciidocBib.read_bibliography filename
    biblio = Biblio.new
    
    begin
      File.open(filename) do |input|
				curr = nil
				ref = ""
        while ((not input.eof?) and (line = input.readline))
					line.strip!
					next if line.empty?
					md = /@([\w-]+){([\w-]+),/.match(line)
					if not md.nil?
						type = md[1]
						ref = md[2]
						curr = case type.downcase
									 when "article" then Article.new
									 when "book" then   Book.new
									 when "conference", "incollection", "inproceedings" then
										 InCollection.new
									 when "manual" then Manual.new
									 when "misc" then Misc.new
									 when "phdthesis" then PhdThesis.new
									 end
					elsif line == "}"
						biblio[ref] = curr
						curr = nil
						ref = ""
					else # TODO: correctly parse bibtex file
						fields = line.partition "="
						key_term = fields.first.strip
						val_term = fields.third.strip
						if val_term.reverse[0] == "," and (val_term.reverse[1] == "}" or val_term.reverse[1] == "\"")
							val_term = val_term[0..val_term.length-2] # remove comma
						end
						until (val_term[0] == "{" and val_term[val_term.length - 1] == "}") or (val_term[0] == "\"" and val_term[val_term.length - 1] == "\"")
							val_term += " " + input.readline.strip
							if val_term.reverse[0] == "," and (val_term.reverse[1] == "}" or val_term.reverse[1] == "\"")
								val_term = val_term[0..val_term.length-2] # remove comma
							end
						end
						begin
  						curr.send("#{key_term}=", val_term[1..val_term.length-2])
						rescue # ignore errors
						end
					end
        end
      end
    rescue Exception => e # abort on any error
      puts "Error in reading bibliography #{e}"
      exit
    end

    return biblio
  end

	# -- read given text to locate cites, return list of used references

	def AsciidocBib.read_citations filename
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
		  	  AsciidocBib.extract_cites(line).each do |cite|
			  	  unless cites_used.include? cite
				  	  cites_used << cite
				    end
  			  end
        end
		  end
    end until files_to_process.empty?

		return cites_used
	end

	# -- read given text to add cites and biblio

	def AsciidocBib.add_citations(filename, cites_used, biblio)
    files_to_process = [filename]
    files_done = []

    begin
      curr_file = files_to_process.shift
      files_done << curr_file

      ref_filename = AsciidocBib.add_ref(curr_file)
		  puts "Writing file:	#{ref_filename}"
  		output = File.new(ref_filename, "w")

      File.new(curr_file).each_line do |line|
        if line.include?("include::")
          line.split("include::").drop(1).each do |filetxt|
            ifile = filetxt.partition(/\s|\[/).first
            file = File.expand_path(ifile)
            files_to_process << file unless files_done.include?(file)
            # make sure included file points to the -ref version
            line.gsub!("include::#{ifile}", "include::#{AsciidocBib.add_ref(file)}")
          end
          output.puts line
  			elsif line.strip == "[bibliography]"
	  			cites_used.sort_by do |ref|
		  			if biblio.contains? ref
			  			biblio[ref].author_chicago
				  	else 
  						[ref]
	  				end
		  		end.each do |ref|
			  		output.puts biblio.get_reference(ref).gsub("{","").gsub("}","")
  					output.puts
	  			end
		  	else
					md = CITATION_FULL.match(line)
					while md
						cite_refs = []
						cite_pages = []
						cite_text = md[4]
						cm = CITATION.match(cite_text)
						while cm
							# process ref 
							cite_refs << cm[1]
							cite_pages << cm[3]
							# look for next ref within citation
							cm = CITATION.match(cm.post_match)
						end
						# replace text on line
						line.gsub!(md[0],
											 biblio.get_citation(md[1], md[3], cite_refs, cite_pages)
											)
						# look for next citation on line
						md = CITATION_FULL.match(md.post_match)
					end

	  			output.puts line
		  	end
  		end

  		output.close
    end until files_to_process.empty?
  end
end

