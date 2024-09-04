#import "@local/minideck:0.3.0" // XXX

#let (template, slide, section, title, pause, uncover, only) = minideck.config()

#show: template

#show raw: set text(0.8em)

#title[
  = Slides with `minideck`
  == Usage and features
  John Doe

  #datetime.today().display()
]

#slide(outlined: false)[
  = Table of contents

  #outline()
]

#section[ = Basic usage ]

#slide[
  = Getting started

  Use `minideck.config()` to get the slide functions:

  ```typ
  #import "@preview/minideck:0.3.0"
  (template, title, section, slide) = minideck.config()
  #show: template

  #title[
    = Presentation title
    == Some subtitle
    Author...
  ]
  // Slide for new section: can include subtitle or other content
  #section[= Some section ]
  #slide[
    = Some normal slide
    ...
  ]
  ```
]

#slide[
  = Options for `minideck.config(...)`

  - `format`: can be `"4:3"` (default), `"16:9"`, a paper name, or a\ `(width:, height:)` dictionary

  - `font-scheme`: switch a bunch of font settings with a dict or a name like
    `"default"`, `"libertinus-sans"` or `"fira-sans-light"`

  - `color-scheme`: switch colors using a name like `"default"` or
    `"metropolis"`, or a dict like `(shades: (bg, fg), accents: (red, blue))`

  - `theme`: give a theme name ortheme function

  - `handout`: use `true` to disable dynamic behavior of `pause`, etc.

  - `cetz`, `fletcher`: see #link(<cetz>)[below].
]

#slide[
  = Outline

  Default in standard themes is to show only section titles.\
  To change this:

  ```typ
  #outline(depth: 5) // show section and slide titles
  #outline(depth: 5, target: minideck.slide-title) // only slide titles
  ```

  For example:
  
  ```typ
  #slide(outlined: false)[ // hide this slide from table of contents
    = Table of contents
    #outline(depth: 5)
  ]
  ```
 
]

#slide[
  = Slide commands
  
  Main parameters to commands `slide`, `section` and `title`:
  
  - `outlined`: whether to include the slide in the outline
  - `header-text` and `footer-text`: for simple content in header/footer
  - any `page` argument like `footer` or `margin` (to change margins just for one slide)
]

#slide(footer-text: [Some footer text])[
  == Example: changing the footer

  To set/override the footer text, use

  ```typ
  #slide(footer-text: [Some footer text])[...]
  ```

  The theme will put the content somewhere in its footer layout.

  #v(1em)

  To make this the default you can redefine `slide`:

  ```typ
  #let slide = slide.with(footer-text: [Some footer text])
  ```

  #v(1em)

  To take full control of the footer, use `footer` (the `page` argument):

  ```typ
  #slide(footer: align(horizon+center, context counter(page).display()))
  ```
]

#section[ = Themes and customization]

#slide[
  #show heading: set text(font: "DejaVu Sans Mono", eastern)
  #let bar = (fill: yellow.lighten(95%))
  #show minideck.slide-title: it => minideck.layouts.top-bar(
    align(left, pad(8mm, it)), style: bar)
  #show minideck.slide-subtitle: it => minideck.layouts.top-bar(
    align(left, pad(top: -2mm, rest: 8mm, text(0.7em, it))), style: bar)

  = Customization
  == Hand-made, without themes

  Use standard show/set rules. Minideck offers some helpers:

  - selectors such as `slide-title`

  - layouts like `place-relative`, `protrude`, `top-bar` and
    `bottom-bar`

  #v(1em)
  Example used in this slide:

  ```typ
  #show heading: set text(font: "DejaVu Sans Mono", eastern)
  #let bar = (fill: yellow.lighten(95%))
  #show minideck.slide-title: it => minideck.layouts.top-bar(
    align(left, pad(8mm, it)), style: bar)
  #show minideck.slide-subtitle: it => minideck.layouts.top-bar(
    align(left, pad(top: -2mm, rest: 8mm, text(0.7em, it))), style: bar)
  ```
]

#{
import minideck.themes: *
let (template, slide) = minideck.config(
  color-scheme: (
    shades: (maroon.lighten(96%), maroon.darken(30%)), // (bg, fg)
    accents: (olive,)), // default theme uses this for links
  font-scheme: "libertinus-sans") // scheme specified by name
