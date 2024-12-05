#import "util.typ"

/*
  A color scheme is a dictionary that can include the following fields:

  - shades: colors of similar hues and increasing or decreasing lightness. This is used for distinguishing elements based on lightness. Typically the first shade is used as background color and the last shade as foreground (text) color.

  - accents: colors of contrasting hues. Used for distinguishing elements based on hue.

  Missing keys or keys set to `auto` will be taken from the default scheme.

  The shades can be given as an array of at least two colors or as a gradient.
  Accent colors must be given as an array of at least one color.

  The theme can request any number of shades by specifying desired gradient positions. If shades were given as an array, minideck will generate a gradient using the given shades at evenly spaced stops.

  The theme can also request any number of accent colors. Minideck will drop the last color(s) if fewer are requested than available. If more are requested than available, minideck will generate additional colors. Currently, new colors are selected to maximize hue differences. This doesn't produce particularly good looking palettes but the colors should at least be distinguishable. In a future version a smarter algorithm might be used.

  The `color-scheme` function can be used to inherit from a scheme and to apply simple tranformations such as reversing the shades.
  */
#let schemes = (
  default: (
    shades: (white, black),
    accents: (red, green, blue, purple),
  ),
  phosphor: ( // Example of dark scheme, with single accent
    shades: (rgb("#fefefe"), rgb("#1b1b1b")),
    accents: (rgb("#00e0aa"),),
  ),
 )

// Get Oklch component `i` from given color
#let oklch-component(i, c) = oklch(c).components().at(i)
#let lightness = oklch-component.with(0)
#let chroma    = oklch-component.with(1)
#let hue       = oklch-component.with(2)

// Take color and return the same color with Oklch component `i` replaced with
// given value
#let with-oklch-component(i, c, value) = {
  let comps = oklch(c).components()
  comps.at(i) = value
  return oklch(..comps)
}
#let with-lightness(c, value) = {
  value = calc.clamp(float(value), 0, 1) * 100%
  with-oklch-component(0, c, value)
}
#let with-chroma    = with-oklch-component.with(1)
#let with-hue       = with-oklch-component.with(2)

// Return array of hue differences between accent colors sorted by hue, together
// with the `accents` indices of the two diffed colors. The returned value is
// an array of elements of the form `((i1, i2), hue-diff)`.
// Colors must be given in Oklch space.
#let _sorted-hue-diffs(accents) = {
  // List of hues
  let hues = accents.map(hue)
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
#let _n-to-pick(n-missing, sorted-diffs) = {
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

// Pick n colors between Oklch colors `c1` and `c2` with evenly spaced hue,
// always taking the path of increasing hue angles.
#let _pick-n-between(n, c1, c2) = {
  let g = gradient.linear(c1, c2, space: oklch)
  let pos-with-ends = util.linspace(0%, 100%, n + 2)
  let new-colors = g.samples(..pos-with-ends.slice(1, -1))

  let hue1 = hue(c1)
  let hue2 = hue(c2)
  let hue-gap = if hue2 > hue1 { hue2 - hue1 } else { hue2 + 360deg - hue1 }
  let hue-step = hue-gap / (n + 1)

  // Calculate hue by hand to make sure it's taken on correct side of circle
  return new-colors.enumerate(start: 1)
    .map(((i, c)) => with-hue(c, hue1 + i * hue-step))
}

// Expand array of colors if required to have it contain at least `n`
// elements while maximizing the hue difference between colors.
// Colors must be given in Oklch space.
#let _expand-accents(accents, n) = {
  if accents.len() >= n {
    return accents
  }

  // Get sorted array of ((i1, i2), hue-diff) elements
  let sorted-diffs = _sorted-hue-diffs(accents)

  // Number of colors to pick in largest hue gap
  let n-new = _n-to-pick(n - accents.len(), sorted-diffs)

  // Indices of colors on each side of the gap
  let (i1, i2) = sorted-diffs.last().first()

  let new-colors = _pick-n-between(n-new, accents.at(i1), accents.at(i2))

  // Recurse
  return _expand-accents(accents + new-colors, n)
}

