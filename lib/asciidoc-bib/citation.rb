module AsciidocBib
  class Citation
    attr_reader :ref, :pages

    def initialize ref, pages
      @ref = ref
      @pages = pages
      # clean up pages
      @pages.gsub!("--","-") unless @pages.nil?
    end

    def == other
      @ref == other.ref && @pages == other.pages
    end
  end
end

