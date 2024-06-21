#let variants = (
  light: (
    bg: rgb("#eff1f3"),
    fg: rgb("#3c3c3c"),
  ),
  dark: (
    bg: rgb("#3c3c3c"),
    fg: rgb("#eff1f3"),
  ),
)
#let theme(paper: auto, variant: none, it) = {
  show heading: set block(below: 1em)
  set page(
    paper: paper,
    footer: context {
      set text(0.8em)
      if here().page() > 1 {
        place(right, dx: 1cm, counter(page).display())
      }
    },
    background: rect(width: 100%, height: 100%, fill: variants.at(variant).bg),
  )
  set text(
    24pt,
    fill: variants.at(variant).fg,
    font: "Libertinus Sans",
  )
  it
}

#let title-slide(slide, it) = {
  set page(footer: none)
  set align(horizon+center)
  slide(it)
}

#let config(slide, paper: "presentation-4-3", variant: "light") = {
  (
    slide: slide,
    title-slide: title-slide.with(slide),
    theme: theme.with(paper: paper, variant: variant)
  )
}

#let with(..args) = config.with(..args)
