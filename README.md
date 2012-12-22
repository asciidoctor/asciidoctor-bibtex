# asciidoc-bib 

Add references from a bibtex file to an asciidoc file.

Features:

- simple syntax for adding a citation within text and placing bibliography
- transformation of source text to include references and full reference list
- formatting of references and reference list follows Harvard style

## Installation

 > gem install asciidoc-bib

## Usage 

Indicate a reference within the text with [cite:bibref].

Add reference list into text with [bibliography] on a line by itself.

 > asciidoc-bib filename.txt

Looks for a bib file in current folder and in ~/Documents.

Outputs a new file: filename-ref.txt
which includes your references.  

Process the new file with asciidoc.

## Limitations

Currently:

- latex formatting from bibtex file will be included in reference list
- single ref per cite
- no control over style
- no included files

## License

The files within this project may be distributed under the terms of 
the Open Works License: http://owl.apotheon.org

