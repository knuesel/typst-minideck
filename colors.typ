#import "util.typ"

/*
  A color scheme has two components:

  - shades: colors of similar hues and increasing or decreasing lightness. This is used for distinguishing elements based on lightness. Typically the first shade is used as background color and the last shade as foreground (text) color.

  - accents: colors of contrasting hues. Used for distinguishing elements based on hue.
 
  The shades can be given as an array of at least two colors, or as a gradient. Accent colors must be given as an array of at least one color.

  The theme can request any number of shades by specifying a desired number or specific gradient positions. If shades were given as an array and the theme requests a different number of colors or any number of gradient samples, minideck will generate a gradient using the given shades at evenly spaced stops.

  The theme can also request any number of accent colors. Minideck will drop the last color(s) if fewer are requested than available. If more are requested than available, minideck will generate additional colors with the aim of maximizing the hue contrasts.
*/
#let schemes = (
  default: (
    shades: (white, black),
    accents: (red, green, blue, purple),
  ),
)

// Return array of hue differences between accent colors sorted by hue, together
// with the `accents` indices of the two diffed colors. The returned value is
// an array of elements of the form `((i1, i2), hue-diff)`.
// Colors must be given in Oklch space.
#let sorted-hue-diffs(accents) = {
  // List of hues
  let hues = accents.map(c => c.components().at(2))
  // List of (index, hue) sorted by hue
  let sorted-pairs = hues.enumerate().sorted(key: x => x.last())
  // Append first value again to also consider diff from last to first
  // (adding 360deg for correct diff computation later)
  let (first-i, first-hue) = sorted-pairs.first()
  sorted-pairs.push((first-i, first-hue + 360deg))

  // Get ((i1, i2), diff) between sorted-pairs elements k and k+1
  // with `i1` and `i2` the corresponding indices in `accents`
  let i-diff(k) = {
    let p1 = sorted-pairs.at(k)
    let p2 = sorted-pairs.at(k + 1)
    ((p1.first(), p2.first()), p2.last() - p1.last())
  }
  let i-diffs = range(sorted-pairs.len() - 1).map(i-diff)
  // Sort by increasing diff
  return i-diffs.sorted(key: x => x.last())
}

// Return number of colors to pick in the largest hue gap
#let n-to-pick(n-missing, sorted-diffs) = {
  if sorted-diffs.len() == 1 {
    return n-missing
  }

  let max-diff = sorted-diffs.at(-1).last()
  let next-diff = sorted-diffs.at(-2).last()

  if next-diff <= 0deg {
    return n-missing
  }

  // How many colors could we pick in the largest gap and get new gaps no
  // smaller than when picking one color in the next largest gap?
  // (subtract 1 from number of new gaps to get number of new colors)
  let n-max = calc.trunc(max-diff / (0.5 * next-diff)) - 1
  return calc.min(n-max, n-missing)
}

// Take Oklch color and return the same color wit hue replaced with given value
#let with-hue(c, hue) = {
  let comps = c.components()
  comps.at(2) = hue
  return oklch(..comps)
}

// Pick n colors between Oklch colors `c1` and `c2` with evenly spaced hue,
// always taking the path of increasing hue angles.
#let pick-n-between(n, c1, c2) = {
  let g = gradient.linear(c1, c2, space: oklch)
  let pos-with-ends = util.linspace(0%, 100%, n + 2)
  let new-colors = g.samples(..pos-with-ends.slice(1, -1))

  let hue1 = c1.components().at(2)
  let hue2 = c2.components().at(2)
  let hue-gap = if hue2 > hue1 { hue2 - hue1 } else { hue2 + 360deg - hue1 }
  let hue-step = hue-gap / (n + 1)

  // Calculate hue by hand to make sure it's taken on correct side of circle
  return new-colors.enumerate(start: 1)
    .map(((i, c)) => with-hue(c, hue1 + i * hue-step))
}

// Expand array of colors if required to have it contain at least `n`
// elements while maximizing the hue difference between colors.
// Colors must be given in Oklch space.
#let expand-accents(accents, n) = {
  if accents.len() >= n {
    return accents
  }

  // Get sorted array of ((i1, i2), hue-diff) elements
  let sorted-diffs = sorted-hue-diffs(accents)

  // Number of colors to pick in largest hue gap
  let n-new = n-to-pick(n - accents.len(), sorted-diffs)

  // Indices of colors on each side of the gap
  let (i1, i2) = sorted-diffs.last().first()

  let new-colors = pick-n-between(n-new, accents.at(i1), accents.at(i2))

  // Recurse
  return expand-accents(accents + new-colors, n)
}

// Return the requested number of accent colors.
// The returned colors are in RGB space.
#let n-accents(accents, n) = {
  if accents.len() >= n {
    return accents.slice(0, count: n).map(rgb)
  }
  // We need to generate more colors
  return expand-accents(accents.map(oklch), n).map(rgb)
}

// Get shades specified either as a number or as gradient positions.
// The returned colors are in RGB space.
#let sample-shades(shades, ts) = {
  if type(shades) == array and type(ts) == int and ts == shades.len() {
    return shades.map(rgb)
  }
  // For all other cases use gradient to sample requested number of colors
  if type(shades) != gradient { 
    // Oklab is best for maintaining hue
    shades = gradient.linear(..shades, space: oklab)
  }
  if type(ts) == int {
    ts = util.linspace(0%, 100%, ts)
  }
  return shades.samples(..ts).map(rgb)
}

// Get given field (`shades` or `accents`) from scheme, or return `default`
// if scheme is `auto` or contains no such field.
// The scheme can be given by name to refer to a standard scheme in the
// `schemes` dict.
#let scheme-field(scheme, field, default) = {
  if scheme == auto {
    return default
  }
  if type(scheme) == str {
    scheme = schemes.at(scheme)
  }
  if type(scheme) != dictionary {
    panic("Color scheme must be a string, dictionary or auto")
  }
  return scheme.at(field, default: default)
}

// Return the requested number of accent colors from the source
// `scheme.accents`, or from `default` if `scheme` has no such field.
// The source must be an array of at least one color. If more colors are given
// than requested with `n`, the remaining color(s) are dropped. If fewer colors
// are given than requested, additional colors are generated in a way that
// maximizes the hue contrast.
// The returned colors are in RGB space.
#let get-accents(scheme, n: 1, default: schemes.default.accents) = {
  let accents = scheme-field(scheme, "accents", default)
  return n-accents(accents, n)
}

// Reverse the order of shade colors (if given as array) or mirror the gradient.
#let reverse-shades(shades) = {
  if type(shades) == gradient {
    gradient.linear(shades.stops().rev().map(((c, s)) => (c, 100% - s)))
  } else {
    shades.rev()
  }
}

// Return some shades sampled from the source `scheme.shades`, or from `default`
// if `scheme` is `auto` or has no such field. The source can be either
// an array of two or more colors, or a gradient. The `ts` argument can be
// either the desired number of shades (two or more) or an
// array of gradient positions. If the source is an array of colors, it
// is first converted to a gradient with evenly spaced stops in cases where a
// different number of shades is requested or if shades are requested at
// specific gradient positions.
// The source is reversed before use if `reverse` is true.
// The returned colors are in RGB space.
#let get-shades(scheme, samples: 2, default: schemes.default.shades, reverse: false) = {
  let shades = scheme-field(scheme, "shades", default)
  if reverse {
    shades = reverse-shades(shades)
  }
  return sample-shades(shades, samples)
}
