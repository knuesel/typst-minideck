#import "@local/minideck:0.3.0" // XXX change local to preview

// Custom theme
#let properties = (
  name: "custom",
  font-scheme: "default",
  color-scheme: (
    shades: (white, black),
    accents: (olive, maroon),
  ),
  requirements: (
    n-fonts: 1,
    n-accents: 2,
    shade-samples: (2%, 98%),
  ),
)
#let custom-theme(cfg: none) = {
  // If no config was provided, return theme parameters
  if cfg == none { return properties }

  return (
    outline-template: doc => {
      // show outline: set block(spacing: 4em)
      // show: minideck.styling.outline-template.with(cfg)
      // show outline: it => {
      //   set block(spacing: 3em)
      //   it
      // }

      // show outline: set par(spacing: 3em)

      show outline: it => {
        show par: p => {
          repr(p)
        }
        it
      }
  
      // Indent slide titles (every line after first paragraph line) under section
      show outline: set par(hanging-indent: 1em)


      show outline.entry: it => link(it.element.location(), it.body)

      // Make each section its own paragraph (with large spacing between
      // paragraphs using the outline block spacing).
      show outline.entry.where(level: 3): it => {
          parbreak()
          // Add some spacing between section title and slide title without breaking
          // into two paragraphs.
          box(inset: (bottom: 1em), fill: red, it)
      }

      doc
    }
  )
}


#let (template, slide, section, title-slide) = minideck.config(
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
    simple: "libertinus-sans",
  ),
  // font-scheme: "fira-sans",
  theme: (
    base: "simple",
    title-slide: "metropolis",
    outline-template: custom-theme,
  ),
)

#show: template
#set outline(depth: 5)

#title-slide[
  = Slides with minideck
  == Mixing and matching themes
]

#slide(outlined: false)[
  = Table of contents

  #link("https://www.example.com")

  #outline()
]

#section[= Section A]
#slide[= X]
#slide[= X2]
#section[= Section B]
#slide[= Y]
