module AsciidoctorBibtex
  `const Cite = require('citation-js')`
  module CiteProc
    class Processor
      def import(js_bibliography)
        @js_bibliography = js_bibliography
      end

      def render(mode, cite_data) 
        case mode
        when :bibliography
           return %x{#{@js_bibliography}.format('bibliography', { entry: #{cite_data[:id]}})}, ""
        when :citation
          return %x{#{@js_bibliography}.format('citation', { entry: #{cite_data[:id]}})}
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end
    end
  end
end