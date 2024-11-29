#import "@local/minideck:0.3.0" // XXX change local to preview

#let current-subslide = context (state("__minideck-subslide-step", 0).get()+1)

#let (template, slide, section, title-slide, pause, uncover, only) = minideck.config(
  author: [Jane Smith],
  affiliation: [University of Rummidge],
  date: [Minideck Symposium, 4#super[th] September 2024],
  theme: "simple",
)

#show: template

#show raw.where(block: false): set text(0.9em)
#show raw.where(block: true): set text(0.8em)

#title-slide[
  = Slides with minideck
  == Usage and features
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
  (template, title-slide, section, slide) = minideck.config(
    author: [John Doe],
    date: [September 4, 2024],
  )
  #show: template

  #title-slide[
    = Presentation title
    == Some subtitle
  ]

  #slide[
    = Some normal slide
    Some text.
  ]
  ```
]

#slide[
  = Sections

  Use `section` to make a slide that starts a new section:
  
  ```typ
  #section[= Some section ]
  ```

  A section slide can include a subtitle or other content.
]

#slide[
  = Outline

  By default only section titles are shown. To change this:

  ```typ
  #outline(depth: 5) // show section and slide titles, or:
  #outline(depth: 5, target: minideck.slide-title) // no sections
  ```

  For example:
  
  ```typ
  #slide(outlined: false)[ // hide this slide from table of contents
    = Table of contents
    #outline(depth: 5)
  ]
  ```
 
  (In minideck, level 3 is a section title and 5 a slide title)
]

#slide[
  = Backup slides

  Add the `<end-slide>` label to the slide that marks the end of your presentation:

  ```typ
  #slide[
    = Final word

    Blablabla.
  ]<end-slide>

  #slide[
    Extra slide to answer predictable question.
  ]
  ```

  Slides after `<end-slide>` are excluded from the outline, unless created with `#slide(outlined: true)[...]`
]

#slide[
  = Slide commands
  
  Main parameters to commands `slide`, `section` and `title-slide`:
  
  - `outlined`: whether to include the slide in the outline

  - `header-text` and `footer-text` for simple content in header/footer

  - `handout` to enable/disable dynamic content for this slide

  - `template` for rules to apply just before the slide content

  - any `page` argument like `footer`, `margin` or `fill`
]

#slide(
  fill: luma(92%),
  background: circle(stroke: white+8mm, radius: 6cm),
  margin: (top: 1.5cm),
)[
  = Example: background and margins

  This slide was created with the following code:

  ```typ
  #slide(
    fill: luma(92%),
    background: circle(stroke: white+8mm, radius: 6cm),
    margin: (top: 1.5cm),
  )[
    = Example: ...
  ]
  ```

  #v(1em)
  (These slide options are simply forwarded to `page`.)
]

