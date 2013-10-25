#
# styles.rb
# Definition of styles
#

module AsciidocBib

  module Styles

    # Valid reference styles
    def Styles.available
      [
        "apa",
        "bibtex",
        "chicago-annotated-bibliography",
        "chicago-author-date-basque",
        "chicago-author-date-de",
        "chicago-author-date",
        "chicago-dated-note-biblio-no-ibid",
        "chicago-fullnote-bibliography-bb",
        "chicago-fullnote-bibliography-delimiter-fixes",
        "chicago-fullnote-bibliography-no-ibid-delimiter-fixes",
        "chicago-fullnote-bibliography-no-ibid",
        "chicago-fullnote-bibliography",
        "chicago-library-list",
        "chicago-note-biblio-no-ibid",
        "chicago-note-bibliography",
        "chicago-quick-copy",
        "ieee",
        "mla-notes",
        "mla-underline",
        "mla-url",
        "mla",
        "vancouver-brackets",
        "vancouver-superscript-bracket-only-year",
        "vancouver-superscript",
        "vancouver"
      ]
    end

    # Make the default style the first one in the list
    def Styles.default_style
      Styles.available.first
    end

    # Check if given style is a valid style
    def Styles.valid? style
      Styles.available.include? style
    end

    # Test here for any numeric styles for citeproc
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

