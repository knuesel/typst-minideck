// Subset of metropolis-slides.typ for testing

#import "/package.typ" as minideck

#let date = datetime(year: 2024, month: 9, day: 5)

#let (
  template, slide, section, title-slide, standout,
  title-block, alert-block, example-block,
) = minideck.config(
  theme: "metropolis",
  author: [Jane Smith],
  affiliation: [University of Rummidge],
  date: date.display("[month repr:long] [day], [year]"),
)

#show: template

#title-slide[
  = Metropolis
  == Internal test slides for minideck
]

#slide(outlined: false)[ // for outline example further down with slide titles
  = Table of contents

  #outline()
]

#section[ = Introduction ]

#slide[
  = Metropolis

  The *Metropolis* theme was created by Matthias Vogelgesang.@metropolis

  This is a Typst@typst reimplementation for the Minideck@minideck package.


  Enable this theme with

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
  = Outline
  
  By default `#outline` will show only sections. To include slide titles:
  
  ```typ
  #slide(outlined: false)[ // exclude TOC slide from TOC
    #set outline(depth: 5) // 5 = slide titles
    #show par: block.with(breakable: false) // optional
    #columns(2, outline())]
  ```

  #show outline: set text(0.8em)
  #set outline(depth: 5)
  #show par: block.with(breakable: false)
  #columns(2, outline())
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

#standout[
  Questions?
]<end-slide>

#slide[
  = Backup slides

  Add the `<end-slide>` label to the slide that marks the end of your presentation.

  Slides coming after this point are ignored by the progress indicator.
]

#slide[
  = References

  #bibliography("metropolis-works.bib") <bib>
]
