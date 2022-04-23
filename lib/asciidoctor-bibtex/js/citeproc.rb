module AsciidoctorBibtex
  `const __cite__ = require('citation-js')`
  module CiteProc
    class Processor
      # TODO
      def import(*arguments)
        puts arguments
        arguments.each do |argument|
          puts argument
        end
      end
    end
  end
end