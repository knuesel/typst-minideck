#import "/lib/lib.typ": *
#import styling: *

#let title(cfg, plain-slide, ..args, it) = {
  let md = cfg.metadata
  plain-slide(offset: 0, footer: none, ..args, {
    place(top, layouts.protrude(top: 100%, x: 100%, md.logos.join(h(1fr))))
    set align(horizon+center)
    it // titles and possibly other content
    set text(0.9em)
    {
      set block(above: 2.5em)
      parbreak()
      md.authors.join(h(2em))
    }
    {
      set text(0.8em)
      set block(spacing: 0.8em)
      parbreak()
      md.affiliations.join(parbreak())
    }
    set block(above: 2.5em)
    parbreak()
    md.date
  })
}

#let section(cfg, plain-slide, ..args, it) = {
  plain-slide(offset: 2, footer: none, ..args, {
    set align(horizon+center)
    it // titles and possibly other content
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
    title: title.with(cfg, plain-slide),
    section: section.with(cfg, plain-slide),
    slide: plain-slide.with(offset: 4),
    template: template.with(cfg),
  )
}
