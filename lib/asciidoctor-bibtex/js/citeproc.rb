module AsciidoctorBibtex
  `const Cite = require('citation-js')`
  module CiteProc
    class Processor
      def import(js_bibliography)
        @js_bibliography = js_bibliography
      end

      def render(mode, cite_data) 
        js_cite = `new Cite(#{@js_bibliography}.data.find(cite => cite.id === #{cite_data[:id]}))`

        case mode
        when :bibliography
           return %x{#{js_cite}.format('bibliography')}, ""
        when :citation
          return %x{#{js_cite}.format('citation')}
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end
    end
  end
end