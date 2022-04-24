module AsciidoctorBibtex
  `const {Cite, plugins} = require('@citation-js/core')`
  `require('@citation-js/plugin-bibtex')`
  require "native"
  
  module BibTeX
    def self.open(path, options = {})
      file = File.read(path, encoding: 'utf-8')
      return Bibliography.new(`new Cite(#{file})`)
    end

    class Bibliography
      def initialize(js_bibliography)
          @js_bibliography = js_bibliography

          @entries = Hash.new(%x{#{@js_bibliography}.format('bibtex', { format: 'object'}).reduce((map, cite) => {
              map[cite.label] = cite;
              return map;
            }, {})})
          @entries = @entries.transform_values! { |bibtex_entry| Entry.new(bibtex_entry) }
      end

      def to_citeproc(options = {})
        return @js_bibliography
      end

      def [](key)
        return @entries[key]
      end
    end

    class Entry 
      attr_reader :author, :editor, :year

      def initialize(bibtex_entry)
        @author = bibtex_entry[:properties][:author]
        @editor = bibtex_entry[:properties][:editor]
        @year = bibtex_entry[:properties][:year]
      end
    end
  end
end