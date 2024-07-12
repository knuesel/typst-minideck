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

*/

#import "lib.typ" as minideck
#import "util.typ"
#import "themes/metropolis-colors.typ" as colors
#import "paper.typ": papers

#let (template, slide, title-slide, pause) = minideck.config()

#let paper-size = (width: papers.presentation-4-3.width*1mm, height: papers.presentation-4-3.height*1mm)
#let text-size = 20pt
#let user-margin = 2.5em
#let margin = util.absolute-margins(user-margin, paper-size, text-size)
#let slide-title-padding = (left: 1em)
#let slide-title-align = horizon+left
#let slide-title-box-height = 2.4em
#let slide-title-text-size = 24pt
#let slide-title-gap = auto
#let slide-title-gap-abs = util.length-to-abs(
  util.coalesce(on: auto, slide-title-gap, margin.top), paper-size, text-size)

#let user = (
  variant: "light",
  base-colors: (bg: luma(90%), alert: red), // override some base colors from variant
  palette: (
    main: (block-title: (fg: blue)),
    inverted: (block-title: (fg: blue)),
  ),
)

#let c = colors.palette(user.variant, user.base-colors, user.palette)

// #show heading: set block(below: 1em)
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math", weight: "light")
#set strong(delta: 100)
#set par(justify: true)

#set heading(numbering: "1.")
#show heading: set text(weight: "regular")

#set page(
  width: paper-size.width,
  height: paper-size.height,
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

#show heading: it => it.body

#show heading.where(level: 2): it => {
  set text(c.normal.bg, size: slide-title-text-size)
  let b = box(
    width: paper-size.width,
    height: slide-title-box-height,
    fill: c.normal.fg,
    align(slide-title-align, pad(..slide-title-padding, it)),
  )
  place(top+center, dy: -margin.top, b)
  v(measure(b).height - margin.top + slide-title-gap-abs)
}

// #show heading.where(level: 1): set page(fill: red)

#let section(it) = {
  set page(footer: none)
  set align(horizon+center)
  slide(offset: 0, it)
}

#let title(it) = {
  set page(footer: none)
  set align(horizon+center)
  set heading(numbering: none, outlined: false)
  slide(offset: 0, it)
}

#title[
  = Title

]

#slide[
  #outline()
]

#section[
  = First section
]

#slide[
  = blob
]

#slide[
  = Some slide

  $ e = lim_(n -> infinity) $
]


#slide[
  = Second section
]


#slide[
  = Hello

  Adsfsdf#footnote[blob]
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



