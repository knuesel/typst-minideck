#import "/lib/lib.typ": *
#import styling: *

#let title-slide(cfg, plain-slide, ..args, it) = {
  let md = cfg.metadata
  plain-slide(offset: 0, ..args, {
    place(top, layouts.use-margin(top: 100%, left: 100%, md.logo))
    set align(horizon+center)
    it // titles and possibly other content
    set text(0.9em)
    {
      set block(above: 2.5em)
      parbreak()
      md.author
    }
    {
      set text(0.8em)
      set block(spacing: 0.8em)
      parbreak()
      md.affiliation
    }
    set block(above: 2.5em)
    parbreak()
    md.date
  })
}

#let section(cfg, plain-slide, ..args, it) = {
  plain-slide(offset: 2, ..args, {
    set align(horizon+center)
    it // titles and possibly other content
  })
}

#let template(cfg, it) = {
  // Set font size before template, so that cfg fonts can override it
  set text(24pt)
  // Apply basic template
  show: basic-template.with(cfg)
  // Make titles a bit larger
  show presentation-title
    .or(slide-title): set text(1.2em)
  show section-title: set text(1.3em)
  // Color for links
  show link: set text(cfg.colors.accents.at(0))

  // Outline
  show: outline-templates.with(cfg, indent: 1em)
  show outline.entry.where(level: 5): it => box(list.item(it))

  show bibliography: bibliography-template.with(cfg)

  it
}

#let footer-func(..args) = text(0.8em, layouts.basic-footer(..args))

#let properties = (
  font-scheme: fonts.schemes.default,
  color-scheme: (
    shades: (white, luma(15%)),
    accents: (blue,),
  ),
  requirements: (
    n-fonts: 1,
    n-accents: 1,
    shade-samples: (0%, 100%),
  ),
)

#let simple(cfg: none) = {
  // If no config was provided, return theme parameters
  if cfg == none { return properties }

  return (
    cfg: cfg,
    title-slide: title-slide.with(cfg, cfg.plain-slide),
    section: section.with(cfg, cfg.plain-slide),
    slide: cfg.plain-slide.with(offset: 4, footer-func: footer-func),
    template: template.with(cfg),
  )
}
