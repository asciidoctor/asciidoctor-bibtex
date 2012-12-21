= asciidoc-bib =

Add references from a bibtex file to an asciidoc file.

Features:

- simple syntax for adding a citation within text and placing bibliography
- transformation of source text to include references and full reference list
- formatting of references and reference list follows Harvard style

== Installation ==

 > gem install asciidoc-bib

== Usage ==

Use [cite:bibref] within text to indicate a reference.
Use [bibliography] on a line by itself to add bibliography.

 > asciidoc-bib filename.txt

Looks for a bib file in current folder and in ~/Documents.
Outputs a new file: filename-ref.txt
which includes your references.  Process the new file with asciidoc.

== Limitations ==

. single ref per cite
. no control over style
. no included files

== License == 

The files within this project may be distributed under the following terms: 

# Open Works License

This is version 0.9.2 of the Open Works License

## Terms

Permission is hereby granted by the copyright holder(s), author(s), and
contributor(s) of this work, to any person who obtains a copy of this work in
any form, to reproduce, modify, distribute, publish, sell, use, or otherwise
deal in the licensed material without restriction, provided the following
conditions are met:

Redistributions, modified or unmodified, in whole or in part, must retain
applicable copyright notices, the above license notice, these conditions, and
the following disclaimer.

NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS LICENSE
OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE
WORK, OR THE USE OF OR OTHER DEALINGS IN THE WORK.


