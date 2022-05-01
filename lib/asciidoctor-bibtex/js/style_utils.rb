module AsciidoctorBibtex
  `const { styles } = require('csl-js')`
  module StyleUtils
    def self.is_numeric?(style)
      return `styles.get(#{style}).info.category['citation-format'] === 'numeric'`
    end
  end
end
