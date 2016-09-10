# asciidoctor-bibtex: add bibtex functionality to asciidoc

asciidoctor-bibtex adds bibtex support for asciidoc documents by introducing
two new macros: `cite:[KEY]` and `bibliography::[]`. Citations are parsed and
replaced with formatted inline texts, and reference lists are automatically
generated and inserted into where `bibliography::[]` is placed. 

asciidoctor-bibtex is designed to be used as an extension to
[asciidoctor](http://asciidoctor.org), although it supports asciidoc to
asciidoc transformation at the moment. Thus this extension can be used
together with other asciidoctor extensions such as
[asciidoctor-mathematical][] and [asciidoctor-pdf][] to enrich your
asciidoc experience.

[asciidoctor-mathematical]: https://github.com/asciidoctor/asciidoctor-mathematical
[asciidoctor-pdf]: https://github.com/asciidoctor/asciidoctor-pdf

## History

asciidoctor-bibtex starts as a fork of [asciidoc-bib][] and goes along a
different way. The major reason for the fork at the time was the differences in
citation and bibliography macros. asciidoc-bib failed to follow the grammar of
macros in asciidoc, thus to avoid breaking existing documents, a fork is
inevitable. Other reasons include the inability to use asciidoctor arguments
in asciidoc-bib. 

While [asciidoc-bib][] focuses on replacing citations in the original
documents and produces new asciidoc documents, asciidoctor-bibtex focuses on
compatibility with asciidoctor and other asciidoctor extensions at the very
beginning. As time passes, asciidoctor-bibtex diverges significantly from its
ancesstor. For example, asciidoctor-bibtex now supports generating real bibtex
ciations and bibliography, so it can be used together with
[asciidoctor-latex][] for native bibtex support.

[asciidoc-bib]: https://github.com/petercrlane/asciidoc-bib
[asciidoc-latex]: https://github.com/asciidoctor/asciidoctor-latex

## Install

    gem install asciidoctor-bibtex

Installs two executable programs:

- 'asciidoc-bibtex' for transforming source text into asciidoc 
- 'asciidoctor-bibtex' uses asciidoctor extension for single-pass output

asciidoctor-bibtex depends on
[bibtex-ruby](http://github.com/inukshuk/bibtex-ruby),
[citeproc-ruby](http://github.com/inukshuk/citeproc-ruby) and
[csl-styles](http://github.com/inukshuk/csl-styles).  (Ensure 'ruby-dev' and
'libxslt1-dev' are installed, so the dependencies will compile.)

[asciidoctor](https://github.com/asciidoctor/asciidoctor) must also be
installed for 'asciidoctor-bibtex' to work. asciidoctor version 1.5.2 or
higher is required.

## Usage

There are three ways of using asciidoctor-bibtex.

The first is required if using _asciidoc_.  'asciidoc-bibtex' works by transforming an asciidoc document containing syntax to include citations and a bibliography. The transformed document will contain a complete reference and bibliography list where indicated, and can then be processed further by asciidoc's toolchain to produce a completed document.

The second is to use 'asciidoctor-bibtex' to transform your bibtex-enabled documents directly to any backend format supported by asciidoctor. It uses the asciidoctor extension mechanism to hook in the asciidoctor preprocessing process. It support all asciidoctor command-line options.

The third is to use asciidoctor-bibtex as an asciidoctor extension. It works the same way as the second approach. In addition, one can use other extensions together to provides even richer functionality. 

Styles must be one of those supported by CSL: https://github.com/citation-style-language/styles

### Citation syntax

Syntax for inserting a citation is the following inline macro:

    cite|citenp:[ref(pages)]

where '(pages)' is optional.  The ref and optional pages may be repeated multiple times, separated by ','.  A citation _must_ be complete on a single line of text.

Examples of "chicago-author-date" style:

`cite:[Lane12]` becomes "(Lane 2012)"

`citenp:[Lane12]` becomes "Lane (2012)"

`cite:[Lane12(59)]` becomes "(Lane 2012, 59)"

For *apa* (Harvard-like) style:

`cite:[Lane12]` becomes "(Lane, 2012)"

`citenp:[Lane12]` becomes "Lane (2012)"

`cite:[Lane12(59)]` becomes "(Lane, 2012, p.59)"

For *ieee*, a numeric style:

`cite:[Lane12,Lane11]` becomes "[1, 2]"

### Place bibliography in text

`bibliography::[]` on a line by itself.

### Processing Text: Asciidoctor

    asciidoctor-bibtex [OPTIONS] filename

Looks for a bib file in current folder and in ~/Documents.

Outputs an html file, including all citations and references.

asciidoctor-bibtex support all command-line options of asciidoctor, for example, use the follow command to output docbook file:

    asciidoctor-bibtex -b docbook filename

One may also use as an asciidoctor extension, for example:

    asciidoctor -r asciidoctor-bibtex -r asciidoctor-pdf -b pdf filename

Options are set through the command-line using the asciidoctor attributes
setting syntax:

    asciidoctor-bibtex -h

or through AsciidoctorBibtex related options:

      -a bibtex-file=FILENAME    Set BibTex filename (default: auto-find)
      -a bibtex-style=STYLE      Set BibTex items style (default: apa)
      -a bibtex-order=<alphabetical|appearance>
                            Set citation order scheme (default: alphabetical)

### Processing text: Asciidoc

    asciidoc-bibtex filename.txt

Looks for a bib file in current folder and in ~/Documents.

Outputs a new file: filename-ref.txt which includes your references.

asciidoc-bibtex supports the same command-line options as asciidoc-bib. The only difference is the citation and bibliography syntex.

## License

The files within this project may be distributed under the terms of 
the Open Works License: http://owl.apotheon.org

## Links

See https://github.com/petercrlane/asciidoc-bib for the original asciidoc-bib.