#slide(footer-text: [Some footer text])[
  = Example: footer

  To set or override the footer text, use

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
  #slide(footer: align(horizon, [Some content]))[...]
  ```
]

#section[ = Themes and customization]

#{
import minideck.themes: *
let (template, slide) = minideck.config(
  color-scheme: (
    shades: (maroon.lighten(96%), maroon.darken(30%)), // (bg, fg)
    accents: (olive,)), // default theme uses this for links
  font-scheme: "libertinus-sans") // scheme specified by name
show: template // OK because this template is almost idempotent
show heading: set text(1em/1.2)

slide[
  = Schemes and themes
  Themes control the layout and general appearance

  Schemes are declarative font and color settings:
  - easy to share
  - work with any theme

  Here we use schemes to customize the default theme:

  ```typ
  minideck.config(
    color-scheme: (
      shades: (maroon.lighten(96%), maroon.darken(30%)), // (bg, fg)
      accents: (olive,)), // default theme uses this for links
    font-scheme: "libertinus-sans") // scheme specified by name
  ```

  Three related concepts (see #link("https://github.com/knuesel/typst-minideck/tree/main/themes")[README] for a discussion) // XXX update link
  // XXX link color wrong
]

slide[
  = Standard themes and schemes // XXX update list

  #columns(2)[
    Themes
    - `simple`
    - `metropolis`

    #colbreak()
    Font schemes (need fonts)
    - `default`
    - `libertinus-sans`
    - `fira-sans`
    - `fira-sans-light`
  ]

  #v(1em)
  Color schemes
  - `default`
  - `phosphor`
  - from a theme: for example `metropolis().color-scheme`
]
}

#{
import minideck.themes: *
let (template, slide) = minideck.config(
  font-scheme: "libertinus-sans",
  color-scheme: (shades: (luma(90%), navy), reverse: true),
  theme: metropolis.with(show-progress: false), // configured function
)
show: template
show heading: set text(1em/1.1)
show raw: set text(1.1em)

slide(margin: 1.4cm)[
  = Setting theme options

  A theme is actually a function with parameters.

  Standard themes (and schemes) can be passed by name, so `"metropolis"` can be given instead of the `minideck.themes.metropolis` function.

  To change parameters, give `minideck.config()` a configured theme function:

  ```typ
  #import minideck.themes: *

  #let (template, slide) = minideck.config(
    font-scheme: "libertinus-sans",
    color-scheme: (shades: (luma(90%), navy)),
    theme: metropolis.with(show-progress: false), // configured function
  )
  ```
]
}

#slide[
  = Getting theme defaults

  You can call the theme function to get its default schemes:

  ```typ
  #import minideck.themes: *
  font scheme: #metropolis().font-scheme \
  color scheme: #metropolis().color-scheme
  ```

  #v(1em)
  #set text(0.8em)
  *Result:*

  #import minideck.themes: *
  font scheme: #metropolis().font-scheme \
  color scheme: #metropolis().color-scheme
]

#{
show heading: set text(font: "DejaVu Sans", eastern)
let grad = gradient.linear(yellow.lighten(85%), white)
show minideck.slide-title: it => minideck.layouts.top-bar(
  fill: yellow.lighten(70%), align(left, pad(6mm, it)))
show minideck.slide-subtitle: it => minideck.layouts.top-bar(
  fill: grad, align(left, pad(6mm, text(0.7em, it))))

slide(margin: 2cm)[
  = Customization
  == Hand-made, without themes

  Use standard show/set rules. Minideck offers some helpers:

  - selectors such as `slide-title`

  - layouts like `use-margin`, `place-relative`, `top-bar` and
    `bottom-bar`

  - utilities like `margins` and `bars`

  #v(1em)
  Example used in this slide:
  #set text(0.9em)

  ```typ
  #show heading: set text(font: "DejaVu Sans", eastern)
  #let grad = gradient.linear(yellow.lighten(85%), white)
  #show minideck.slide-title: it => minideck.layouts.top-bar(
    fill: yellow.lighten(70%), align(left, pad(6mm, it)))
  #show minideck.slide-subtitle: it => minideck.layouts.top-bar(
    fill: grad, align(left, pad(6mm, text(0.7em, it))))
  ```
]

slide[
  = Full list of selectors

  Defined in the `minideck` module, to use with show rules:

  - `presentation-title`
  - `presentation-subtitle`
  - `section-title`
  - `section-subtitle`
  - `slide-title`
  - `slide-subtitle`
  - `block-title`
  - `block-subtitle`

  These correspond to `level` 1 to 8.
]

slide[
  =  Custom slide layouts

  #import minideck: use-margin

  `use-margin` helps with layouts that extend in the margins:


  ```typ
  #let my-box = box.with(inset: 1em, fill: luma(90%))
  #use-margin(x: 100%, my-box(width: 100%)[Page-wide figure])
  ```

  #let my-box = box.with(inset: 1em, fill: luma(90%))
  #use-margin(x: 100%, my-box(width: 100%)[Page-wide figure])

  ```typ
  #grid(columns: 2, lorem(12),
    use-margin(right: 100% - 5mm, my-box(width: 100%,
      [Figure reaching to 5mm of page border])))
  ```

  #grid(columns: 2, lorem(12),
    use-margin(right: 100% - 5mm, my-box(width: 100%,
      [Figure reaching to 5mm of page border])))
]

slide[
  = Titled blocks

  If your theme doesn't offer titled blocks, you can use `layouts.titled-block` directly:

  ```typ
  #show minideck.block-title: set text(20pt)
  #minideck.layouts.titled-block(
    title: (fill: yellow.lighten(80%)),
    body: (fill: luma(90%)),
    width: 70%,
  )[#lorem(3)][#lorem(10)]
  ```
  
  #show minideck.block-title: set text(20pt)
  #minideck.layouts.titled-block(
    title: (fill: yellow.lighten(80%)),
    body: (fill: luma(90%)),
    width: 70%,
  )[#lorem(3)][
    #lorem(10)
  ]

  Or use a package like #link("https://typst.app/universe/package/showybox/")[showybox]...
]
}

#section[ = Dynamic slides ]

#slide[
  = Overview
  
  #v(1em)
  - Use `pause` / `uncover` / `only` to make subslides

  - Use `minideck.config(handout: true)` to disable subslides\
    (this puts all subslides' content in one slide)

    Or choose handout mode from the command line:
    
    ```
    typst compile file.typ --input handout=true
    ```

  - Dynamic CeTZ/fletcher diagrams are possible with extra effort\
    (see examples below)
]

#slide[
  = Subslides with `pause`

  Use `#show: pause` where you want to start a new subslide:

  #grid(columns: (50%, 50%),
    ```typ
    First part

    #show: pause

    Second part
    ```,
  [
    *Result:*
    
    First part

    #show: pause

    Second part
  ],
  )
]

