#import "@local/minideck:0.3.0" // XXX
#import minideck.themes: *
#import minideck.util

#let color-scheme = (
  shades: (white, rgb("#5c1d06"), black),
  accents: (rgb("#67b765"),),
)

// XXX todo: for outline group template, use background image instead of gradient

// #let outline-icon = scale(x: -100%, image("leaf.svg", width: 1.3em))
// #let logo = layout(size => {
//   let img = image("logo.svg", width: 40%)
//   img
//   place(top+left, block(..measure(img, ..size), fill: bg.transparentize(10%)))
// })
#let theme = minideck.themes.fancy.with(
  // outline: (icon: outline-icon),
)
#let (template, slide, section, title-slide) = minideck.config(
  // color-scheme: (
  //   shades: (white, rgb("#5c1d06"), black),
  //   accents: (rgb("#67b765"),),
  // ),
  theme: theme,
  author: [John Doe],
  date: datetime.today().display("[month repr:long] [day], [year]"),
  affiliation: [Center for minideck themes],
  logo: image("logo.svg", width: 12cm),
)

#show: template

#set outline(depth: 5)

#title-slide[
  = Fancy
  == A minideck theme for demonstration purposes
]

#slide(outlined: false)[ // for example further down (outline with slide titles)
  = Table of contents
  // #v(1em)
  #outline()
]

#section[ = Introduction ]

#slide[ = A1 ]
#slide[ = A2 ]
#slide[ = A3 ]
#slide[ = A4 ]

#section[ = More stuff... ]

#slide[
  = B1
]
#slide[
  = B2
]

#section[ = Yet more stuff #lorem(10)]

#slide[
  = C
]

#section[ = Even more stuff ]
#slide[
  = D
]

#section[ = Last stuff]
