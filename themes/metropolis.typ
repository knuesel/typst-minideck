#import "/lib/lib.typ": *
#import styling: *

#let place-progress-bar(show-progress, colors) = context {
  if show-progress {
    let (i, n) = util.progress()
    place(horizon, line(length: 100%, stroke: colors.bg))
    place(horizon, line(length: i/n * 100%, stroke: colors.fg))
  } else {
    place(horizon, line(length: 100%, stroke: colors.fg))
  }
}

#let slide(cfg, plain-slide, center: true, ..args, it) = plain-slide(offset: 4, ..args, {
  if center {
    // Use tiny values so any user fractional spacing wins
    v(0.0004fr)
    it
    v(0.0006fr)
  } else {
    it
  }
})

#let section(cfg, plain-slide, show-progress: true, ..args, it) = {
  // TODO: use 50% - 11em once typst supports giving abs margins
  plain-slide(offset: 2, footer: none, margin: 50% - 11*22pt, ..args, {
    set align(top)
    place-progress-bar(show-progress, cfg.colors.progress-bar)
    block(height: 50%)
    it
  })
}

#let standout(cfg, plain-slide, ..args, it) = {
  set text(cfg.colors.bg) // done here to also affect header/footer
  plain-slide(offset: 4, footer: none, fill: cfg.colors.fg, ..args, {
    set text(size: 1.4em, weight: "bold")
    set align(horizon+center)
    it
  })
}

#let title-slide(cfg, plain-slide, ..args, it) = {
  plain-slide(offset: 0, footer: none, ..args, {
    set align(top)
    place(horizon, line(length: 100%, stroke: cfg.colors.progress-bar.fg))
    block(height: 50%, below: 2.4em)
    it

    let md = cfg.metadata
    set text(0.9em)
    {
      set block(below: 1em)
      md.author
      parbreak()
      md.date
    }
    block(above: 1.4em, {
      set text(0.8em)
      set block(spacing: 0.8em)
      md.affiliation
    })
  })
}
    
#let title-block(cfg, transparent: true, ..args, it-title, it-body) = {
  let title = (inset: 0.4em)
  let body = (inset: 0.4em)
  if not transparent {
    title.fill = cfg.colors.block-title-bg
    body.fill = cfg.colors.block-body-bg
  }
 layouts.title-block(title: title, body: body, ..args, it-title, it-body)
}

#let alert-block(cfg, ..args, it-title, it-body) = title-block(cfg, ..args,
  text(cfg.colors.alert, it-title),
  it-body,
)

#let example-block(cfg, ..args, it-title, it-body) = title-block(cfg, ..args,
  text(cfg.colors.example, it-title),
  it-body,
)

#let footer-func(..args) = text(0.7em, layouts.footer(padding: 1.5em, ..args))

#let title-bar(cfg, it) = layouts.top-bar(
  style: (fill: cfg.colors.fg),
  align(horizon+start, pad(0.85em, text(cfg.colors.bg, it))),
)

#let template(cfg, it) = {
  set page(
    // TODO: use 3em once typst supports giving abs margins
    margin: 66pt,
    fill: cfg.colors.bg,
    footer: footer-func(none),
  )

  // Set default font size before template, so that cfg fonts can override it
  set text(22pt)

  show: basic-template.with(cfg)

  // Show section titles without numbering (but keep numbering in the TOC)
  show section-title: it => it.body

  // Heading text styles
  // typst defaults: H1 1.4em, H2 1.2em, all headings bold
  // show presentation-title: set text() // default is good
  show presentation-subtitle: set text(weight: "regular")
  show section-title: set text(1.4em)
  show section-subtitle: set text(1.2em, weight: "regular")
  show slide-title: set text(1.2em)
  show slide-subtitle: set text(1.2em)
  show block-title.or(block-subtitle): set text(weight: "medium")

  // Layout for titles
  show presentation-title: it => layouts.place-relative(
    presentation-subtitle,
    anchor: bottom,
    default: _ => place(bottom, dy: -50%, pad(bottom: 1.38em, it)),
    pad(bottom: 1.08em, it),
  )
  show presentation-subtitle: it => place(bottom, dy: -50%, pad(bottom: 1.6em, it))
  show section-title: it => place(bottom, dy: -50%, pad(bottom: 0.9em, it))
  show slide-title: title-bar.with(cfg)

  // Links
  show link: set text(weight: "medium")

  // Outline
  show: outline-templates.with(cfg, spacing: 1.8em, title-gap: 0.3em, indent: 1em)
  // Make bold section titles only when slide titles are also shown
  show outline-sections-and-slides: it => {
    show outline.entry.where(level: 3): set text(weight: "bold")
    it
  }

  show bibliography: bibliography-template.with(cfg)

  // Lists
  set list(indent: 1em, spacing: 1em)
  set enum(indent: 0.8em, spacing: 1em)
  set terms(indent: 0.6em, spacing: 1em)

  // Raw text
  show raw.where(block: true): it => {
    set block(above: 1.8em, below: 1.8em)
    pad(left: 1em, it)
  }

  // Quotes
  show quote.where(block: false): set text(style: "italic")
  show quote.where(block: true): it => {
    block(width: 100%, above: 2.4em, below: 1.8em, pad(x: 1em, {
      emph(it.body)
      v(0.9em, weak: true)
      align(end, [#sym.dash.em #it.attribution])
    }))
  }

  it
}

// Compute named colors based on shades and accents
#let color-theme(cfg) = {
  let (bg, bg1, bg2, fg) = cfg.colors.shades
  let (alert, example) = cfg.colors.accents
  return (
    bg: bg,
    fg: fg,
    progress-bar: (
      bg: color.mix((alert, 15%), (fg, 15%), (bg, 70%)),
      fg: alert,
    ),
    block-title-bg: bg2,
    block-body-bg: bg1,
    alert: alert,
    example: example,
  )
}

#let properties = (
  font-scheme: "fira-sans-light",
  color-scheme: (
    shades: (white, rgb("#23373b")), // dark teal
    accents: (rgb("#eb811b"), rgb("#14b03d")), // red, green
  ),
  requirements: (
    n-fonts: 1,
    n-accents: 2,
    shade-samples: (2%, 10%, 20%, 100%),
  ),
)

#let metropolis(cfg: none, show-progress: true) = {
  // If no config was provided, return theme parameters
  if cfg == none { return properties }

  // Add named colors
  cfg.colors += color-theme(cfg)

  let plain-slide = cfg.plain-slide.with(footer-func: footer-func)

  return (
    cfg: cfg,
    template: template.with(cfg),
    slide: slide.with(cfg, plain-slide),
    section: section.with(cfg, plain-slide, show-progress: show-progress),
    title-slide: title-slide.with(cfg, plain-slide),
    standout: standout.with(cfg, plain-slide),
    title-block: title-block.with(cfg),
    alert-block: alert-block.with(cfg),
    example-block: example-block.with(cfg),
    alert: text.with(cfg.colors.alert),
    example: text.with(cfg.colors.example),
  )
}
