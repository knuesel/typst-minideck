// The Metropolis theme has two subthemes used in the same set of slides or even
// the same slide: normal (e.g. for content of normal slides) and inverted (e.g.
// for title of normal slides and for content of standout slides).
// When using the default values, the inverted subtheme of the light
// variant has the same colors as the normal subtheme of the dark variant,
// but this is coincidental. The variant is a global switch for the whole slide
// deck, while several subthemes can be used in a single deck.

#import "../util.typ"

#let dark-brown  = rgb("#604c38")
#let dark-teal   = rgb("#23373b")
#let light-brown = rgb("#EB811B")
#let light-green = rgb("#14B03D")

// Default base colors for the light variant.
#let base-light = (
  fg: dark-teal,
  bg: luma(98%),
  alert: light-brown,
  example: light-green,
)

// Base colors for all theme variants.
// A variant is a named color theme. A theme can have many variants but most
// common is to have "light" and "dark".
#let base-variants = (
  light: base-light,
  dark: util.switch-bg-fg(base-light),
)

// Compute palette for main subtheme, given the corresponding base colors.
#let compute-subtheme(subtheme-base) = {
  let (fg, bg, alert, example) = subtheme-base
  let block-title-bg = color.mix((bg, 80%), (fg, 20%))
  return (
    fg: fg,
    bg: bg,
    alert: alert,
    example: example,
    progress-bar: (
      fg: alert,
      bg: color.mix((color.mix(alert, black), 30%), (white, 70%)),
    ),
    block-title: (
      fg: fg,
      bg: block-title-bg,
    ),
    block-body: (
      fg: fg,
      bg: color.mix(block-title-bg, bg),
    ),
    block-title-alerted: (
      fg: alert,
      bg: block-title-bg,
    ),
    block-title-example: (
      fg: example,
      bg: block-title-bg,
    ),
  )
}

// Compute full palette (including all subthemes) for the given base colors.
#let compute-palette(base) = (
  normal: compute-subtheme(base),
  inverted: compute-subtheme(util.switch-bg-fg(base)),
)

// Return full palette (including all subthemes) for the given variant,
// overriding the base colors with the given user base colors and overriding
// the resulting palette with the given user palette.
#let palette(variant, user-base, user-palette) = {
  let final-base = util.merge-dicts(base-variants.at(variant), user-base)
  let palette-from-base = compute-palette(final-base)
  return util.merge-dicts(palette-from-base, user-palette)
}
