#import "/package.typ" as minideck

#let (template, slide, title-slide) = minideck.config(
  author: [John Doe#super[1]],
  affiliation: [#super[1]Euphoric State University],
  date: [Minideck Symposium, 4#super[th] September 2024],
  color-scheme: (
    // metropolis: (accents: (red,)),
    simple: (accents: (green,)),
    // accents: (green,),
  ),
  font-scheme: (
    // Note: changing the metropolis font scheme is useless since metropolis
    // uses fonts only in basic-template which we don't use (we use only
    // title-slide from metropolis)
    simple: "fira-sans",
  ),
  // font-scheme: "fira-sans",
  theme: (
    base: "simple",
    title-slide: "metropolis",
  ),
)

#show: template
#title-slide[
  = Slides with minideck
  == Mixing and matching themes
]

#slide(outlined: false)[
  = Table of contents

  #link("https://www.example.com")

  #outline()
]


