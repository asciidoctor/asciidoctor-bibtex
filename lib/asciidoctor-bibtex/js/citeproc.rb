module AsciidoctorBibtex
  `const Cite = require('citation-js')`
  module CiteProc
    class Processor
      attr_reader :style, :format, :locale

      def initialize(options) 
        @style = options[:style]
        @format = options[:format]
        @locale = options[:locale]
      end 

      def import(js_bibliography)
        @js_bibliography = js_bibliography
      end

      def render(mode, cite_data) 
        case mode
        when :bibliography
          return %x{#{@js_bibliography}.format('bibliography', { 
            entry: #{cite_data[:id]}, 
            template:  #{@template},
            locale:  #{@locale}
          })}, ""
        when :citation
          return %x{#{@js_bibliography}.format('citation', { 
            entry: #{cite_data[:id]},
            template:  #{@template},
            locale:  #{@locale}
          })}
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end
    end
  end
end