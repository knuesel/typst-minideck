#import "util.typ"

#let std-weights = (
  thin: 100,
  extralight: 200,
  light: 300,
  regular: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
  extrabold: 800,
  black: 900,
)

#let default-text-weights = {
  let new = (:)
  for key in std-weights.keys() { new.insert(key, key) }
  new
}

/*
  A font scheme is a dictionary that can include the following fields:

  - `text`: dict of text options (normally just the font)
  - `text-weights`: dictionary of weight overrides, e.g.
    `(regular: "light", bold: "regular")` to use light weight for normal text
    and regular for bold text.
  - `raw`: dict of raw text options (normally just font and maybe weight)
  - `math`: dict of math text options (normally just font and maybe weight)
  - `delta`: delta value to use for `strong`

  Missing values in `text-weights` for thin, regular and black will be set to
  the standard values and other missing values will be interpolated.

  Missing keys (except for `text-weights`) will be taken from the default
  scheme.
*/ 
#let schemes = (
  // The `default` scheme defines the valid keys
  default: (
    text: (font: "Linux Libertine"),
    text-weights: default-text-weights,
    raw: (font: "DejaVu Sans Mono"),
    math: (font: "New Computer Modern Math"),
    delta: 300,
  ),
  libertinus-sans: (
    text: (font: "Libertinus Sans"),
  ),
  fira-sans: (
    text: (font: "Fira Sans"),
    raw: (font: "Fira Mono", weight: "medium"),
    math: (font: "Fira Math"),
    text-weights: (bold: "medium"),
  ),
  fira-sans-light: (
    text: (font: "Fira Sans"),
    text-weights: (regular: "light", medium: "regular", bold: "regular"),
    raw: (font: "Fira Mono", weight: "regular"),
    math: (font: "Fira Math", weight: "light"),
    delta: 100,
  ),
)

#let weight-value(v) = if type(v) == str { std-weights.at(v) } else { v }

// Interpolate the value at position `i` from its nearest non-`none` neighbors
#let interpolate(values, i) = {
  let i-prev = range(i - 1, -1, step: -1).find(j => values.at(j) != none)
  let i-next = range(i + 1, values.len()).find(j => values.at(j) != none)
  let prev = values.at(i-prev)
  let next = values.at(i-next)
  prev + (i - i-prev)/(i-next - i-prev) * (next - prev)
}

// Return full dict of weights in standard order, interpolating missing values.
// The standard weights are used for the extreme (thin and black) and regular
// weights if unspecified.
#let weights-full(weights) = {
  // Use default for regular and extreme weights if unspecified
  for w in ("thin", "regular", "black") {
    if not w in weights {
      weights.insert(w, w)
    }
  }

  let keys = std-weights.keys()

  // Make array of values in order of increasing weight
  // (using `none` where values are missing)
  let values = keys.map(k => weights.at(k, default: none)).map(weight-value)

  // Make full dict, interpolating missing values
  let new = (:)
  for (i, (k, v)) in array.zip(keys, values).enumerate() {
    if v == none {
      new.insert(k, int(interpolate(values, i)))
    } else {
      // Use `weights` rather than `values` to preserve values given as string
      new.insert(k, weights.at(k))
    }
  }
  new
}

#let normalize(scheme) = {
  // Resolve scheme value if given as name
  if type(scheme) == str {
    scheme = schemes.at(scheme)
  }
  // Check that all fields are valid
  for (k, _) in scheme {
    if k not in schemes.default {
      panic("Invalid font scheme key: " + k)
    }
  }
  // Ensure all weights are set, interpolating missing values
  scheme.text-weights = weights-full(scheme.at("text-weights", default: (:)))
  // Fill in default values for missing fields
  scheme = schemes.default + scheme

  return scheme
}

#let get-fonts(schemes, n: 1, default: schemes.default) = {
  // Replace auto with default
  schemes = util.coalesce(schemes, default)
  // If single scheme, wrap in array
  let schemes-array = if type(schemes) == array { schemes } else { (schemes,) }
  // Normalize each scheme
  let normal = schemes-array.map(normalize)
  // Fill in with first scheme if more are requested than given
  for _ in range(normal.len(), n) {
    normal.push(normal.first())
  }
  return normal.slice(0, count: n)
}
