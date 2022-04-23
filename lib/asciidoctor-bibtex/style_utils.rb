#
# styles.rb
# Simple checks on available styles through CSL
#

#
# styles.rb
# Simple checks on available styles through CSL
#

if RUBY_ENGINE != 'opal'
  require 'citeproc'
  require 'csl/styles'
end

# TODO: Implement CSL

module AsciidoctorBibtex
  module StyleUtils
  #   def self.available
  #     CSL::Style.ls
  #   end

  #   def self.default_style
  #     'apa'
  #   end

  #   def self.valid?(style)
  #     Styles.available.include? style
  #   end

    def self.is_numeric?(style)
      false
      # CSL::Style.load(style).citation_format == :numeric
    end
  end
end
