#import "util.typ"

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

  Missing keys or keys set to `auto` will be taken from the default scheme
  (this guarantees that `scheme.text` will exist, but not that it will contain
  particular keys such as `font`).
*/ 
// Non-normalized schemes: can have missing values (to be copied from default
// scheme), missing text weights (to be copied from typst defaults) and
// non-standard font names (to be lowercased).
#let _abnormal-schemes = (
  // The default scheme defines the valid keys
  default: (
    text: (:), // default font: Linux Libertine
    text-weights: (:),
    raw: (:), // default font: DejaVu Sans Mono
    math: (:), // defont font: New Computer Modern Math
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
    text-weights: (regular: "light", medium: 350, bold: "regular"),
    raw: (font: "Fira Mono", weight: "regular"),
    math: (font: "Fira Math", weight: "light"),
    delta: 100,
  ),
)


// Weight values of standard weights
#let _std-weights = (
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

// Weight names of weight values (inverted dict of _std-weights).
// The values (integers) are converted to string to act as dict keys.
#let _values-to-names = {
  let new = (:)
  for (k, v) in _std-weights {
    new.insert(str(v), k)
  }
  new
}

#let _weight-value(v) = if type(v) == str { _std-weights.at(v) } else { v }

// Interpolate the value at position `i` from its nearest non-`none` neighbors
#let _interpolate(values, i) = {
  let i-prev = range(i - 1, -1, step: -1).find(j => values.at(j) != none)
  let i-next = range(i + 1, values.len()).find(j => values.at(j) != none)
  let prev = values.at(i-prev)
  let next = values.at(i-next)
  prev + (i - i-prev)/(i-next - i-prev) * (next - prev)
}

// Return full dict of weights in standard order, interpolating
// missing values. The standard weights are used for the extreme (thin and
// black) and regular weights if unspecified. Numeric weights are converted to
// weight names where possible.
#let _weights-full(weights) = {
  // Use default for regular and extreme weights if unspecified
  for w in ("thin", "regular", "black") {
    if not w in weights {
      weights.insert(w, w)
    }
  }

  let keys = _std-weights.keys()

  // Make array of values in order of increasing weight
  // (using `none` where values are missing)
  let values = keys.map(k => weights.at(k, default: none)).map(_weight-value)

  // Make full dict, interpolating missing values
  let new = (:)
  for (i, (k, v)) in array.zip(keys, values).enumerate() {
    if v == none {
      v = int(_interpolate(values, i))
    }
    // Convert values to names where possible
    new.insert(k, _values-to-names.at(str(v), default: v))
  }
  new
}

// Return true if the weights are all equal to the default, false
// otherwise.
#let is-default-weights(weights) = {
  for (k, v) in weights {
    if k != v { return false }
  }
  return true
}

// Return a scheme in normalized form:
// - font names are lowercased (necessary for matching in `text.where(...)`)
// - missing text weights are filled in (for normal, thin and black) or
//   interpolated
// - weight values are converted to names where possible
// - missing fields are copied from the default scheme
// - an error is thrown if the scheme contains unknown fields
#let _normalize(scheme) = {
  // Check that all fields are valid
  for (k, _) in scheme {
    if k not in _abnormal-schemes.default {
      panic("Invalid font scheme key: " + k)
    }
  }
  // Fill in default values for missing fields
  scheme = _abnormal-schemes.default + scheme
  // Ensure all weights are set, interpolating missing values and using weight
  // names where possible
  scheme.text-weights = _weights-full(scheme.text-weights)
  // Convert font names to lowercase
  if "font" in scheme.text { scheme.text.font = lower(scheme.text.font) }
  if "font" in scheme.math { scheme.math.font = lower(scheme.math.font) }
  if "font" in scheme.raw  { scheme.raw.font  = lower(scheme.raw.font)  }
  return scheme
}

// Normalize standard schemes
#let schemes = util.map-dict(_abnormal-schemes, (k, v) => _normalize(v))

// Make scheme (dict with fields `text`, `text-weights`, `raw`, `math` and
// `delta`) from given base scheme, overriding fields with the given
// values when they are not `auto`.
// The base scheme can be given by value (dict) or by name, or as `auto` to
// refer to the default scheme.
// When given by value, a partial scheme can be given: missing fields or fields
// with value `auto` will be taken from the default scheme.
// If `reverse` is `true`, the order of shades is reversed.
#let font-scheme(
  base: auto,
  text: auto,
  text-weights: auto,
  raw: auto,
  math: auto,
  delta: auto,
) = {
  // This function takes fields as parameters instead of a dict, to present
  // a nicer API to the user when used directly.
  if base == auto {
    base = schemes.default
  }
  if type(base) == str {
    // Resolve scheme name
    if base not in schemes { panic("No font scheme named " + repr(base)) }
    base = schemes.at(base)
  }
  if type(base) != dictionary {
    panic("Base font scheme must be a name or dictionary")
  }

  // Make sure base has all fields and they're all valid
  base = _normalize(base)

  // TODO: automatize merging of all fields
  let scheme = (
    text: util.coalesce(text, base.text, schemes.default.text),
    text-weights: util.coalesce(text-weights, base.text-weights, schemes.default.text-weights),
    raw: util.coalesce(raw, base.raw, schemes.default.raw),
    math: util.coalesce(math, base.math, schemes.default.math),
    delta: util.coalesce(delta, base.delta, schemes.default.delta),
  )

  // Normalize result (for font names and text weights)
  return _normalize(scheme)
}
