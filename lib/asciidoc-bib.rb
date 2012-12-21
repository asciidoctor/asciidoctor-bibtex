
module AsciidocBib

  # -- locate a bibliography file to read in given dir

  def AsciidocBib.find_bibliography dir
    begin
      Dir.chdir dir
      candidates = Dir.glob("*.bib")
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

  class Article
    attr_accessor :author, :title, :journal, :volume, :number, :pages, :year
  end

  class Book
    attr_accessor :author, :title, :publisher, :year
  end

  class InCollection
    attr_accessor :author, :title, :pages, :editor, :booktitle, :publisher, :year
  end

  class InProceedings
    attr_accessor :author, :title, :pages, :editor, :booktitle, :publisher, :year
  end

  class Misc
    attr_accessor :author, :title, :how_published, :year
  end

  # -- read in a given bibliography file and return a biblio instance

  def AsciidocBib.read_bibliography filename
    biblio = Biblio.new
    
    begin
      File.open(filename) do |input|
        while ((line = input.readline) and (not input.eof?))
          puts "Line: #{line}"
        end
      end
    rescue Exception => e # abort on any error
      puts "Error in reading bibliography #{e}"
      exit
    end

    return biblio
  end

end

