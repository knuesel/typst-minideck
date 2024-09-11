#import "/lib/lib.typ": *
#import styling: *

#let title(cfg, plain-slide, ..args, it) = {
  let md = cfg.metadata
  plain-slide(offset: 0, footer: none, ..args, {
    place(top, layouts.protrude(top: 100%, left: 100%, md.logo))
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
  // Make titles a bit larger
  show presentation-title
    .or(slide-title)
    .or(section-title): set text(1.2em)
  // Color for links
  show link: set text(cfg.colors.accents.at(0))

  // Outline
  show: outline-templates.with(cfg, indent: 1em)
  show outline.entry.where(level: 5): it => box(list.item(it))

  show bibliography: bibliography-template.with(cfg)

  it
}

#let simple(get-config, plain-slide) = {
  plain-slide = plain-slide.with(
    footer-func: (..args) => text(0.8em, layouts.footer(..args)),
  )

  let cfg = get-config(
    shade-samples: (0%, 100%),
    n-accents: 1,
    default-color-scheme: (
      shades: (white, luma(15%)),
      accents: (blue,),
    )
  )
  
  return (
    cfg: cfg,
    title: title.with(cfg, plain-slide),
    section: section.with(cfg, plain-slide),
    slide: plain-slide.with(offset: 4),
    template: template.with(cfg),
  )
}
