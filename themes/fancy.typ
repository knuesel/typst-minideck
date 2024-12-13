#import "/lib/lib.typ": *

// XXX todo: footer in purple

#let footer-func(..args) = text(0.8em, layouts.basic-footer(..args))

#let transparent-image(cfg, alpha: 50%, it) = layout(size => {
  // We cover the image with a transparantized background color, so the image
  // alpha is the image transparency value
  let bg = cfg.colors.shades.first().transparentize(alpha)
  it
  place(top+left, block(..measure(it, ..size), fill: bg))
})

#let numbered-title(
  cfg,
  align: none,
  number: none,
  text: none,
  gutter: none,
  i,
  it,
) = {
  let (bg-accent, title-accent, ..) = cfg.colors.accents
  let (font-main, font-title, font-small-title) = cfg.fonts
  set grid.cell(breakable: false)
  grid(
    columns: (number.width, text.width),
    align: align,
    column-gutter: gutter,
    std.text(
      ..font-title.text,
      size: number.size,
      fill: title-accent,
      if i == none { none } else { str(i) },
    ),
    std.text(text.size, it),
  )
}

#let title-slide(
  cfg,
  plain-slide,
  background: pad(2mm, scale(x: -100%, image("assets/mountains.svg", width: 85%))),
  ..args,
  it,
) = {
  let (bg, .., fg) = cfg.colors.shades
  let (font-main, font-title, font-small-title) = cfg.fonts

  // Keep these two rules separate in case: the secone one might also set a
  // relative size to adjust the font scale
  show presentation-title: set text(
    size: 1.4em,
    fill: cfg.colors.accents.at(1),
  )
  show presentation-title: set text(..font-title.text)

  show presentation-subtitle: set text(..font-small-title.text)

  // With fancy fonts the required text size might be larger than usual,
  // so it's best to set block spacing independently of the font size
  show heading: set block(below: 10%)
  
  let md = cfg.metadata
  plain-slide(
    offset: 0,
    background: place(
      bottom+left,
      transparent-image(cfg, alpha: cfg.background-alpha, background),
    ),
    ..args,
    {
      place(top+right, layouts.use-margin(top: 100%-2mm, right: 100%-2mm, {
        transparent-image(cfg, alpha: cfg.background-alpha, md.logo)
      }))
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
  },
  )
}

#let section(
  cfg,
  plain-slide,
  background: pad(2mm, image("assets/mountains-high.svg", width: 40%)),
  ..args,
  it,
) = {
  let (font-main, font-title, font-small-title) = cfg.fonts

  // Keep these two rules separate in case: the secone one might also set a
  // relative size to adjust the font scale
  show section-title: set text(size: 1.3em)
  show section-title: set text(..font-small-title.text)

  show section-title: it => {
    if it.numbering == none {
      return it
    }
    numbered-title(
      cfg,
      align: horizon,
      number: (size: 1.6em, width: 1.2em),
      text: (size: 1em, width: auto),
      gutter: 0.8em,
      counter(heading).get().at(2),
      it.body,
    )
  }

  plain-slide(
    offset: 2,
    background: place(
      bottom+right,
      transparent-image(cfg, alpha: cfg.background-alpha, background),
    ),
    ..args,
    {
      set align(horizon+center)
      it // titles and possibly other content
    },
  )
}

#let slide(
  cfg,
  plain-slide,
  background: pad(2mm, scale(x: -100%, image("assets/mountains-flat.svg", height: 10%))),
  ..args,
  it,
  ) = {
  let (font-main, font-title, font-small-title) = cfg.fonts

  // Keep these two rules separate in case: the secone one might also set a
  // relative size to adjust the font scale
  show slide-title: set text(size: 1.2em)
  show slide-title: set text(..font-small-title.text)

  plain-slide(
    offset: 4,
    footer-func: footer-func,
    background: place(
      bottom+left,
      transparent-image(cfg, alpha: cfg.background-alpha, background),
    ),
    ..args,
    it)
}

#let basic-template(cfg, doc) = {
  set text(28pt)
  show: styling.basic-template.with(cfg)
  set outline(depth: 5)

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