// Return the requested number of accent colors.
// The returned colors are in RGB space.
#let _n-accents(accents, n) = {
  if accents.len() >= n {
    return accents.slice(0, count: n).map(rgb)
  }
  // We need to generate more colors
  return _expand-accents(accents.map(oklch), n).map(rgb)
}

// Check that sample positions are all of the same type and in increasing order,
// panicking otherwise.
// (This is necessary to avoid surprises when the number of given shades matches
// the number of requested positions: in this case the given shades are returned
// directly without sampling (giving an easy way for the user to set precise
// colors, and users can easily make a gradient when that behavior is not
// desired).
#let _check-sample-positions(ts) = {
  if type(ts) != array {
    panic("Shade sample positions must be given as an array")
  }
  let types = ts.map(type)
  if not (types.all(x => x == ratio) or types.all(x => x == angle)) {
    panic("Shade sample positions must be all ratios or all angles")
  }
  if ts.len() < 2 {
    return
  }
  for (x, y) in array.zip(ts.slice(0, -1), ts.slice(1)) {
    if y < x {
      panic("Shade postions must be increasing")
    }
  }
}

// Get shades specified either as a number or as gradient positions.
#let _sample-shades(shades, ts) = {
  _check-sample-positions(ts)

  if type(shades) != gradient { 
    // Oklab is best for maintaining hue
    shades = gradient.linear(..shades, space: oklab)
  }
  return shades.samples(..ts)
}

// Reverse the order of shade colors (if given as array) or mirror the gradient.
#let _reverse-shades(shades) = {
  if type(shades) == gradient {
    gradient.linear(shades.stops().rev().map(((c, s)) => (c, 100% - s)))
  } else {
    shades.rev()
  }
}

// Make scheme (dict with fields `shades` and `accents`) from given base scheme,
// overriding shades and accents with the given values when they are not `auto`.
// The base scheme can be given by value (dict with `shades` and `accents`) or
// by name, or as `auto` to refer to the default scheme.
// When given by value, a partial scheme can be given: missing fields or fields
// with value `auto` will be taken from the default scheme.
// If `reverse` is `true`, the order of shades is reversed.
// The accents can be reordered by passing an array of indices to `arrange`:
// the accent array will be indexed at these indices to produce a new array.
#let color-scheme(
  base: auto,
  shades: auto,
  accents: auto,
  arrange: none,
  reverse: false,
) = {
  // This function takes fields as parameters instead of a dict, to present
  // a nicer API to the user when used directly.
  if base == auto {
    base = schemes.default
  }
  if type(base) == str {
    // Resolve scheme name
    if base not in schemes { panic("No color scheme named " + repr(base)) }
    base = schemes.at(base)
  }
  if type(base) != dictionary {
    panic("Base color scheme must be a name or dictionary")
  }

  // Check that all fields in base are valid
  for (k, _) in base {
    if k not in schemes.default {
      panic("Invalid color scheme key: " + k)
    }
  }

  // Make sure all standard fields exist in base, taking missings from default
  base = schemes.default + base

  // TODO: automatize merging of all fields
  shades = util.coalesce(shades, base.shades, schemes.default.shades)
  accents = util.coalesce(accents, base.accents, schemes.default.shades)

  if arrange != none {
    if type(arrange) != array {
      panic("arrange must be an array of indices, or none")
    }
    accents = arrange.map(i => accents.at(i))
  }
  if reverse {
    shades = _reverse-shades(shades)
  }
  return (shades: shades, accents: accents)
}

// Get some colors from a color scheme
#let get-colors(scheme, shade-samples, n-accents) = (
  shades: _sample-shades(scheme.shades, shade-samples).map(rgb),
  accents: _n-accents(scheme.accents, n-accents).map(rgb),
)
