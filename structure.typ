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

#import "lib.typ" as minideck
#import "util.typ"
#import "themes/metropolis-colors.typ" as colors
#import "paper.typ": papers

#let (template, slide, title-slide, pause) = minideck.config()

#let page-size = (width: papers.presentation-4-3.width*1mm, height: papers.presentation-4-3.height*1mm)
#let text-size = 20pt
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

#set text(font: "Fira Sans", weight: "light", size: text-size)
#show math.equation: set text(font: "Fira Math", weight: "light")
#set strong(delta: 100)
#set par(justify: true)
#set align(horizon)

// Show headings without numbering (but keeping numbering enabled for TOC)
// This heading rule must come first to be processed last, since it returns
// a non-heading object which will prevent further heading rules to be applied.
#show heading: it => block(below: 1.2em, it.body)

#set heading(numbering: "1.")

// Presentation and section title
#show heading.where(level: 1): set text(1.1em, weight: "regular")
// Presentation and section subtitle
#show heading.where(level: 2, depth: 2): set text(1.1em, weight: "light")
// Slide title
#show heading.where(level: 2, depth: 1): set text(1.05em, weight: "regular")
// Slide subtitle
#show heading.where(level: 3, depth: 2): set text(1.1em, weight: "regular")


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

// To show individual slide titles in outline: set depth 2 and decrease
// block spacing.
#set outline(title: [Table of contents], depth: 1)
#show outline: it => {
  set block(spacing: 0.5em)
  set heading(offset: 1)
  show heading.where(level: 1): [#it.title#parbreak()]
  it
}
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
      align(horizon+left, pad(0.9em, it)),
    )
    place(top+center, dy: -margin.top, float: true, clearance: 0pt, b)
  }
  it
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

#let section(slide: slide, it) = {
  set page(margin: (x: 50% - 12em), footer: none)
  // Use top alignment for content below the middle line
  set align(top)
  let title-gap = 28pt
  show heading.where(depth: 1): it => {
    let dy = -page-size.height/2 + margin.bottom - title-gap
    place(bottom, dy: dy, it)
  }
  plain-slide(offset: 0)[
    #place(horizon, line(length: 100%, stroke: c.normal.progress-bar.bg))
    #place(horizon, progress-bar-done())
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

#let title(slide: slide, it) = {
  let title-gap = 48pt
  set page(footer: none)
  // Use top alignment for content below the middle line
  set align(top)
  set heading(numbering: none, outlined: false)
  // Decrease spacing between paragraph for text in lower half
  show par: set block(spacing: 1em)
  // Layout of title and subtitle is a bit complicated as it must work
  // whether a subtitle is present or not: in both cases it must fill the page
  // up to the middle line.
  show heading.where(depth: 2): it => {
    place(
      bottom,
      dy: -(page-size.height/2 - margin.bottom) - title-gap,
      [#metadata(none)<__minideck-title-h2> #it],
    )
  }
  show heading.where(depth: 1): it => {
    // set text(1.1em)
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

  #v(0.5em)
  #text(0.8em)[BFH-TI]
]

#slide[
  #outline()
]

#section[
  = Introduction

  == blob
]

#slide[
  = Metropolis

  Blob
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

  #place(hide[@knuth @nash51])

  #bibliography("works.bib") <bib>
]
