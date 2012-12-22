# asciidoc-bib 

Add references from a bibtex file to an asciidoc file.

Features:

- simple syntax for adding a citation within text and placing bibliography
- transformation of source text to include references and full reference list
- formatting of references and reference list in author-date style after 'The 
Chicago Manual of Style'

## Install (to come)

 > gem install asciidoc-bib

## Use 

Indicate a reference within the text with [cite:bibref].

Add reference list into text with [bibliography] on a line by itself.

 > asciidoc-bib filename.txt

Looks for a bib file in current folder and in ~/Documents.

Outputs a new file: filename-ref.txt
which includes your references.  

Check the new file, and process in the usual way with asciidoc.

## Limitations

- latex formatting from bibtex file will be included in reference list
- single ref per cite
- no control of reference format (e.g. brackets, page numbers)
- no choice of style
- no included files
- multi-line values in bibtex file

## License

The files within this project may be distributed under the terms of 
the Open Works License: http://owl.apotheon.org

## Notes on Using

There is a sample file and bibliography in the folder 'tests'.

It is advisable to preview the -ref files before further processing, 
to remove any Latex commands, and check the formatting.

If you make a Bibliography/Reference heading, a2x interprets this specially,
and will fail to make a pdf. To prevent a2x treating a heading specially, place
a section template name, such as [sect1], before it. 

