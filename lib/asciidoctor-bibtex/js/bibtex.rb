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
        # return Entry.new(`#{@js_bibliography}.data.find(cite => cite.id === #{key})`)
        # return Entry.new(%x{#{@js_bibliography}.format('bibtex', { format: 'object',  entry: #{key}})})
        return Entry.new(%x{#{@js_bibliography}.format('bibtex', { format: 'object'}).find(cite => cite.label === #{key})})
      end
    end

    class Entry 
      attr_reader :author, :editor, :year

      def initialize(js_entry)
        puts "Entry!"
        `console.log(js_entry)`
        `console.log(js_entry.author)`
        # if `js_entry.hasOwnProperty('author')`
        #   @author = %x{js_entry.author.map(author => `${author.family}, ${author.given}`).join(' and ')}
        #   @editor = @author
        # else
        #   @author = nil
        #   @editor = %x{js_entry.editor.map(editor => `${editor.family}, ${editor.given}`).join(' and ')}
        # end
        # @year = `js_entry.year`
      end
    end
  end
end