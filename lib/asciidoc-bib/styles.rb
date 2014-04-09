#
# styles.rb
# Definition of styles
#

module AsciidocBib

  module Styles

    # Valid reference styles
    def Styles.available
      CSL::Style.ls
    end

    # Make the default style simple APA
    def Styles.default_style
      'apa'
    end

    # Check if given style is a valid style
    def Styles.valid? style
      Styles.available.include? style
    end

    # Test here for any numeric styles for citeproc
    # TODO
    def Styles.is_numeric? style
      [
        "ieee",
        "vancouver-brackets",
        "vancouver-superscript-bracket-only-year",
        "vancouver-superscript",
        "vancouver"
      ].include? style
    end
  end
end

