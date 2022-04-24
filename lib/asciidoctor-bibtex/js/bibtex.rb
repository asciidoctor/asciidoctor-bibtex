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
        return Entry.new(%x{#{@js_bibliography}.format('bibtex', { format: 'object'}).find(cite => cite.label === #{key})})
      end
    end

    class Entry 
      attr_reader :author, :editor, :year

      def initialize(js_entry)
        @author = `js_entry.properties.author`
        @editor = `js_entry.properties.editor`
        @year = `js_entry.properties.year`
      end
    end
  end
end