#let outline-columns(columns, gutter, it) = {
  if columns != auto {
    return std.columns(columns, gutter: gutter, it)
  }
  block(
    height: 1fr,
    layout(available => {
      // Measure without giving available height (fractional lengths will be 0
      // which is what we want here)
      let (width, height) = measure(width: available.width, it)
      let n-columns = calc.ceil(height / available.height)
      std.columns(n-columns, gutter: gutter, it)
    }),
  )
}

#let outline-placer(
  spacing: 2em,
  insert: none,
  columns: auto,
  gutter: 6% + 0pt,
  items,
) = {
  let inserts = (none, ..(v(spacing, weak: true),) * (items.len() - 1), none)
  if insert != none {
    for (i, it) in insert {
      inserts.at(i) = it
    }
  }
  let items2 = items + (none, )
  let items3 = array.zip(inserts, items2).join()
  outline-columns(columns, gutter, items3.join())
}

// Format the outline item with number `i`, or `none` if unnumbered.
// The `it` argument can be a single piece of content (for single-level
// outlines) or a dict with `title` and `children` keys (for two-level
// outlines).
#let outline-item-template(
  cfg,
  align: top,
  number: auto,
  text: auto,
  gutter: 0.8em,
  i,
  it,
) = {
  number = (size: 1.6em, width: 1.2em) + util.coalesce(number, (:))
  text = (size: 0.9em, width: auto) + util.coalesce(text, (:))
  if type(it) == dictionary {
    // The item is a dict with title and children
    let (font-main, font-title, font-small-title) = cfg.fonts
    it = block({
      heading(
        level: 7,
        outlined: false,
        numbering: none,
        std.text(
          ..font-small-title.text,
          link(it.title.location(), it.title.body),
        ),
      )
      it.children.intersperse(linebreak()).join()
    })
  } else {
    it = link(it.location(), it.body)
  }
  numbered-title(
    cfg,
    align: align,
    number: number,
    text: text,
    gutter: gutter,
    i,
    it,
  )
}

// Return `it` if it is a function, and otherwise return `default-func`, with
// arguments in `it` preapplied if `it` is a dict.
#let _func-or-args(default-func, it) = {
  if it == auto {
    it = (:)
  }
  if type(it) == dictionary {
    return default-func.with(..it)
  }
  // Not a dict or auto => `it` is itself the function
  return it
}

// template and placer options can be a function, or a dict of arguments to
// pass to the default function
#let outline-template(
  cfg,
  item-template: auto,
  placer: auto,
  doc,
) = {
  item-template = _func-or-args(outline-item-template.with(cfg), item-template)
  placer = _func-or-args(outline-placer, placer)
  show outline: it => {
    let items = util.outline-items(it)
    let i = 0
    let formatted = ()
    for item in items {
      let main-item = if type(item) == dictionary { item.title } else { item }
      if main-item.numbering != none {
        i += 1
        formatted.push(item-template(i, item))
      } else {
        formatted.push(item-template(none, item))
      }
    }
    placer(formatted)
  }
  doc
}

#let properties = (
  name: "fancy",
  font-scheme: (
    "fira-sans-light",
    (text: (font: "Audiowide")),
    (text: (font: "Tilt Neon")),
  ),
  color-scheme: (
    shades: (rgb("#02081d"), rgb("#a1eefd")),
    accents: (rgb("#e653ba"), rgb("#90cb8f")),
  ),
  requirements: (
    n-fonts: 3,
    n-accents: 2,
    shade-samples: (0%, 90%),
  ),
)

#let fancy(cfg: none, background-alpha: 15%, outline: auto) = {
  // If no config was provided, return theme parameters
  if cfg == none { return properties }

  outline = util.coalesce(outline, (:))

  cfg.background-alpha = background-alpha

  return (
    title-slide: title-slide.with(cfg, cfg.plain-slide),
    section: section.with(cfg, cfg.plain-slide),
    slide: slide.with(cfg, cfg.plain-slide),
    basic-template: basic-template.with(cfg),
    outline-template: outline-template.with(cfg, ..outline),
    bibliography-template: styling.bibliography-template.with(cfg),
    transparent-image: transparent-image.with(cfg),
  )
}