show: template
slide[
  = Schemes and themes
  Schemes: easy to exchange / use with any theme:

  ```typ
  minideck.config(
    color-scheme: (
      shades: (maroon.lighten(96%), maroon.darken(30%)), // (bg, fg)
      accents: (olive,)), // default theme uses this for links
    font-scheme: "libertinus-sans") // scheme specified by name
  ```

  #v(1fr)

  Three related concepts (see #link("https://github.com/knuesel/typst-minideck/tree/main/themes")[README] for a discussion) // XXX update link

  - *theme:* controls layout and general appearance

  - *color scheme:* palettes of colors the theme can use

  - *font scheme(s):* fonts and related settings
  
  Themes and schemes can be passed as values or by name.
]

slide[
  = Standard schemes and themes // XXX update list

  #show: columns.with(2)

  Font schemes (need fonts)
  - `default`
  - `libertinus-sans`
  - `fira-sans`
  - `fira-sans-light`

  #v(1em)
  Color schemes
  - `default`
  - `metropolis`

  #colbreak()
 
  Themes
  - `simple`
  - `metropolis`
]
}

#{
import minideck.themes: *
let (template, slide) = minideck.config(
  font-scheme: "libertinus-sans",
  color-scheme: (shades: (luma(90%), navy)),
  theme: simple.with(variant: "dark"),
)
show: template
show heading: set text(1.2em)

slide[
  = Slide with dark theme

  A theme can be specified by name, but to set options the theme function
  must be used:

  ```typ
  #import minideck.themes: * // for easy access to theme functions
  #let (template, slide) = minideck.config(
    // This requires Libertinus Sans to be installed
    font-scheme: "libertinus-sans",
    // The simple theme expects shades of increasing brightness
    color-scheme: (shades: (luma(90%), navy)),
    // Configure theme function (dark variant = reverse order of shades)
    theme: simple.with(variant: "dark"),
  )
  ```
]
}

#section[ = Dynamic slides ]

#slide[
  = Subslides with `pause`

  #grid(columns: (2fr, 3fr))[
    First part

    #show: pause

    Second part
  ][
    #show: pause

    Enums work with explicit numbering

    1. One
    2. Two
    #show: pause
    3. Three
  ]
]

#slide[
  = Subslides with `uncover` and `only`

  #set par(justify: true)

  #uncover(1, from: 3)[
    `#uncover(1, from: 3)[...]`\
    #sym.arrow visible on subslides 1 and 3+ (space reserved on 2)
  ]

  #only(2, 3)[
    `#only(2, 3)[...]`\
    #sym.arrow included on subslides 2 and 3 (no space reserved on 1)
  ]

  Normal text: this content is always visible
]

#slide[
  = Dynamic equations

  $
    f(x) &= x^2 + 2x + 1  \
         #uncover(2, $&= (x + 1)^2$)
  $

  // XXX add numbering once fixed
]

#import "@preview/pinit:0.1.4": *

#slide[
  = Works well with `pinit`

  Pythagorean theorem:

  $ #pin(1)a^2#pin(2) + #pin(3)b^2#pin(4) = #pin(5)c^2#pin(6) $

  #show: pause

  $a^2$ and $b^2$ : squares of triangle legs

  #only(2, {
    pinit-highlight(1,2)
    pinit-highlight(3,4)
  })

  #show: pause

  $c^2$ : square of hypotenuse

  #pinit-highlight(5,6, fill: green.transparentize(80%))
  #pinit-point-from(6)[larger than $a^2$ and $b^2$]
  
]

#import "@preview/cetz:0.2.2" as cetz: *

#let (slide, only, cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

#let _subslide-count = state("__minideck-subslide-count", (0, 0))

#slide[
  = With CeTZ figures

  CeTZ figures require
  
  - cetz-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `canvas` call

  == Example
  ```typ
  #context canvas({
    import draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on subslide 1]
    ])
  })
  ```
]<cetz>

#slide[
  == Result: subslide #context (state("__minideck-subslide-step", 0).get()+1)

  Above canvas
  #context canvas({
    import draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on subslide 2]
    ])
  })
  Below canvas
]


#import "@preview/fletcher:0.5.0" as fletcher: diagram, node, edge

#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)

#slide[
  = With fletcher diagrams

  fletcher diagrams require
  
  - fletcher-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `diagram` call (but in the slide)
  - an explicit number of steps passed to the `slide` function

  == Example

  ```typ
  #slide(steps: 2)[
    #context diagram(
      node-stroke: 1pt,
      node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
      edge("-|>"),
      node((1,0), align(center)[A]),
      fletcher-uncover(from:2,edge("d,r,u,l","-|>",[x],label-pos:0.1)))
  ]
  ```
]


#slide(steps: 2)[
  == Result: subslide #context (state("__minideck-subslide-step", 0).get()+1)

  #set align(center)
  Above diagram

  #context diagram(
    node-stroke: 1pt,
    node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
    edge("-|>"),
    node((1,0), align(center)[A]),
    fletcher-uncover(from: 2, edge("d,r,u,l", "-|>", [x], label-pos: 0.1))
  )
  
  Below diagram
]