#slide[
  = Subslides with `uncover` and `only`

  These functions work with subslide indices, which start at 1.

  This will show content on subslides 1, 3, and all starting at 5:

  ```typ
  #uncover(1, 3, from: 5)[
    ...
  ]
  ```
  
  #v(1em)
  `#only` works the same but layout is affected: content is removed instead of hidden
]

#slide[
  Example:

  ```typ
  #uncover(1, from: 3)[content for 1 and 3+ (space reserved on 2)]

  #only(2, 3)[content for 2 and 3 (no space reserved on 1)]

  Normal text: this content is always visible
  ```

  #v(1em)
  Result (subslide #current-subslide):
  
  #set text(0.9em)
  #v(1em)

  #uncover(1, from: 3)[content for 1 and 3+ (space reserved on 2)]

  #only(2, 3)[content for 2 and 3 (no space reserved on 1)]

  Normal text: this content is always visible
]

#slide[
  = Step-by-step lists and enumerations
  
  Currently, list markers don't get hidden properly (see #link("https://github.com/typst/typst/issues/619")[issue here]):
  #grid(columns: (50%, 50%),
    ```typ
    + One
    #show: pause
    + Two
    ```,
    [
      *Result:*
      + One
      #show: pause
      + Two
    ],
  )

  #show: pause
  #v(1em)
  As a workaround, consider using `only` instead of `pause` or `uncover`:
  #grid(columns: (50%, 50%),
    ```typ
    + One
    #only(2, 3)[
      + Two
    ]
    #only(3)[
      + Three
    ]
    ```,
    [
      *Result:*
      + One
      #only(4, 5)[
        + Two
      ]
      #only(5)[
        + Three
      ]
    ],
  )
]

#slide[
  = Dynamic equations

  ```typ
  $
    f(x) &= x^2 + 2x + 1  \
    #uncover(2, $&= (x + 1)^2$)
  $
  ```

  #v(1em)

  Subslide #current-subslide:

  $
    f(x) &= x^2 + 2x + 1  \
    #uncover(2, $&= (x + 1)^2$)
  $

  // XXX add numbering once fixed
]

#import "@preview/pinit:0.2.2": *

#slide[
  // = Dynamic slides with `pinit`

  // Pythagorean theorem:

  // $ #pin(1)a^2#pin(2) + #pin(3)b^2#pin(4) = #pin(5)c^2#pin(6) $

  // // #show: pause

  // $a^2$ and $b^2$ : squares of triangle legs

  // // #only(2, {
  //   pinit-highlight(1,2)
  //   pinit-highlight(3,4)
  // // })

  // // #show: pause

  // $c^2$ : square of hypotenuse

  // #pinit-highlight(5,6, fill: green.transparentize(80%))
  // #pinit-point-from(6)[larger than $a^2$ and $b^2$]
  
]

#import "@preview/cetz:0.3.1"

#let (slide, only, cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

#let _subslide-count = state("__minideck-subslide-count", (0, 0))

#slide[
  = Dynamic CeTZ figures

  CeTZ figures require
  
  - cetz-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `canvas` call

  Example setup:

  ```typ
  #import "@preview/cetz:0.3.1"

  (cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

  #slide[
    #context cetz.canvas({
      ...
    })
  ]
  ```
]

#slide[
  == CeTZ example

  #set text(0.9em)
  
  Code:
  ```typ
  #context cetz.canvas({
    import cetz.draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on subslide 1]
    ])
  })
  ```

  Result: subslide #current-subslide

  #context cetz.canvas(length: 8mm, {
    import cetz.draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on subslide 2]
    ])
  })
]


#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge

#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)

#slide[
  = Dynamic fletcher diagrams

  fletcher diagrams require
  
  - fletcher-specific `uncover` and `only` from `minideck.config`
  - a `context` outside the `diagram` call (but in the slide)
  - an explicit number of steps passed to the `slide` function

  Example setup:

  #set text(0.9em)

  ```typ
  #import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge

  (fletcher-uncover, fletcher-only) = minideck.config(fletcher: fletcher)

  #slide(steps: 2)[
    #context diagram({
      ...
    })
  ]
  ```
]

