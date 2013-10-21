module AsciidocBib
  class Citation
    attr_reader :ref, :pages

    def initialize ref, pages=nil
      @ref = ref
      @pages = pages
    end
  end
end

