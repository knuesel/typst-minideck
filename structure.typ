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
#let user-margin = 2.5em
#let margin = util.absolute-margins(user-margin, page-size, text-size)
#let slide-title-padding = (rest: 1em)
#let slide-title-align = horizon+left
#let slide-title-box-height = 2.4em
// #let slide-title-text-size = 24pt
#let slide-title-gap = auto
#let slide-title-gap-abs = util.length-to-abs(
  util.coalesce(on: auto, slide-title-gap, margin.top), page-size, text-size)

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

#set heading(numbering: "1.")
#show heading: set text(weight: "regular")

#set page(
  width: page-size.width,
  height: page-size.height,
  margin: margin,
  // header-ascent: 0pt,
  // footer-descent: 0pt,
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
#show heading: it => it.body

#let slide(..args, it) = plain-slide(..args, {
  show heading.where(level: 2): it => {
    // Prepare heading rectangle
    set text(c.inverted.fg)
    let b = box(
      width: page-size.width,
      height: slide-title-box-height,
      fill: c.inverted.bg,
      align(slide-title-align, pad(..slide-title-padding, it)),
    )
    // Show heading as rectangle at top of slide
    place(top+center, dy: -margin.top, b)
    // Add spacing with slide content equal to title gap setting
    v(measure(b).height - margin.top + slide-title-gap-abs)
  }
  it
})

#let section(it) = {
  set page(footer: none)
  set align(horizon+center)
  plain-slide(offset: 0, it)
}

#let title-gap = 48pt

#let title(slide: slide, it) = {
  set page(footer: none)
  set heading(numbering: none, outlined: false)
  show heading.where(depth: 2): it => {
    set text(weight: "light", 1.1em)
    place(
      bottom,
      dy: -(page-size.height/2 - margin.bottom) - title-gap,
      [#metadata(none)<title-h2> #it],
    )
  }
  show heading.where(depth: 1): it => {
    set text(weight: "regular", 1.2em)
    let h2 = query(<title-h2>)
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
  #v(1fr)
  #outline()
  #v(2fr)
]

#section[
  = First section
]

#slide[
  = Some slide

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
]



