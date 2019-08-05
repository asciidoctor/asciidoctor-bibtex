#
# styles.rb
# Simple checks on available styles through CSL
#

module AsciidoctorBibtex

  module StyleUtils

    def StyleUtils.available
      CSL::Style.ls
    end

    def StyleUtils.default_style
      'apa'
    end

    def StyleUtils.valid? style
      Styles.available.include? style
    end

    def StyleUtils.is_numeric? style
      CSL::Style.load(style).citation_format == :numeric
    end
  end
end

