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

#let weight-schemes = (
  regular: (
    text: "regular",
    raw: "regular",
    math: "regular",
    title: "bold",
    subtitle: "regular",
    slide-title: "bold",
    slide-subtitle: "bold",
    strong-delta: 300,
  ),
  light: (
    text: "light",
    raw: "regular",
    math: "light",
    title: "regular",
    subtitle: "light",
    slide-title: "regular",
    slide-subtitle: "regular",
    strong-delta: 100,
  ),
)

#let size-schemes = (
  default: (
    text: 1em,
    raw: 1em,
    math: 1em,
  ),
)

#let font-themes = (
  default: (
    text: "Linux Libertine",
    raw: "DejaVu Sans Mono",
    math: "New Computer Modern Math",
    default-weight-scheme: "regular",
    default-text-size: 22pt,
  ),
  fira-sans: (
    text: "Fira Sans",
    raw: "Fira Mono",
    math: "Fira Math",
    default-weight-scheme: "light", // we want bolder raw for regular weight...
    default-text-size: 22pt, // we also want default raw and math size...
  ),
  libertinus-sans: (
    text: "Libertinus Sans",
    raw: "DejaVu Sans Mono",
    math: "New Computer Modern Math",
    default-weight-scheme: "regular",
    default-text-size: 22pt,
  ),
)


#import "lib.typ" as minideck
#import "util.typ"
#import "themes/metropolis-colors.typ" as colors
#import "paper.typ": papers

#let font-theme = "libertinus-sans"
#(font-theme = "fira-sans")
#let weight-scheme = auto
#let text-size = 22pt

#if type(font-theme) == str {
  font-theme = font-themes.at(font-theme)
}
#let weight-scheme = util.coalesce(weight-scheme, font-theme.default-weight-scheme)
#if type(weight-scheme) == str {
  weight-scheme = weight-schemes.at(weight-scheme)
}

#let text-size = util.coalesce(text-size, font-theme.default-text-size)

#let (template, slide, title-slide, pause) = minideck.config()

#let page-size = (width: papers.presentation-4-3.width*1mm, height: papers.presentation-4-3.height*1mm)
#let user-margin = 3em
#let margin = util.absolute-margins(user-margin, page-size, text-size)

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

#set text(font: font-theme.text, weight: weight-scheme.text, size: text-size)
#show math.equation: set text(font: font-theme.math, weight: weight-scheme.math)
#set strong(delta: weight-scheme.strong-delta)
#set par(justify: true)

#show raw.where(block: true): pad.with(left: 1em)
#show raw.where(block: true): set par(justify: false)
#show raw.where(block: true): set block(above: 1.8em, below: 1.8em)
#show raw: set text(font: font-theme.raw, weight: weight-scheme.raw)

// Show headings without numbering (but keeping numbering enabled for TOC)
// This heading rule must come first to be processed last, since it returns
// a non-heading object which will prevent further heading rules to be applied.
#show heading: it => block(below: 1.2em, it.body)

#set heading(numbering: "1.")

/*
  Most headings are in "regular" weight, which is bolder than the "light" text.
  To customize the various headings, select on level and depth:
   - level 1: presentation and section titles
   - level 2 depth 1: slide title
   - level 2 depth 2: presentation and section subtitle
   - level 3 depth 2: slide subtitle
*/
#show heading: set text(weight: "regular")
#show heading.where(level: 2, depth: 2): set text(weight: "light")

// #show heading.where(level: 2, depth: 2): set text(weight: "regular")


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
// To show individual slide titles in outline: set depth 2 and decrease
// block spacing.
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
  show heading.where(level: 2): it => {
    set text(c.inverted.fg)
    let b = box(
      width: page-size.width,
      fill: c.inverted.bg,
      align(horizon+left, pad(0.85em, it)),
    )
    place(top+center, dy: -margin.top, float: true, clearance: 0pt, b)
  }
  v(4fr)
  it
  v(6fr)
})

#let progress-bar-done() = context {
  let i = counter(page).get().first()
  let appendix = query(<appendix>)
  let n = if appendix.len() > 0 {
    // If an appendix label was found, count slides only till there
    counter(page).at(appendix.first().location()).first()
  } else {
    counter(page).final().first()
  }
  line(length: i/n * 100%, stroke: c.normal.progress-bar.fg)
}

#let section(slide: slide, progress-bar: true, it) = {
  set page(margin: (x: 50% - 12em), footer: none)
  // Use top alignment for content below the middle line
  set align(top)
  let title-gap = 28pt
  show heading.where(depth: 1): it => {
    let dy = -page-size.height/2 + margin.bottom - title-gap
    place(bottom, dy: dy, it)
  }
  plain-slide(offset: 0)[
    #if progress-bar {
      place(horizon, line(length: 100%, stroke: c.normal.progress-bar.bg))
      place(horizon, progress-bar-done())
    } else {
      place(horizon, line(length: 100%, stroke: c.normal.progress-bar.fg))
    }
    #block(spacing: 0pt, height: 50% + title-gap - 1.2em)
    #it
  ]
}

#let standout(slide: slide, it) = {
  set page(fill: c.inverted.bg, footer: none)
  set text(1.6em, c.inverted.fg, weight: "regular")
  set align(center)
  plain-slide(offset: 0, it)
}

// Layout of title and subtitle is a bit complicated as it must work
// whether a subtitle is present or not: in both cases it must fill the page
// up to the middle line.
#let title(slide: slide, it) = {
  let title-gap = 48pt
  set page(footer: none)
  // Use top alignment for content below the middle line
  set align(top)
  set heading(numbering: none, outlined: false)
  // Decrease spacing between paragraph for text in lower half
  show par: set block(spacing: 1em)
  show heading.where(depth: 2): it => {
    place(
      bottom,
      dy: -(page-size.height/2 - margin.bottom) - title-gap,
      [#metadata(none)<__minideck-title-h2> #it],
    )
  }
  show heading.where(depth: 1): it => {
    let h2 = query(<__minideck-title-h2>)
    let dy = if h2.len() == 0 {
      -page-size.height/2 + margin.bottom - title-gap
    } else {
      let y2 = h2.first().location().position().y
      y2 - (page-size.height - margin.bottom) - 1.2em
    }
    place(bottom, dy: dy, it)
  }
  plain-slide(offset: 0)[
    #place(horizon, line(length: 100%, stroke: c.normal.progress-bar.fg))
    #block(spacing: 0pt, height: 50% + title-gap - 1.2em)
    #it
  ]
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
  
  == Blob

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
