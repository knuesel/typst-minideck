#import "/lib/lib.typ": *

#let place-progress-bar(show-progress, colors) = context {
  if show-progress {
    let (i, n) = util.progress()
    place(horizon, line(length: 100%, stroke: colors.bg))
    place(horizon, line(length: i/n * 100%, stroke: colors.fg))
  } else {
    place(horizon, line(length: 100%, stroke: colors.fg))
  }
}

#let footer-func(..args) = text(0.7em, layouts.basic-footer(padding: 1.5em, ..args))

#let title-bar(cfg, it) = layouts.top-bar(
  fill: cfg.colors.fg,
  align(horizon+start, pad(0.8em, text(cfg.colors.bg, it))),
)

#let slide(cfg, plain-slide, center: true, ..args, it) = {
  show slide-title: set text(1.2em)
  show slide-subtitle: set text(1.2em)

  show slide-title: title-bar.with(cfg)

  plain-slide(
    offset: 4,
    footer-func: footer-func,
    ..args,
    {
      if center {
        // Use tiny values so any user fractional spacing wins
        v(0.0004fr)
        it
        v(0.0006fr)
      } else {
        it
      }
    },
  )
}

#let section(cfg, plain-slide, show-progress: true, ..args, it) = {
  // Show section titles without numbering (but keep numbering in the TOC)
  show section-title: it => it.body

  show section-title: set text(1.4em)
  show section-subtitle: set text(1.2em, weight: "regular")

  show section-title: it => place(bottom, dy: -50%, pad(bottom: 0.9em, it))

  // TODO: use 50% - 11em once typst supports giving abs margins
  plain-slide(offset: 2, margin: 50% - 11*22pt, ..args, {
    set align(top)
    place-progress-bar(show-progress, cfg.colors.progress-bar)
    block(height: 50%)
    it
  })
}

#let standout(cfg, plain-slide, ..args, it) = {
  set text(cfg.colors.bg) // done here to also affect header/footer
  plain-slide(offset: 4, fill: cfg.colors.fg, ..args, {
    set text(size: 1.4em, weight: "bold")
    set align(horizon+center)
    it
  })
}

#let title-slide(cfg, plain-slide, ..args, it) = {
  // show presentation-title: set text() // default is good
  show presentation-subtitle: set text(weight: "regular")

  // Layout for titles
  show presentation-title: it => layouts.place-relative(
    target: <__minideck-h2>,
    anchor: bottom,
    default: _ => place(bottom, dy: -50%, pad(bottom: 1.38em, it)),
    pad(bottom: 1.08em, it),
  )
  show presentation-subtitle: it => place(
    bottom,
    dy: -50%,
    pad(bottom: 1.6em)[#it.body <__minideck-h2>],
  )

  let md = cfg.metadata
  plain-slide(offset: 0, ..args, {
    if md.logo != none {
      place(top, md.logo)
    }
    set align(top)
    place(horizon, line(length: 100%, stroke: cfg.colors.progress-bar.fg))
    block(height: 50%, below: 2.4em)
    it
    // Get rid of extra vertical space introduced by placed titles?
    v(0pt, weak: true)
    set text(0.9em)
    md.author
    v(1.2em, weak: true)
    md.date
    v(1.4em, weak: true)
    set text(0.8em)
    md.affiliation
  })
}
    
#let titled-block(cfg, transparent: true, ..args, it-title, it-body) = {
  show block-title.or(block-subtitle): set text(weight: "medium")

  let title-args = (inset: 0.4em)
  let body-args =  (inset: 0.4em)
  if not transparent {
    title-args.fill = cfg.colors.block-title-bg
    body-args.fill = cfg.colors.block-body-bg
  }
  layouts.titled-block(
    title: title-args,
    body: body-args,
    ..args,
    it-title,
    it-body,
  )
}

#let alert-block(cfg, ..args, it-title, it-body) = titled-block(cfg, ..args,
  text(cfg.colors.alert, it-title),
  it-body,
)

#let example-block(cfg, ..args, it-title, it-body) = titled-block(cfg, ..args,
  text(cfg.colors.example, it-title),
  it-body,
)

#let basic-template(cfg, doc) = {
  set page(
    // TODO: use 3em once typst supports giving abs margins
    margin: 66pt,
    fill: cfg.colors.bg,
  )

  // Set default font size before template, so that cfg fonts can override it
  set text(22pt)

  show: styling.basic-template.with(cfg)

  // Links in semibold except in the outline
  show link: it => context {
    if styling._in-outline.get() == false {
      set text(weight: "medium")
      it
    } else {
       it
    }
  }

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

  doc
}

#let outline-template(cfg, doc) = {
  // Outline
  show: styling.outline-template.with(cfg, spacing: 1.8em, title-gap: 0.3em, indent: 1em)
  // Make bold section titles only when slide titles are also shown
  show styling.outline-sections-and-slides: it => {
    show outline.entry.where(level: 3): set text(weight: "bold")
    it
  }
  doc
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
  name: "metropolis",
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

  return (
    basic-template: basic-template.with(cfg),
    outline-template: outline-template.with(cfg),
    bibliography-template: styling.bibliography-template.with(cfg),
    slide: slide.with(cfg, cfg.plain-slide),
    section: section.with(cfg, cfg.plain-slide, show-progress: show-progress),
    title-slide: title-slide.with(cfg, cfg.plain-slide),
    standout: standout.with(cfg, cfg.plain-slide),
    titled-block: titled-block.with(cfg),
    alert-block: alert-block.with(cfg),
    example-block: example-block.with(cfg),
    alert: text.with(cfg.colors.alert),
    example: text.with(cfg.colors.example),
  )
}
