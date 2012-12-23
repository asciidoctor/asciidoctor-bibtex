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

	CITATION = /\[(cite|citenp):(([\w ]+):)?(\w+)(,([\w\.\- ]+))?\]/

	# -- utility functions
	
	def AsciidocBib.extract_cites line
		cites_used = []
		md = CITATION.match(line)
		while md
			cites_used << md[4]
			md = CITATION.match(md.post_match)
		end
		return cites_used
	end

  def AsciidocBib.add_ref filename
    file_dir = File.dirname(File.expand_path(filename))
    file_base = File.basename(filename, ".*")
    file_ext = File.extname(filename)
    return "#{file_dir}#{File::SEPARATOR}#{file_base}-ref#{file_ext}"
  end


end

