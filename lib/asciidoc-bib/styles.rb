#
# styles.rb
# Simple checks on available styles through CSL
#

module AsciidocBib

  module Styles

    def Styles.available
      CSL::Style.ls
    end

    def Styles.default_style
      'apa'
    end

    def Styles.valid? style
      Styles.available.include? style
    end

    def Styles.is_numeric? style
      CSL::Style.load(style).citation_format == :numeric
    end
  end
end

