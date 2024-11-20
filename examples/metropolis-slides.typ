#import "@local/minideck:0.3.0" // XXX
#import minideck.themes: *

#let (
  template, slide, section, title-slide, standout, alert, example,
  titled-block, alert-block, example-block
) = minideck.config(
  theme: "metropolis",
  author: [Jeremie Knuesel],
  date: datetime.today().display("[month repr:long] [day], [year]"),
  affiliation: [Center for minideck themes],
)

#show: template

#title-slide[
  = Metropolis
  == An implementation for minideck
]

#slide(outlined: false)[ // for example further down (outline with slide titles)
  = Table of contents

  #outline()
]

#section[ = Introduction ]

#slide[
  = Metropolis

  The *Metropolis* theme was created by Matthias Vogelgesang.@metropolis

  This is a Typst@typst reimplementation for the Minideck@minideck package.

  Enable this theme with
  // XXX update version

  ```typ
  #import "@preview/minideck:0.3.0"
  #let (template, slide, title, section) = minideck.config(
    theme: "metropolis",
    author: [...], affiliation: [...], date: [...],
  )
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
    ...
  )
  ```


  #v(1em)
  The theme provides an `alert` function for #alert[special emphasis], and
  `example` for an #example[alternative color].
]

#section[ = Structure ]

#slide[
  = Presentation title

  To make the title slide:

  ```typ
  #title-slide[
    = Presentation title
    == Subtitle

    // Content can be added here e.g. with `#place`
  ]
  ```

  The theme will insert the author, affiliation, logo and date given to `minideck.config`.
]

#slide[
  = Sections

  Use `#section` to separate groups of slides:

  ```typst
  // Can also include subtitle or other content
  #section[ = Section title ]
  ```

  By default this shows a progress bar. To disable it, configure the theme
  function and give the result to `minideck`:

  ```typ
  #import minideck.themes: *

  minideck.config(
    theme: metropolis.with(show-progress: false),
     ...
  )
  ```
]

#slide(footer-text: [blob])[
  = Outline
  
  By default `#outline` shows only sections. To include slide titles:
  
  ```typ
  #slide(outlined: false)[ // exclude TOC slide from TOC
    #set outline(depth: 5) // 5 = slide titles
    #show par: block.with(breakable: false) // optional
    #columns(2, outline())] // 2 columns looks good here
  ```

  #show outline: set text(0.8em)
  #set outline(depth: 5)
  #show par: block.with(breakable: false)
  #columns(2, outline())
]

#slide[
  = Regular slides

  Use `#slide[...]` for regular slides.
  By default, content is (almost) centered vertically by adding fractional spacing above and below.
  Use `#slide(center: false)[...]` to disable this behavior.

  Use `#standout[...]` to show a slide with simplified layout and inverted colors. Such slides default to `outlined: false`.
]

#standout[
  This is a standout slide
]

#section[ = Elements ]

#slide[
  = Blocks

  Make titled blocks with `titled-block`, `alert-block`, `example-block`

  Syntax: `#titled-block(options...)[Title][Body]`

  Options: `transparent: false` for background, `width:` for fixed width

  #set text(0.9em)

  #columns(2)[
    #titled-block[Default (transparent)][
      Block with `auto` width and enough text to require several lines.
    ]
    #alert-block[Alert (transparent)][
      Block with `auto` width.
    ]
    #example-block(width: 16em)[Example (transparent)][
      Block with fixed width.
    ]
    #colbreak()

    #titled-block(transparent: false)[Default][
      Block with `auto` width and enough text to require several lines.
    ]
    #alert-block(transparent: false)[Alert][
      Block with `auto` width.
    ]
    #example-block(transparent: false, width: 14em)[Example][
      Block with fixed width.
    ]
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

#section[ = Customization ]

// Use external slides to show other themes (because the theme templates cannot
// be used on top of each other)
#slide(
  foreground: image("metropolis-reverse.svg", width: 100%, height: 100%),
)[= Dark variant] // for TOC

#slide(
  // Small shift upward and fill here too to avoid SVG artifact
  foreground: {
    move(dy: -0.5pt, image("metropolis-customized.svg", width: 100%, height: 100%))
  },
  fill: navy,
)[= Appearance] // for TOC

#slide[
  = Custom layouts
  
  How to make layouts such as "full slide picture" that play well with the title bar?

  Minideck has standard functions that should work with any theme:

  - `use-margin`: let content extend over the margins

  - `margins` and `bars`: low level, give raw dimensions to play with

  Combine `block(height: 1fr)` and `use-margin` to use the whole width under the title bar:

  ```typ
  #slide[
    = Title
    #block(height: 1fr)[
      #minideck.use-margin(100%, image("filename.svg"))
    ]
  ]
  ```
]

#slide(margin: 2cm)[
  =  Another example

  #block(height: 1fr)[
    #grid(
      columns: (1fr, 1fr),
      [
        Full size on right side:
        ```typ
        #block(height: 1fr)[
          #grid(
            columns: (1fr, 1fr),
            [Left side...],
            minideck.use-margin(
              y: 100%,
              right: 100%,
              box(
                width: 100%,
                height: 100%,
                fill: orange,
              ),
            )
          )
        ]
        ```
      ],
      minideck.use-margin(
        y: 100%,
        right: 100%,
        box(
          width: 100%,
          height: 100%,
          fill: orange,
        ),
      ),
    )
  ]
]

#section[
  = Conclusion

  == Give it a try!
]

#standout[
  Questions?
]<end-slide>


#slide[
  = References

  #bibliography("metropolis-works.bib") <bib>
]
