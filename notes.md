# TODO

* rename 'paper' to 'format'
* add offset parameter to slide, document.
* make a theme with variants corresponding to popular base16 themes, or any!
* rename title-slide to title?
* convert page number to figure kind:page-number ?
* a dict-merge function that checks that the second dict has no new fields and
  panic if it has (e.g. for overriding palette with a partial user palette)

* show rule for raw to split on some `pause` line and generate subslides, to allow using pause in e.g. codly and algorithmic

* progress bar toggle

## Waiting on typst improvements

* make `alert` aware of context: use `c.inverted.alert` for standout slides

* nicer formatting for bibliography

# Document

* how to get fira math light
* changing slide title padding
* bibliograpy with correct slide title and non-referenced elements
* add to bibliography:  #place(hide[@knuth @nash51])
* changing margins

* how to e.g. change page background, headings: make slide wrapper
* page numbers in appendix unlike original metropolis: seems more useful that way
* centere title in blocks

# Readme updates:

* add images
* convert relative links to absolute (otherwise don't work in typst universe version of the readme)


# Themes

the package is now in `@preview` and includes some minimal infrastructure for theming. Check the [example](https://github.com/knuesel/typst-minideck/blob/main/themes/simple.typ) and the [documentation](https://github.com/knuesel/typst-minideck/blob/main/themes/README.md) if you want to try and make a theme, and let me know if you find anything more difficult than it should be...

metropolis:


https://github.com/matze/mtheme?tab=readme-ov-file

https://polylux.dev/book/utils/sections.html
https://github.com/andreasKroepelin/polylux/issues/175
https://github.com/andreasKroepelin/polylux/issues/179
https://github.com/andreasKroepelin/polylux/issues/118
https://github.com/andreasKroepelin/polylux/issues/98
http://bloerg.net/posts/a-modern-beamer-theme/
