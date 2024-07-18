/*
  Goals

  - adapt margins to text size => support ems as input
  - slide title ignores margins, goes to top and reserves space equal to margin below
    => needs margin as absolute numbers

  Solution

  - theme has options for abs text size and supports em margins, but quickly converts the margins to absolute


  Problem:
  - How to make section slides with inverted theme? We don't want to set page properties in slide as that would be hard for the user to override?
  - Idea: sectoin title is a figure of section-title kind, shown as a fulll box in the whole slide

   But what about standout slides then? everything must be inverted.


  = Distinguish headings

  Problem: normal slides have rectangle, title slide and section slides not

*/

// Document-specific settings
#show raw: set underline(stroke: 0pt)

/*
  font theme:
  font, math font, font weight, math font weight, heading weights, strong delta


  metropolis.with(
    font-theme: "fira-sans",
    weight: "light",
  )

  color-theme: 
*/

// Settings for `text` and `strong`
#let font-themes = (
  default: (
    text: (:),
    raw: (:), 
    math: (:),
    presentation-title: (:),
    presentation-subtitle: (:),
    section-title: (:),
    section-subtitle: (:),
    slide-title: (:),
    slide-subtitle: (:),
    standout: (:),
    strong: (:),
    semi-strong: (delta: 150),
  ),
  fira-sans: (
    text: (font: "Fira Sans",),
    raw: (font: "Fira Mono", weight: "medium"),
    math: (font: "Fira Math",),
    presentation-title: (weight: "medium",),
    presentation-subtitle: (weight: "regular",),
    section-title: (weight: "medium",),
    section-subtitle: (weight: "regular",),
    slide-title: (weight: "medium",),
    standout: (weight: "medium",),
    semi-strong: (delta: 100),
  ),
  fira-sans-light: (
    text: (font: "Fira Sans", weight: "light"),
    raw: (font: "Fira Mono", weight: "regular"),
    math: (font: "Fira Math", weight: "light"),
    presentation-title: (weight: "regular",),
    presentation-subtitle: (weight: "light",),
    section-title: (weight: "regular",),
    section-subtitle: (weight: "light",),
    slide-title: (weight: "regular",),
    slide-subtitle: (weight: "regular",),
    standout: (weight: "regular",),
    strong: (delta: 100),
    semi-strong: (delta: 50),
  ),
  libertinus-sans: (
    text: (font: "Libertinus Sans",),
    raw: (font: "DejaVu Sans Mono",),
    math: (font: "New Computer Modern Math",),
  ),
)

// Get field from dict if x is a string, or return x if not a string
// (this function should not be used when the value can be a string)
#let field-or-value(dict, x) = if type(x) == str { dict.at(x) } else { x }

#import "lib.typ" as minideck
#import "util.typ"
#import "themes/metropolis-colors.typ" as colors
#import "paper.typ": papers

// #let font-theme = "libertinus-sans"
#let font-theme = "fira-sans-light"
// #let font-theme = "fira-sans"
#let text-size = 22pt

// Resolve font theme name to value
#let font-theme = field-or-value(font-themes, font-theme)
// Fill in default values for missing fields
#let font-theme = util.merge-dicts(font-themes.default, font-theme)

#let (template, slide, title-slide, pause) = minideck.config()

#let page-size = (width: papers.presentation-4-3.width*1mm, height: papers.presentation-4-3.height*1mm)
#let user-margin = 3em
#let margin = util.absolute-margins(user-margin, page-size, text-size)

#let presentation-title-gap = 44pt
#let section-title-gap = 28pt
#let progress-bar = true
#let footer-padding = 1.5em
#let show-footer = false

// Text smaller than normal size in lower half of title slide
#let title-slide-text-scale = 0.9

#let user = (
  variant: "light",
  // base-colors: (:),
  // base-colors: (bg: luma(90%)), // override some base colors from variant
  base-colors: (:),
  palette: (
    // normal: (block-title: (fg: blue)),
    inverted: (block-title: (fg: blue)),
  ),
)

