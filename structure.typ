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
    strong: (:),
  ),
  fira-sans: (
    text: (font: "Fira Sans",),
    raw: (font: "Fira Mono",),
    math: (font: "Fira Math",),
    presentation-subtitle: (weight: "regular",),
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
    strong: (delta: 100),
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

#let font-theme = "libertinus-sans"
#let font-theme = "fira-sans-light"
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

// Text smaller than normal size in lower half of title slide
#let title-slide-text-scale = 0.9

#let user = (
  variant: "light",
  // base-colors: (:),
  base-colors: (bg: luma(90%)), // override some base colors from variant
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

// Set a reasonable default text size relative to level 4 and 5
// (and compensate for scaling of text on the title slide)
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
    -page-size.height/2 + margin.bottom
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
  block(spacing: 0pt, height: 50%)
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


#set list(indent: 1em)
#set enum(indent: 0.8em)

#set bibliography(title: none)
#show bibliography: it => {
  set block(spacing: 2em)
  show regex("\[[0-9]+\]"): set align(top)
  it
}


#set page(
  width: page-size.width,
  height: page-size.height,
  margin: margin,
  footer: context {
    set text(0.8em)
    set align(bottom+right)
    pad(x: -margin.right+1.5em, y: 1.5em, counter(page).display())
  },
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
#show outline: set block(spacing: 0.5em)
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
  v(4fr)
  it
  v(6fr)
})

#let section(it) = {
  set page(margin: (x: 50% - 12em), footer: none)
  // Use top alignment for content below the middle line
  set align(top)
  plain-slide(offset: 0, it)
}

#let standout(it) = {
  set page(fill: c.inverted.bg, footer: none)
  set text(1.4em, c.inverted.fg, weight: "regular")
  // set text(1.6em, c.inverted.fg) // XXX check weight
  set align(horizon+center)
  plain-slide(offset: 0, it)
}

#let title(slide: slide, it) = {
  set page(footer: none)

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

  Matthias Vogelgesang

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

  The *Metropolis* theme was created by Matthias Vogelgesang for Beamer. @metropolis

  This is an implementation for the minideck Typst package. @minideck@typst

  Enable this theme with

  ```typ
  #import "@preview/minideck:0.2.1"
  #let (template, slide, title, section) = minideck.config(
    theme: minideck.themes.metropolis)
  #show: template
  ```

  (On the `#let` line, list all the theme functions you want to use.)
]

#slide[
  = Presentation title

  The `#title` command creates a title slide.
  
  Headers are defined with the usual typst syntax.

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

  This will create a slide with the section title and a progress bar.

  The progress bar can be disabled by loading the theme as\
  `metropolis.with(progress-bar: false)`
  
  By default the `#outline` function will show only the sections.
]

#section[
  = Elements

  sfadsf
]

#slide[
  = Typography

  
]

#slide[
  = Lists

  #grid(columns: (1fr,)*3, align: top)[
    Items:

    - Milk

    - Eggs

    - Potatos
  ][
    Enumerations:

    + First,

    + Second and

    + Last
  ][
    Descriptions:

    / PowerPoint: Meeh.
    / Beamer: Yeeeha.
  ]
]

#slide[
  = Blocks

  #columns(2)[
    #title-block(width: auto)[Default][#lorem(20)]
    #alert-block(width: 16em)[Alert][Block content.]
    #example-block(width: 16em)[Example][Block content.]
    #colbreak()

    #title-block(transparent: false)[Default][#lorem(20)]
    #alert-block(transparent: false, width: 12em)[Alert][Block content.]
    #example-block(transparent: false, width: 12em)[Example][Block content.]
  ]
]

#slide[
  = Math
  
  $ e = lim_(n -> infinity) (1 + 1/n)^n $
]

#slide[
  = Quotes
  #quote(attribution: [Julius Caesar])[Veni, vidi, vici]
]

#slide[
  = Frame footer

  Text

  ```
  raw
  ```

  Adsfsdf#footnote[feet]

  #lorem(20)

  #lorem(20)
]

#section[
  = Second section
  
  == Second section subtitle

  Text
]

#standout[
  Questions?
]

<appendix>

#slide[
  = Backup slides

  Any slide after the `<appendix>` label is ignored by the progress indicator.

  The page number is still shown (contrary to the original Metropolis theme) as it seems harmless and potentially useful to me.
]

#slide[
  = Bibliography

  #bibliography("works.bib") <bib>
]