#slide(steps: 2)[
  == Fletcher example
  
  #set text(0.9em)
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

  == Result: subslide #current-subslide

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

#section[ = Reference ]

#slide[
  = Options for `minideck.config`
  #set text(0.9em)
  #show terms: set block(spacing: 1fr)

  / `format`: can be `"4:3"` (default), `"16:9"`, a paper name, or a\ `(width:, height:)` dictionary

  / `font-scheme`: change font settings using a scheme name such as
    `"libertinus-sans"` or `"fira-sans-light"`, or a dict (see below).\
    Can also be an array of schemes (for themes that use several fonts)

  / `color-scheme`: change colors using a scheme name like `"default"` or
    `"phosphor"`, or dict (see below)

  / `theme`: can be a theme name or theme function

  / `handout`: disables dynamic behavior of `pause`, etc. when set to `true`

  / `cetz`, `fletcher`: enable support for dynamic diagrams (give your version of the CeTZ/fletcher module as option value)
]

#slide[
  Plus some options used mostly for the title slide:
  #set text(0.9em)
  #v(1em)

  / `author:`: presentation author

  / `affiliation:`: author affiliation

  / `logo:`: institution logo

  / `date:`: date, can be any content (event name, etc.)
]

#slide[
  = Font schemes
  #set text(0.9em)

  A font scheme is a dict with fields

  - `text`, `raw` and `math`: settings for regular text, raw and math elements
  - `text-weights`: a dict of weight overrides for regular text
  - `delta`: the weight step to use with `strong`
  
  For example, the `fira-sans-light` scheme is defined as follows:

  ```typ
  (
    text: (font: "Fira Sans"),
    text-weights: (regular: "light", medium: 350, bold: "regular"),
    raw: (font: "Fira Mono", weight: "regular"),
    math: (font: "Fira Math", weight: "light"),
    delta: 100,
  )
  ```  

  This will use light weight for regular text and regular for bold.
]

#slide[
  #set text(0.9em)
  Fields can be omitted to inherit from the default scheme.\
  For example `libertinus-sans` is defined as
  ```typ
  (text: (font: "Libertinus Sans"))
  ```

  Standard schemes are stored in `minideck.fonts.schemes` and include
  - `default`
  - `libertinus-sans`
  - `fira-sans`
  - `fira-sans-light`

  Standard schemes can be specified by name instead of dict.

  `minideck.fonts.font-scheme()` can be used to inherit from a scheme:

  ```
  font-scheme(base: "fira-sans-light", delta: 300)
  ```

  The same arguments can be passed as dict to `minideck.config`:

  ```
  minideck.config(font-scheme: (base: "fira-sans-light", delta: 300))
  ```
]

#slide[
  = Color schemes
  #set text(0.9em)

  A color scheme is a dict with fields
  - `shades`: colors of similar hues and increasing or decreasing lightness.

    Can be an array of at least two colors, or a gradient.

    Used for distinguishing elements based on lightness.

    Typically the first shade is used as background color and the last shade as foreground (text) color.

  - `accents`: colors of contrasting hues.

    Must be an array of at least one color.
  
    Used for distinguishing elements based on hue.
]

#slide[
  For example the default scheme is
  
  ```
  (
    shades: (white, black),
    accents: (red, green, blue, purple),
  )
  ```

  Standard schemes are stored in `minideck.colors.schemes` and include
  `default` and `phosphor`.

  Standard schemes can be specified by name instead of dict.

  `minideck.colors.color-scheme()` can be used to inherit from a scheme and/or to reverse the shades:

  ```
  color-scheme(base: "phosphor", accents: (red,), reverse: true)
  ```

  The same arguments can be passed as dict to `minideck.config`:

  ```
  minideck.config(color-scheme: (base: "phosphor", reverse, true))
  ```
]

#slide[
  = Options for `slide`, `section` and `title-slide`
  #set text(0.8em)

  / `header-func:`: callback for header layout (`none` = leave header as is)

  / `footer-func:`: callback for footer layout (`none` = leave footer as is)
  
  / `header-text:`: content to pass to `header-func` (`auto` = use default)
    
  / `footer-text:`: content to pass to `footer-func` (`auto` = use default)
    
  / `handout:`: enable/disable dynamic content for this slide
  
  / `steps`: number of subslides (default is `auto`)
  
  / `offset:`: offset for headings in this slide (e.g. 4 for normal slides)
  
  / `outlined:`: include/exclude slide headings in outline

  / `template:`: template to apply just before slide content (default is `none`)

  - plus any option accepted by `page`

  - plus non-standard options defined by the theme
]