#let c = colors.palette(user.variant, user.base-colors, user.palette)

#set text(text-size, ..font-theme.text)
#show math.equation: set text(..font-theme.math)
#set strong(..font-theme.strong)
#set par(justify: true)

#show raw: set text(..font-theme.raw)
#show raw.where(block: true): it => {
  set par(justify: false)
  set block(above: 1.8em, below: 1.8em)
  pad(left: 1em, it)
}

// Show headings without numbering (but keeping numbering enabled for TOC)
// This heading rule must come first to be processed last, since it returns
// a non-heading object which will prevent further heading rules to be applied.
#show heading: it => block(below: 1.2em, it.body)

#set heading(numbering: "1.")

/*
  To customize the various headings, select on offset/depth/level:
   - offset 0 depth 1 level 1: section titles
   - offset 0 depth 2 level 2: section subtitle
   - offset 1 depth 1 level 2: slide title
   - offset 1 depth 2 level 3: slide subtitle
   - offset 3 depth 1 level 4: presentation titles
   - offset 3 depth 2 level 5: presentation subtitle

  The presentation title uses offset 3 so that `outline` with depth 1 or 2 can
  pick up the appropriate headings.
*/
#let heading-section-title = heading.where(offset: 0, depth: 1)
#let heading-section-subtitle = heading.where(offset: 0, depth: 2)
#let heading-slide-title = heading.where(offset: 1, depth: 1)
#let heading-slide-subtitle = heading.where(offset: 1, depth: 2)
#let heading-presentation-title = heading.where(offset: 3, depth: 1)
#let heading-presentation-subtitle = heading.where(offset: 3, depth: 2)

// Set a reasonable default text size relative to level 4 and 5,
// and compensate for scaling of text on the title slide.
// (The 1.4em and 1.2em are not put in font-theme.default because the values
// there should be relative to this reasonable default, as they are for other
// headings).
#show heading-presentation-title: set text(1.4em / title-slide-text-scale)
#show heading-presentation-subtitle: set text(1.2em / title-slide-text-scale)

// Apply title text settings
#show heading-section-title: set text(..font-theme.section-title)
#show heading-section-subtitle: set text(..font-theme.section-subtitle)
#show heading-slide-title: set text(..font-theme.slide-title)
#show heading-slide-subtitle: set text(..font-theme.slide-subtitle)
#show heading-presentation-title: set text(..font-theme.presentation-title)
#show heading-presentation-subtitle: set text(..font-theme.presentation-subtitle)

// Exclude section subtitles from outline
// (in case the user sets outline(depth: 2))
#show heading-section-subtitle: set heading(outlined: false)

// Layout for presentation title. A bit complicated as it must work whether a
// subtitle is present or not.
#show heading-presentation-title: it => {
  place(horizon, line(length: 100%, stroke: c.normal.progress-bar.fg))
  let h2 = query(<__minideck-title-h2>)
  let dy = if h2.len() == 0 {
    // The bottom padding is for the case with h2
    // -> add a small offset here to increase spacing when there's no h2
    -page-size.height/2 + margin.bottom - 0.3em
  } else {
    let y2 = h2.first().location().position().y
    y2 - (page-size.height - margin.bottom)
  }
  place(bottom, dy: dy, pad(bottom: 1.08em, it))
  block(spacing: 1.7em, height: 50%)
}

// Layout for presentation subtitle
#show heading-presentation-subtitle: it => {
  place(
    bottom,
    dy: -(page-size.height/2 - margin.bottom),
    [#metadata(none)<__minideck-title-h2> #pad(bottom: 1.6em, it)],
  )
}

