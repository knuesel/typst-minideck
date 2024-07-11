#import "lib.typ" as minideck
#import minideck.themes: *

// XXX remove
#import "layouts.typ"
#import "util.typ"
#import "styling.typ": *

#let (cfg, template, slide, section, title, standout, pause, alert, example,
      title-block, alert-block, example-block) = minideck.config(
  // format: "4:3",
  // text-size: 22pt,
  // font-scheme: "libertinus-sans",
  // font-scheme: "fira-sans-light",
  // font-scheme: "fira-sans",
  // color-scheme: (shades: (gray, black)),
  theme: metropolis.with(
    variant: "light", // light or dark
    // show-progress: false,
  ),
)

#show: template

#title[
  = Metropolis
  == An implementation for minideck
  // == A modern beamer theme // XXX remove

  // Matthias Vogelgesang// XXX remove

  Jeremie Knuesel

  #datetime.today().display("[month repr:long] [day], [year]")
]

#slide(outlined: false)[
  = Table of contents

  #outline()
]

#section[
  = Introduction
]

#slide[
  = Metropolis

  The *Metropolis* theme was created by Matthias Vogelgesang.@metropolis

  This is a Typst@typst reimplementation for the Minideck@minideck package.


  Enable this theme with
  // XXX update version

  ```typ
  #import "@preview/minideck:0.3.0"
  #let (template, slide, title, section) = minideck.config(
    theme: "metropolis")
  #show: template
  ```

  (On the `#let` line, list all the theme functions you want to use.)

  #v(1em)
  For other Typst implementations see Polylux@polylux and Touying@touying.
]

#slide[
  = Typography

  The default font scheme is `fira-sans-light`. To use it, make sure you have _Fira Sans_ and _Fira Math_ installed!

  There is also a font scheme `fira-sans` that uses regular weight for text and medium weight for titles. Select it with

  ```typ
  minideck.config(
    font-scheme: "fira-sans",
    theme: "metropolis",
  )
  ```


  #v(1em)
  The theme provides an `alert` function for #alert[special emphasis], and an
  `example` function for display in an #example[alternative color].
]

#section[= Structure]

#slide[
  = Presentation title

  The `#title` command creates a title slide.
  
  Headers are defined with the usual typst syntax:

  ```typ
  #title[
    = Presentation title
    == Subtitle

    Author

    Date
  ]
  ```
]

#slide[
  = Sections

  Use `#section` to separate groups of slides:

  ```typst
  #section[
    = Section title
    ...
  ]
  ```

  This will create a slide with the section title and a progress bar, plus optional subtitle(s) or other content.

  #v(1fr)
  To disable the progress bar, import the `metropolis` function with

  
  `  #import minideck.themes: *`
  
  and configure it with\
  `  minideck.config(theme: metropolis.with(show-progress: false))`
]

#slide[
  By default `#outline` will show only sections, but you can
  include the titles of normal slides (see result below):

  ```typ
  #slide(outlined: false)[ // exclude TOC slide from TOC
    #set outline(depth: 5)
    #show par: block.with(breakable: false) // optional
    #columns(2, outline())
  ]
  ```

  #show outline: set text(0.8em)
  #set outline(depth: 5)
  #show par: block.with(breakable: false)
  #columns(2, outline())

  The `show par:` prevents a column break in the middle of a section.
]


#section[
  = Elements
]

#slide[
  = Lists

  #grid(columns: (1fr,)*3, align: top)[
    List:

    - Milk

    - Eggs

    - Potatos
  ][
    Enumeration:

    + First,

    + Second and

    + Last.
  ][
    Terms:

    / PowerPoint: Meeh.

    / Beamer: Yeeeha.
  ]
]

#slide[
  = Blocks

  Show title blocks with `title-block`, `alert-block` and `example-block`.

  Syntax: `#title-block(options...)[Title][Body]`.

  Options: `transparent: false` for background, `width:` for fixed width.

  #set text(0.9em)

  #columns(2)[
    #title-block()[Default][
      Block with `auto` width and enough text to require several lines.
    ]
    #alert-block()[Alert][Block with `auto` width.]
    #example-block(width: 16em)[Example][Block with fixed width.]
    #colbreak()

    #title-block(transparent: false)[Default][
      Block with `auto` width and enough text to require several lines.
    ]
    #alert-block(transparent: false)[Alert][Block with `auto` width.]
    #example-block(transparent: false, width: 14em)[Example][Block with fixed width.]
  ]
]

#slide[
  = Math

  The default math font (Fira Math) has many weights.
  
  Here are some:

  #let cells =  for w in ("light", 350, "regular", "medium", "semibold", "bold", "extrabold", "black") {
      (
        [#w],
        [
          #show math.equation: set text(weight: w)
          $ e = lim_(n -> infinity) (1 + 1/n)^n $
        ],
      )
    }

  #grid(columns: 4, align: horizon, column-gutter: (1em, 2em, 1em), row-gutter: 3pt,
    ..cells
  )

  #v(1em)
  To choose one, use `#show math.equation: set text(weight: ...)`
]

#slide(footer-text: [Some footer text])[
  = Frame footer

  Add text in the footer using the `footer-text` parameter of `slide`:

  ```typ
  #slide(footer-text: [Some footer text])[
    ...
  ]
  ```

  To make this the default use
  ```
  #let slide = slide.with(footer-text: [Some footer text])
  ```

  You can override the complete footer (including page number) using `slide(footer: ...)`

  Actually this works for any `page` setting: pass them to `slide`, they will be forwarded to `page`.

]

#section[
  = Conclusion

  == Give it a try!
]

#standout[
  Questions?
]

#slide[
  = Backup slides

  Add the `<appendix>` label to a slide (section title or normal slide) to start
  the appendix.
  
  Appendix slides are ignored by the progress indicator.
]<appendix>

#slide[
  = References

  #bibliography("works.bib") <bib>
]
