#import "/lib/lib.typ": *
#import styling

#let footer-func(..args) = text(0.8em, layouts.basic-footer(..args))

#let title-slide(cfg, plain-slide, ..args, it) = {
  show presentation-title: set text(1.2em)

  let md = cfg.metadata
  plain-slide(offset: 0, ..args, {
    place(top, layouts.use-margin(top: 100%, left: 100%, md.logo))
    set align(horizon+center)
    v(10%)
    it // titles and possibly other content
    set text(0.9em)
    v(2.5em, weak: true)
    md.author
    set text(0.8em)
    v(0.8em, weak: true)
    md.affiliation
    v(2.5em, weak: true)
    md.date
  })
}

#let section(cfg, plain-slide, ..args, it) = {
  show section-title: set text(1.3em)

  plain-slide(offset: 2, ..args, {
    set align(horizon+center)
    it // titles and possibly other content
  })
}

#let slide(cfg, plain-slide, ..args, it) = {
  show slide-title: set text(1.2em)

  plain-slide(offset: 4, footer-func: footer-func, ..args, it)
}

#let basic-template(cfg, doc) = {
  set text(24pt)
  show: styling.basic-template.with(cfg)

  // Color for links except in the outline
  show link: it => context {
    if styling._in-outline.get() {
      it
    } else {
      set text(cfg.colors.accents.first())
      it
    }
  }
  doc
}

#let outline-template(cfg, doc) = {
  show: styling.outline-template.with(cfg, indent: 1em)
  show outline.entry.where(level: 5): it => box(list.item(it))
  doc
}

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
    title-slide: title-slide.with(cfg, cfg.plain-slide),
    section: section.with(cfg, cfg.plain-slide),
    slide: slide.with(cfg, cfg.plain-slide),
    basic-template: basic-template.with(cfg),
    outline-template: outline-template.with(cfg),
    bibliography-template: styling.bibliography-template.with(cfg),
  )
}