// Layout for section title
#show heading-section-title: it => {
  if progress-bar {
    place(horizon, line(length: 100%, stroke: c.normal.progress-bar.bg))
    context {
      let (i, n) = util.progress()
      place(horizon, line(length: i/n * 100%, stroke: c.normal.progress-bar.fg))
    }
  } else {
    place(horizon, line(length: 100%, stroke: c.normal.progress-bar.fg))
  }
  let dy = -page-size.height/2 + margin.bottom
  place(bottom, dy: dy, pad(bottom: 0.9em, it))
  block(spacing: 1.2em, height: 50%)
}

// Layout for slide title
#show heading-slide-title: it => {
  set text(c.inverted.fg)
  let b = box(
    width: page-size.width,
    fill: c.inverted.bg,
    align(horizon+start, pad(0.85em, it)),
  )
  place(top+center, dy: -margin.top, float: true, clearance: 0pt, b)
}


#set list(indent: 1em, spacing: 1em)
#set enum(indent: 0.8em, spacing: 1em)
#set terms(indent: 0.6em, spacing: 1em)

#set bibliography(title: none)
#show bibliography: it => {
  set block(spacing: 2em)
  show regex("\[[0-9]+\]"): set align(top)
  it
}

#let footer = []

#let footer-code(footer) = context {
  set text(0.7em)
  set align(bottom)
  pad(
    left: -page.margin.left + footer-padding,
    right: -page.margin.right + footer-padding,
    bottom: footer-padding,
    {
      place(bottom+end, counter(page).display())
      footer
    },
  )
}

#set page(
  width: page-size.width,
  height: page-size.height,
  // Add noise to margins to prevent them getting normalized to a single value
  margin: (..margin, left: margin.left+1pt*1e-6, top: margin.top+1pt*1e-6),
  footer: footer-code(footer),
)

// Colors
#set text(c.normal.fg)
#set page(fill: c.normal.bg,)
#set footnote.entry(separator: line(length: 30%, stroke: 0.5pt+c.normal.fg))

// Disable outline title for consistency with bilbiography (which doesn't react
// to heading.offset like outline does), and other slides in general which all
// get their titles from `= ...` syntax.
// To show individual slide titles in outline: set depth 2, decrease
// block spacing, and make sure outline and bibliography have outlined: false
#set outline(title: none, depth: 1)
#show outline: set block(spacing: 0.8em)
#show outline.entry: it => {
  h(1em*(it.level - 1))
  it.body
  parbreak()
}

#set quote(block: true)
#show quote.where(block: false): set text(style: "italic")
#show quote.where(block: true): it => {
  block(width: 100%, above: 2.4em, below: 1.8em, pad(x: 1em, {
    emph(it.body)
    v(0.9em, weak: true)
    align(end, [— #it.attribution])
  }))
}


#let plain-slide = slide

#let slide(..args, it) = plain-slide(..args, {
  v(0.4fr)
  it
  v(0.6fr)
})

#let section(it) = {
  set page(margin: (x: 50% - 12em))
  set page(footer: none) if not show-footer
  // Use top alignment for content below the middle line
  set align(top)
  plain-slide(offset: 0, it)
}

#let standout(it) = {
  set page(fill: c.inverted.bg)
  set page(footer: none) if not show-footer
  set text(1.4em, c.inverted.fg, ..font-theme.standout)
  set align(horizon+center)
  plain-slide(offset: 0, it)
}

#let title(slide: slide, it) = {
  set page(footer: none) if not show-footer

  // Settings for content in the lower half:
  set align(top)
  show par: set block(below: 1em)
  set text(title-slide-text-scale*1em)

  plain-slide(offset: 3, it)
}

#let alert = text.with(c.normal.alert)

