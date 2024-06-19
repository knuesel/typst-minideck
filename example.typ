#import "@local/minideck:0.1.0": *

#set page(paper: "presentation-4-3")
#set text(24pt, fill: rgb("#42505a"), font: "Libertinus Sans")
#show heading: set block(below: 1em)

#title-slide[
  = Slides with `minideck`
  == Some examples
  John Doe

  #datetime.today().display()
]

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


#import "@preview/cetz:0.2.2" as cetz: *

#import "@local/minideck:0.1.0"

#let (slide, only, cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

#slide[
  = In a CeTZ figure

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
]


#import "@preview/fletcher:0.5.0" as fletcher: diagram, node, edge

#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)

#slide(steps: 2)[
  = `only` and `uncover` in a fletcher diagram

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

