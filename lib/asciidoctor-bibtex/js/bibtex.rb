module AsciidoctorBibtex
  `const Cite = require('citation-js')`
  module BibTeX
    def self.open(path, options = {})
      file = File.read(path, encoding: 'utf-8')
      return Bibliography.new(`new Cite(#{file})`)
    end

    class Bibliography
      def initialize(js_bibliography)
          @js_bibliography = js_bibliography
      end

      def to_citeproc(options = {})
        return @js_bibliography
      end

      def [](key)
        return Entry.new(`#{@js_bibliography}.data.find(cite => cite.id === #{key})`)
      end
    end

    class Entry 
      attr_reader :author, :editor, :year

      def initialize(js_entry)
        # @author = `js_entry.author`
        @author = %x{console.log(js_entry.author.map(author => `${author.family}, ${author.given}`).join(' and '))}
        @editor = @author
        @year = `js_entry.year`
      end
    end
  end
end