#let title-block(title-colors: c.normal.block-title, transparent: true, width: auto, title, it) = {
  let b1 = block.with(
    below: 0pt,
    inset: 0.4em,
    fill: if transparent { none } else { title-colors.bg},
    text(title-colors.fg, strong(title)),
  )
  let b2 = block.with(
    above: 0pt,
    inset: 0.4em,
    fill: if transparent { none } else { c.normal.block-body.bg },
    text(c.normal.block-body.fg, it),
  )
  block({
    if width == auto {
      // Calculate width as the largest between the two blocks but at most 100%.
      // This computation can be expensive. Note that even in case of
      // transparent background, having the same width for the title as the content can matter e.g. when centering the title. 
      layout(size => {
        let w1 = measure(b1()).width
        let w2 = measure(b2()).width
        let w = calc.min(size.width, calc.max(w1, w2))
        b1(width: w)
        b2(width: w)
      })
    } else {
      b1(width: width)
      b2(width: width)
    }
  })
}

#let example-block = title-block.with(title-colors: c.normal.block-title-example)
#let alert-block = title-block.with(title-colors: c.normal.block-title-alert)


#title[
  = Metropolis
  == An implementation for minideck

  Jeremie Knuesel

  #datetime.today().display("[month repr:long] [day], [year]")
]

#slide[
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

  ```typ
  #import "@preview/minideck:0.2.1"
  #let (template, slide, title, section) = minideck.config(
    theme: minideck.themes.metropolis)
  #show: template
  ```

  (On the `#let` line, list all the theme functions you want to use.)

  #v(1em)
  For other Typst implementations see Polylux@polylux and Touying@touying.
]

#slide[
  = Typography

  The default font theme is `fira-sans-light`. To use it, make sure you have _Fira Sans_ and _Fira Math_ installed!

  There is also a font theme `fira-sans` that uses regular weight for text and medium weight for titles. To use it, load the `metropolis` theme as

  ```typ
  minideck.config(
    theme: metropolis.with(font-theme: "fira-sans"))
  ```

  #v(1em)
  The theme provides an `alert` function for #alert[special emphasis].
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
  ]
  ```

  This will create a slide with the section title and a progress bar, plus optional subtitle(s) or other content.

  #v(1em)
  The progress bar can be disabled by loading the theme as\
  `metropolis.with(progress-bar: false)`
  
  #v(1em)
  By default the `#outline` function will show only the sections.
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

    + Last
  ][
    Terms:

    / PowerPoint: Meeh.

    / Beamer: Yeeeha.
  ]
]

#slide[
  = Blocks

  Show titled blocks with `title-block`, `alert-block` and `example-block`.

  Syntax: `#title-block(options...)[Title][Body]`.

  Options: `transparent: false` shows a background, `width` sets a fixed width.

  #set text(0.8em)

  #columns(2)[
    #title-block(width: auto)[Default][#lorem(8)]
    #alert-block(width: 16em)[Alert][Block content.]
    #example-block(width: 16em)[Example][Block content.]
    #colbreak()

    #title-block(transparent: false)[Default][#lorem(8)]
    #alert-block(transparent: false, width: 12em)[Alert][Block content.]
    #example-block(transparent: false, width: 12em)[Example][Block content.]
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

#slide[
  = Quotes
  #quote(attribution: [Julius Caesar])[Veni, vidi, vici]
]

#{
set page(footer: footer-code[My custom footer])
slide[
  = Frame footer

  Choose a footer with the `footer` theme option:

  ```typ
  minideck.config(
    theme: metropolis.with(footer: [My custom footer]))
  ```

  You can also override the complete footer (with page number) using `set page(footer:...)`

  #v(1em)
  Note: the footer is disabled by default on special slides. To override this behavior call e.g. `#section(show-footer: true)[...]`.
]
}

#section[
  = Conclusion

  Give it a try!
]

#standout[
  Questions?
]

<appendix>

#slide[
  = Backup slides

  #set par(justify: false)
  Any slide after the `<appendix>` label is ignored by the progress indicator.
]

#show link: strong.with(..font-theme.semi-strong)

#slide[
  = References

  #bibliography("works.bib") <bib>
]
