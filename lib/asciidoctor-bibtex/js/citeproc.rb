module AsciidoctorBibtex
  `const {Cite, plugins} = require('@citation-js/core')`
  `require('@citation-js/plugin-csl')`
  `const Fs = require('fs')`
  `const { styles } = require('csl-js')`

  module CiteProc
    class Processor
      attr_reader :style, :format, :locale

      def initialize(options) 
        @style = options[:style]
        @format = options[:format]
        @locale = options[:locale]

        styleFilePath = "../vendor/styles/#{@style}.csl"
        raise "Bibtex-style '#{@style}' does not exist" unless `Fs.existsSync(#{styleFilePath})`

        styleFile = File.read(styleFilePath, encoding: 'utf-8')
        %x{
          let csl_config = plugins.config.get('@csl')
          csl_config.templates.add(#{style}, #{styleFile})

          // This is used for style_utils.rb as the lib itself doesn't expose infos about the csl styles
          styles.set(#{style}, #{styleFile})
        }
      end 

      def import(js_bibliography)
        @js_bibliography = js_bibliography
      end

      def render(mode, cite_data) 
        case mode
        when :bibliography
          return %x{#{@js_bibliography}.format('bibliography', { 
            entry: #{cite_data[:id]}, 
            template:  #{@style},
            locale:  #{@locale}
          })}, ""
        when :citation
          return %x{#{@js_bibliography}.format('citation', { 
            entry: #{cite_data[:id]},
            template:  #{@style},
            locale:  #{@locale}
          })}
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end
    end
  end
end