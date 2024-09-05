#import "/package.typ" as minideck

#let (template, slide, pause, uncover, only) = minideck.config()

#show: template

#slide[
  = Subslides with `pause`

  Paused enums require explicit numbering:
  #v(1em)
  #grid(columns: (50%, 50%),
    ```typ
    1. One
    #show: pause
    2. Two  // not `+ Two`
    ```,
    [
      1. One
      #show: pause
      2. Two
    ],
  )
]

#slide[
  = Subslides with `uncover` and `only`

  #set par(justify: true)

  #uncover(1, from: 3)[
    `#uncover(1, from: 3)[...]`\
    #sym.arrow visible on subslides 1 and 3+ (space reserved on 2)
  ]

  #only(2, 3)[
    `#only(2, 3)[...]`\
    #sym.arrow included on subslides 2 and 3 (no space reserved on 1)
  ]

  Normal text: this content is always visible
]

#slide[
  = Dynamic equations

  #set align(center)

  ```typ
  $
    f(x) &= x^2 + 2x + 1  \
         #uncover(2, $&= (x + 1)^2$)
  $
  ```

  #v(1em)

  $
    f(x) &= x^2 + 2x + 1  \
         #uncover(2, $&= (x + 1)^2$)
  $

  // XXX add numbering once fixed
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
 
]

#import "@preview/cetz:0.2.2" as cetz: *

#let (slide, only, cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

#let _subslide-count = state("__minideck-subslide-count", (0, 0))

#slide[
  == CeTZ: subslide #context (state("__minideck-subslide-step", 0).get()+1)

  Above canvas
  #context canvas({
    import draw: *
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on subslide 2]
    ])
  })
  Below canvas
]


#import "@preview/fletcher:0.5.0" as fletcher: diagram, node, edge

#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)

#slide(steps: 2)[
  == Fletcher: subslide #context (state("__minideck-subslide-step", 0).get()+1)

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


