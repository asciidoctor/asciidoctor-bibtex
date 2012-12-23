# asciidoc-bib 

Add references from a bibtex file to an asciidoc file.

Features:

- simple syntax for adding a citation within text and placing bibliography
- transformation of source text to include references and full reference list
- formatting of references and reference list in author-date style after 'The 
Chicago Manual of Style'
- follows included files
- supports some styling of citation text (page numbers, bracket placement, 
and pretext)

## Install (to come)

 > gem install asciidoc-bib

## Use 

### Include a citation

Syntax for inserting a citation is [cite|citenp:(pretext:)ref(,pages)] 
where 'pretext' and 'pages' are optional.

Examples:

[cite:Lane12] produces "(Lane 2012)"

[citenp:Lane12] produces "Lane (2012)"

[cite:Lane12,59] produces "(Lane 2012, 59)"

[cite:See:Lane12,59] produces "(See Lane 2012, 59)"

### Place bibliography in text

[bibliography] on a line by itself.

### Processing text

 > asciidoc-bib filename.txt

Looks for a bib file in current folder and in ~/Documents.

Outputs a new file: filename-ref.txt
which includes your references.  

Check the new file, and process in the usual way with asciidoc.

## Limitations

- assumes a simplified format for bibtex file
- latex formatting from bibtex file will be included in reference list
- single ref per cite
- no choice of style

## License

The files within this project may be distributed under the terms of 
the Open Works License: http://owl.apotheon.org

## Notes on Using

There is a sample document and bibliography in the folder 'tests'.

It is advisable to preview the -ref files before further processing, to remove
any Latex commands, and check the formatting; in particular, all curly braces
are removed when outputting the reference list, to avoid skipping of lines by
asciidoc.

If you make a Bibliography/Reference heading, a2x interprets this specially,
and will fail to make a pdf. To prevent a2x treating a heading specially, place
a section template name, such as [sect1], before it. 

The bibtex file is not correctly passed. The format for entries is assumed 
to be:

----------------
@TYPE{ref,
  KEY = VAL,
}
----------------

with the type on one line and closing brace on its own.  
VAL is wrapped in {..} or ".." and may span multiple lines, but intermediate 
lines should not end with } or ".

