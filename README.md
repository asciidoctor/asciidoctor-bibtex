# asciidoctor-bibtex: add bibtex functionality to asciidoc

asciidoctor-bibtex is a fork of [asciidoc-bib](https://github.com/petercrlane/asciidoc-bib) It generates in-text references and a reference list for an asciidoc file, using a bibtex file as a source of citation information. However, asciidoctor-bibtex proposes a different citation and reference grammar, which resembles the bibtex grammar in LaTeX. The grammar follows asciidoc inline and block macro semantics.

## Why a fork

When I began switching from latex/word to asciidoc, I searched for an easy way to integrate bibtex like references into asciidoc. Then I came across asciidoc-bib, which nearly meet my needs. I can insert citations, generate automatically a complete reference list. But there are aspects in asciidoc-bib that are not pleasing to work with.

The first is the overriding of `[bibliography]`. Asciidoctor introduces `[xxx]` as an mechanism to customize block styles, roles, etc.  `[bibliography]` is reserved for the bibliography section style. asciidoc-bib breaks it and there is no apparent way to fix it.

The second is the grammar inconsistency with the rest of asciidoc. The `[cite:xxx]` is actually an inline macro but it does not follow the grammar of inline macros. This makes asciidoc-bib not that confortable to write with since it breaks the semantic memory.

The last is asciidoc-bib does not support asciidoctor arguments and extensions. So I can not use asciidoctor-pdf with it.

To accommodate the above problems, I create this fork. This fork tries to be as consistent with asciidoctor as possible. 

## Features

- bibtex-like syntax for adding a citation within text and placing bibliography
- formatting of references and reference list according to range of styles supported by citeproc-ruby
- supports some styling of citation text (page numbers, bracket placement)
- can be used as an asciidoctor extension

## Install

    gem install asciidoctor-bibtex

Installs two executable programs:

- 'asciidoc-bibtex' for transforming source text into asciidoc 
- 'asciidoctor-bibtex' uses asciidoctor extension for single-pass output

asciidoctor-bibtex depends on [bibtex-ruby](http://github.com/inukshuk/bibtex-ruby), [citeproc-ruby](http://github.com/inukshuk/citeproc-ruby) and [csl-styles](http://github.com/inukshuk/csl-styles).  (Ensure 'ruby-dev' and 'libxslt1-dev' are installed, so the dependencies will compile.)

[asciidoctor](https://github.com/asciidoctor/asciidoctor) must also be installed for 'asciidoctor-bibtex' to work. asciidoctor version 1.5.2 or higher is required.

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

  > asciidoctor-bibtex -h

  ...
  AsciidoctorBibtex related options:

      -a bib-file=FILENAME    Set BibTex filename (default: auto-find)
      -a bib-style=STYLE      Set BibTex items style (default: apa)
      -a bib-numeric-order=<alphabetical|appearance>
                            Set citation order scheme (default: alphabetical)
      -a bib-no-links=1       Do not use links (default: use links)

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
