# Class to read in asciidoc-bibtex options from command-line, and 
# store results in an accessible form.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'optparse'

module AsciidoctorBibtex
  class Options
    attr_reader :bibfile, :filename, :links, :style, :output

    def initialize(program_name = 'asciidoc-bibtex')
      @bibfile = ''
      @links = true
      @numeric_order = :alphabetical
      @style = AsciidoctorBibtex::Styles.default_style
      @program_name = program_name
      @output = "asciidoc"
    end

    # Public: Parse options from commandline.
    # This function is used by asciidoc-bib command.
    def parse!(args = ARGV)
      options = OptionParser.new do |opts|
        opts.banner = "Usage: #{@program_name} filename"
        opts.on("-h", "--help", "help message") do |v|
          puts "#{@program_name} #{AsciidoctorBibtex::VERSION}"
          puts
          puts options
          puts
          puts "All styles available through CSL are supported."
          puts "The default style is 'apa'."
          exit!
        end
        opts.on("-b", "--bibfile FILE", "location of bib file") do |v|
          @bibfile = v
        end
        opts.on("-n", "--no-links", "do not add internal links") do |v|
          @links = false
        end
        opts.on('', '--numeric-alphabetic-order', 'sort numeric styles in alphabetical order (DEFAULT)') do |v|
          @numeric_order = :alphabetical
        end
        opts.on('', '--numeric-appearance-order', 'sort numeric styles in order of appearance') do |v|
          @numeric_order = :appearance
        end
        opts.on("-s", "--style STYLE", "reference style") do |v|
          @style = v
        end
        opts.on("--output-style OUTPUT_STYLE", "Output style (asciidoc or latex)") do |v|
          @output = v
        end
        opts.on("-v", "--version", "show version") do |v|
          puts "#{@program_name} version #{AsciidoctorBibtex::VERSION}"
          exit!
        end
      end

      begin
        options.parse! args
      rescue 
        puts options
        exit!
      end

      # unless specified by caller, try to find the bibliography
      if @bibfile.empty?
        @bibfile = AsciidoctorBibtex::FileHandlers.find_bibliography "."
        if @bibfile.empty?
          @bibfile = AsciidoctorBibtex::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
      end
      if @bibfile.empty?
        puts "Error: could not find a bibliography file"
        exit
      end
      unless AsciidoctorBibtex::Styles.valid? @style
        puts "Error: style #{@style} was not one of the available styles"
        exit
      end

      if args.length == 1
        @filename = args[0]
      else
        puts "Error: a single file to convert must be given"
        exit
      end

      puts "Reading biblio: #{@bibfile}"
      puts "Reference style: #{@style}"
      puts "Numerical order: #{@numeric_order}"
      puts "Output style: #{@output}"
    end
    
    # Public: Parse values given `attrs`
    # This function is used by asciidoctor preprocessor to determine options
    # from document attributes. According to the attribute preccedence rule,
    # attrs_cli > attrs_src > default
    def parse_attributes(attrs_cli, attrs_src)
      if attrs_cli['bib-style']
        @style = attrs_cli['bib-style']
      elsif attrs_src['bib-style']
        @style = attrs_src['bib-style']
      end
      if attrs_cli['bib-file']
        @bibfile = attrs_cli['bib-file']
      elsif attrs_src['bib-file']
        @bibfile = attrs_src['bib-file']
      end
      order = nil
      if attrs_cli['bib-numeric-order']
        order = attrs_cli['bib-numeric-order']
      elsif attrs_src['bib-numeric-order']
        order = attrs_src['bib-numeric-order']
      end
      if order == nil
        @numeric_order = :appearance
      elsif order == "appearance"
        @numeric_order = :appearance
      elsif order == "alphabetical"
        @numeric_order = :alphabetical
      else
        raise RuntimeError.new "Unknown numeric order: #{order}"
      end
      if attrs_cli['bib-no-links']
        @links = false
      elsif attrs_src['bib-no-links']
        @links = false
      end
      if attrs_cli['bib-output']
        @output = attrs_cli['bib-output']
      elsif attrs_src['bib-output']
        @output = attrs_src["bib-output"]
      else
        @output = "asciidoc"
      end

      # unless specified by caller, try to find the bibliography
      if @bibfile.empty?
        @bibfile = AsciidoctorBibtex::FileHandlers.find_bibliography "."
        if @bibfile.empty?
          @bibfile = AsciidoctorBibtex::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
      elsif not File.file? @bibfile
        puts "Error: bibliography file '#{@bibfile}' does not exist"
        exit
      end
      if @bibfile.empty?
        puts "Error: could not find a bibliography file"
        exit
      end
      unless AsciidoctorBibtex::Styles.valid? @style
        puts "Error: style #{@style} was not one of the available styles"
        exit
      end

      puts "Reading biblio: #{@bibfile}"
      puts "Reference style: #{@style}"
      puts "Numerical order: #{@numeric_order}"
      puts "Output style: #{@output}"
    end

    def numeric_in_appearance_order?
      @numeric_order == :appearance
    end
  end
end
