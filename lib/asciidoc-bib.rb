# asciidoc-bib.rb
#
# Copyright (c) Peter Lane, 2012.
# Released under Open Works License, 0.9.2

# monkey patch some convenience methods to Array
class Array
	def second
		self[1]
	end

	def third
		self[2]
	end

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

  # -- class for handling a bibliography

  class Biblio

    def initialize
      @store = {}
    end

		# retrieve citation text
		def get_citation ref
			if contains?(ref)
				return @store[ref].citation
			else
				puts "Unknown citation #{ref}"
				return ref
			end
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

		def author_harvard(authors=@author)
			authors.split("and").collect do |name|
				parts = name.strip.rpartition(" ")
				"#{parts.third}, #{parts.first}"
			end
		end

		def citation
			"(#{author_surnames.comma_and_join}, #{@year})"
		end
	end

  class Article < BibItem
    attr_accessor :journal, :volume, :number, :pages

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
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
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
			end 
			unless @publisher.nil?
				result << "(#{@publisher})"
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
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
			end 
			unless @editor.nil?
				result << "In #{author_harvard(editor).comma_and_join} (Eds.) "
			end
			unless @booktitle.nil?
				result << "_#{@booktitle}_ "
			end
			unless @publisher.nil?
				result << "(#{@publisher})"
			end
			unless @pages.nil?
				result << ", pp. #{@pages}"
			end
			result << "."
			return result
		end
  end

  class Manual < BibItem
    attr_accessor :note

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
			end 
			unless @note.nil?
				result << "(#{@note})"
			end
			result << "."
			return result
		end
  end

  class Misc < BibItem
    attr_accessor :how_published

		def reference
			result = ""
			unless @author.nil?
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
			end 
			unless @how_published.nil?
				result << "(#{@how_published})"
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
				result << "#{author_harvard.comma_and_join} "
			end
			unless @year.nil?
				result << "(#{@year}), "
			end
			unless @title.nil?
				result << "\"#{@title}\", "
			end 
			unless @school.nil?
				result << "(#{@school})"
			end
			result << "."
			return result
		end
	end

	# -- utility functions
	
	def AsciidocBib.extract_cites line
		cites_used = []
		line.split("[cite:").drop(1).each do |reftext|
			cites_used << reftext.partition("]").first
		end
		return cites_used
	end

  # -- read in a given bibliography file and return a biblio instance

  def AsciidocBib.read_bibliography filename
    biblio = Biblio.new
    
    begin
      File.open(filename) do |input|
				curr = nil
				ref = ""
        while ((line = input.readline) and (not input.eof?))
					line.strip!
					next if line.empty?
					if line.downcase.start_with? "@article"
						curr = Article.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@book"
						curr = Book.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@conference"
						curr = InCollection.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@incollection"
						curr = InCollection.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@inproceedings"
						curr = InCollection.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@manual"
						curr = Manual.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@misc"
						curr = Misc.new
						ref = line.split("{").second.gsub(",", "")
					elsif line.downcase.start_with? "@phdthesis"
						curr = PhdThesis.new
						ref = line.split("{").second.gsub(",", "")
					elsif line == "}"
						biblio[ref] = curr
						curr = nil
						ref = ""
					else
						fields = line.split "="
						begin
  						curr.send("#{fields.first.strip}=", 
												fields.second.strip.gsub(/{|}|,|\"/,"")
											 )
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

		File.new(filename).each_line do |line|
			AsciidocBib.extract_cites(line).each do |cite|
				unless cites_used.include? cite
					cites_used << cite
				end
			end
		end

		return cites_used
	end

	# -- read given text to add cites and biblio

	def AsciidocBib.add_citations(filename, cites_used, biblio)
		# TODO: improve this code
		ref_filename = "#{filename.rpartition(".").first}-ref.#{filename.rpartition(".").third}"

		puts "Writing file:	#{ref_filename}"
		output = File.new(ref_filename, "w")

    File.new(filename).each_line do |line|
			if line.strip == "[bibliography]"
				cites_used.sort_by do |ref|
					if biblio.contains? ref
						biblio[ref].author_harvard
					else 
						ref
					end
				end.each do |ref|
					output.puts biblio.get_reference ref
					output.puts
				end
			else
				extract_cites(line).each do |ref|
					line.gsub!("[cite:#{ref}]", biblio.get_citation(ref))
				end
				output.puts line
			end
		end

		output.close
	end

end

