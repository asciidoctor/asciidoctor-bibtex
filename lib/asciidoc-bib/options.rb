# Class to read in asciidoc-bib options from command-line, and 
# store results in an accessible form.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'optparse'

module AsciidocBib
  class Options
    attr_reader :bibfile, :filename, :links, :style

    def initialize(program_name = 'asciidoc-bib')
      @bibfile = ''
      @links = true
      @numeric_order = :alphabetical
      @style = AsciidocBib::Styles.default_style
      @program_name = program_name
    end

    # Public: Parse options from commandline.
    # This function is used by asciidoc-bib command.
    def parse!(args = ARGV)
      options = OptionParser.new do |opts|
        opts.banner = "Usage: #{@program_name} filename"
        opts.on("-h", "--help", "help message") do |v|
          puts "#{@program_name} #{AsciidocBib::VERSION}"
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
        opts.on("-v", "--version", "show version") do |v|
          puts "#{@program_name} version #{AsciidocBib::VERSION}"
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
        @bibfile = AsciidocBib::FileHandlers.find_bibliography "."
        if @bibfile.empty?
          @bibfile = AsciidocBib::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
      end
      if @bibfile.empty?
        puts "Error: could not find a bibliography file"
        exit
      end
      unless AsciidocBib::Styles.valid? @style
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
    end
    
    # Public: Parse values given `attrs`
    # This function is used by asciidoctor preprocessor to determine options
    # from document attributes.
    def parse_attributes(attrs)
      if attrs['bib-style']
        @style = attrs['bib-style']
      end
      if attrs['bib-file']
        @bibfile = attrs['bib-file']
      end
      if attrs['bib-numeric-order']
        order = attrs['bib-numeric-order']
        if order == "appearance"
          @numeric_order = :appearance
        elsif order == "alphabetical"
          @numeric_order = :alphabetical
        else
          raise RuntimeError.new "Unknown numeric order: #{order}"
        end
      end
      if attrs['bib-no-links']
        @links = false
      end

      # unless specified by caller, try to find the bibliography
      if @bibfile.empty?
        @bibfile = AsciidocBib::FileHandlers.find_bibliography "."
        if @bibfile.empty?
          @bibfile = AsciidocBib::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
      end
      if @bibfile.empty?
        puts "Error: could not find a bibliography file"
        exit
      end
      unless AsciidocBib::Styles.valid? @style
        puts "Error: style #{@style} was not one of the available styles"
        exit
      end

      puts "Reading biblio: #{@bibfile}"
      puts "Reference style: #{@style}"
      puts "Numerical order: #{@numeric_order}"
    end

    def numeric_in_appearance_order?
      @numeric_order == :appearance
    end
  end
end

