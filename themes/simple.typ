#import "/lib/lib.typ": *

// Layout for title slides: centered content and no footer/page numbers
#let title(plain-slide, ..args, it) = {
  plain-slide(footer: none, ..args, {
    set align(horizon+center)
    it
  })
}

#let template(cfg, it) = {
  // Set font size before template, so that cfg fonts can override it
  set text(24pt)
  // Apply basic template
  show: basic-template.with(cfg)
  // Make slide titles a bit larger
  show slide-title.or(section-title): set text(1.2em)
  // Color for links
  show link: set text(cfg.accents.at(0))

  // Outline
  show: outline-templates.with(cfg, indent: 1em)
  show outline.entry.where(level: 5): it => box(list.item(it))

  show bibliography: bibliography-template.with(cfg)

  it
}

#let simple(get-cfg, plain-slide, variant: "light") = {
  if variant not in ("light", "dark") {
    panic("invalid variant: must be \"light\" or \"dark\"")
  }

  plain-slide = plain-slide.with(
    footer-func: (..args) => text(0.8em, layouts.footer(..args)),
  )

  let cfg = get-cfg(
    shades: (default: (white, luma(15%)), reverse: variant == "dark"),
    accents: (n: 1, default: (blue,)),
  )
  
  return (
    cfg: cfg,
    title: title.with(plain-slide, offset: 0),
    section: title.with(plain-slide, offset: 2),
    slide: plain-slide.with(offset: 4),
    template: template.with(cfg),
  )
}
