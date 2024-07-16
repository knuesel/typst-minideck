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
  base-colors: (bg: luma(90%)), // override some base colors from variant
  palette: (
    normal: (block-title: (fg: blue)),
    inverted: (block-title: (fg: blue)),
  ),
)

#let c = colors.palette(user.variant, user.base-colors, user.palette)

#set text(font: "Fira Sans", weight: "light", size: text-size)
#show math.equation: set text(font: "Fira Math", weight: "light")
#set strong(delta: 100)
#set par(justify: true)
#set align(horizon)

#set heading(numbering: "1.")
#show heading: set text(1.05em, weight: "regular")

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
#show footnote.entry: set text(c.normal.footnote)
#set footnote.entry(separator: line(length: 30%, stroke: 0.5pt+c.normal.footnote))

// To show individual slide titles in outline: set depth 2 and decrease
// block spacing.
#set outline(title: [Table of contents], depth: 1)
#show outline: set block(spacing: 0.5em)
#show outline.entry: it => {
  h(1em*(it.level - 1))
  it.body
  parbreak()
}

#show outline: it => {
  set heading(offset: 1)
  show heading.where(level: 1): [#it.title#parbreak()]
  it
}

#let plain-slide = slide

// Show headings without numbering (but keeping numbering enabled for TOC)
#show heading: it => block(it.body)

#let slide(..args, it) = plain-slide(..args, {
  show heading.where(level: 2): it => {
    set text(c.inverted.fg)
    let b = box(
      width: page-size.width,
      fill: c.inverted.bg,
      align(horizon+left, pad(0.9em, it)),
    )
    // Place title box at top of slide
    place(top+center, dy: -margin.top, b)
    // Push other slide content down by height of box
    v(measure(b).height)
  }
  it
})

#let progress-bar-done() = context {
  let i = counter(page).get().first()
  let n = counter(page).final().first()
  line(length: i/n * 100%, stroke: c.normal.progress-bar.fg)
}

#let section(slide: slide, it) = {
  set page(margin: (x: 50% - 12em), footer: none)
  set align(top)
  let title-gap = 28pt
  show heading.where(depth: 1): it => {
    let dy = -page-size.height/2 + margin.bottom - title-gap
    place(bottom, dy: dy, it)
  }
  show heading.where(depth: 2): set text(weight: "light")
  plain-slide(offset: 0)[
    #place(horizon, line(length: 100%, stroke: c.normal.progress-bar.bg))
    #place(horizon, progress-bar-done())
    #block(spacing: 0pt, height: 50% + title-gap - 1.2em)
    #it
  ]
}


#let title(slide: slide, it) = {
  let title-gap = 48pt
  set page(footer: none)
  set align(top)
  set heading(numbering: none, outlined: false)
  show heading.where(depth: 2): it => {
    set text(weight: "light")
    place(
      bottom,
      dy: -(page-size.height/2 - margin.bottom) - title-gap,
      [#metadata(none)<__minideck-title-h2> #it],
    )
  }
  show heading.where(depth: 1): it => {
    set text(weight: "regular", 1.2em)
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

#title[
  = Metropolis
  == An implementation for minideck

  Jeremie Knuesel

  #datetime.today().display("[month repr:long] [day], [year]")

  #v(0.3em)
  #text(0.8em)[BFH-TI]
]

#slide[
  #outline()
]

#section[
  = Introduction
]

#slide[
  = Metropolis

  $ e = lim_(n -> infinity) $
]

#slide[
  = Hello

  Adsfsdf#footnote[feet]
]

#section[
  = Second section
  
  blabla
]

#slide[
  = Another
]


#slide[
  = Another

  sadfsdf


  #lorem(200)
]



