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

#section[ = Configuration ]

#slide[
  = Basic usage

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
  // or:
  #outline(target: minideck.slide-title) // only slide titles
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

  // XXX add freeze

  #v(0.5em)
  Use `footer-text` to place content using the theme layout.\
  Use `footer` to define the footer from scratch.
]

#slide[
  = Customization

  Use standard show/set rules. Minideck offers some helpers:

  - selectors such as `slide-title`
  - layouts like `place-relative`, `protrude`, `top-bar` and
    `bottom-bar`

  // #show slide-subtitle: 
]

#slide[
  = Themes

  Appearance can be 
]

#{
import minideck.themes: *
let (template, slide) = minideck.config(
  color-scheme: (shades: (luma(90%), navy)),
  theme: simple.with(variant: "dark"),
)
show: template
show heading: set text(1.3em)

slide[
  = Slide with dark theme

  ```typ
  #import minideck.themes: *
  #let (template, slide) = minideck.config(
    // This theme expects shades of increasing brightness
    color-scheme: (shades: (luma(90%), navy)),
    // The dark variant reverses the order of shades
    theme: simple.with(variant: "dark"),
  )
  ```

  To have larger slide titles, use for example:
  ```typ
  #show XXX
  ```

  // XXX export modules for colors, styling, etc. and use
  // slide-title.or(slide-subtitle) in the example above
]
}

#section[ = Commands for dynamic slides ]

#slide[
  = Subslides with `pause`

  #grid(columns: (1fr, 1fr))[
    First part

    #show: pause

    Second part
  ][
    #show: pause

    Enums need explicit numbering

    1. One
    2. Two
    #show: pause
    3. Three
  ]
]

#slide[
  = Subslides with `uncover` and `only`

  #uncover(1, from:3)[Content visible on subslides 1 and 3+ (space reserved on 2).]

  #only(2,3)[Content included on subslides 2 and 3 (no space reserved on 1).]

  Content always visible.
]

#slide[
  = Dynamic equations

  $
    f(x) &= x^2 + 2x + 1  \
         #uncover(2, $&= (x + 1)^2$)
  $
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

#slide[
  = With CeTZ figures

  CeTZ figures require
  
  - cetz-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `canvas` call

  Above canvas
  #context canvas({
    import draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on 2nd subslide]
    ])
  })
  Below canvas
]<cetz>


#import "@preview/fletcher:0.5.0" as fletcher: diagram, node, edge

#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)

#slide(steps: 2)[
  = With fletcher diagrams

  fletcher diagrams require
  
  - fletcher-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `diagram` call
  - an explicit number of steps passed to the `slide` function

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


