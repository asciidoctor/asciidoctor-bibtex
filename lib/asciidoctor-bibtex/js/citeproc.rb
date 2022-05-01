module AsciidoctorBibtex
  `const {Cite, plugins} = require('@citation-js/core')`
  `require('@citation-js/plugin-csl')`
  `const { styles } = require('csl-js')`
  `const path = require('path')`

  module CiteProc
    class Processor
      attr_reader :style, :format, :locale

      def initialize(options) 
        @style = options[:style]
        @format = options[:format]
        @locale = options[:locale]

        styleFilePath = "../vendor/styles/#{@style}.csl"
        styleFilePath = `path.resolve(__dirname, #{styleFilePath})`
        raise "bibtex-style '#{@style}' does not exist" unless File.file?(styleFilePath)

        localeFilePath = "../vendor/locales/locales-#{@locale}.xml"
        localeFilePath = `path.resolve(__dirname, #{localeFilePath})`
        raise "bibtex-locale '#{@locale}' does not exist" unless  File.file?(localeFilePath)

        styleFile = File.read(styleFilePath, encoding: 'utf-8')
        localeFile = File.read(localeFilePath, encoding: 'utf-8')
        %x{
          let csl_config = plugins.config.get('@csl')
          csl_config.templates.add(#{style}, #{styleFile})
          csl_config.locales.add(#{locale}, #{localeFile})

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
            template: #{@style},
            lang: #{@locale}
          })}, ""
        when :citation
          return %x{#{@js_bibliography}.format('citation', { 
            entry: #{cite_data[:id]},
            template: #{@style},
            lang: #{@locale}
          })}
        else
          raise ArgumentError, "cannot render unknown mode: #{mode.inspect}"
        end
      end
    end
  end
end