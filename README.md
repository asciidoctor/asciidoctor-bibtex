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
[asciidoctor-latex]: https://github.com/asciidoctor/asciidoctor-latex

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

### Macros

Syntax for inserting a citation is the following inline macro:

    cite|citenp:[ref(pages), ...]

where '(pages)' is optional.

Examples of "chicago-author-date" style:

- `cite:[Lane12]` becomes "(Lane 2012)"
- `citenp:[Lane12]` becomes "Lane (2012)"
- `cite:[Lane12(59)]` becomes "(Lane 2012, 59)"

For *apa* (Harvard-like) style:

- `cite:[Lane12]` becomes "(Lane, 2012)"
- `citenp:[Lane12]` becomes "Lane (2012)"
- `cite:[Lane12(59)]` becomes "(Lane, 2012, p.59)"

For *ieee*, a numeric style:

`cite:[Lane12,Lane11]` becomes "[1, 2]"

To add a list of formatted references, place `bibliography::[]` on a line by itself.

### Document Attributes

| Attribute Name | Description                              | Valid Values                      | Default Value       |
| -------------- | ---------------                          | ----------                        | --------------      |
| bibtex-file    | Bibtex database file                     | any string, or empty              | Automatic searching |
| bibtex-style   | Reference formatting style               | any style supported by csl-styles | ieee                |
| bibtex-order   | Order of citations                       | `appearance` or `alphabetical`    | `appearance`        |
| bibtex-format  | Formatting of citations and bibliography | `asciidoc` or `latex`             | `asciidoc`          |

### Commandline

Use asciidoctor-bibtex as an extension:

```bash
asciidoctor -r asciidoctor-bibtex sample.adoc
```

## License

The files within this project may be distributed under the terms of 
the Open Works License: http://owl.apotheon.org

## Links

See https://github.com/petercrlane/asciidoc-bib for the original asciidoc-bib.
