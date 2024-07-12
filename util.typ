// Convert length to absolute length for given text size
#let simple-length-to-abs(len, text-size) = len.abs + text-size * len.em

// Convert simple or relative length to absolute for given text and paper size
#let length-to-abs(len, layout-size, text-size) = {
  if type(len) == relative {
    simple-length-to-abs(len.length, text-size) + layout-size * len.ratio
  } else {
    simple-length-to-abs(len, text-size)
  }
}

// Return value of first field from `fields` found in `d`, or `default` if none found
#let dict-at-any(d, fields, default: none) = {
  if fields.len() == 0 {
    default
  } else {
    d.at(fields.first(), default: dict-at-any(d, fields.slice(1), default: default))
  }
}

// Return dict with same fields as `d` and values mapped through `f(k,v)`
#let map-dict(d, f) = {
  let new = (:)
  for (k, v) in d.pairs() {
    new.insert(k, f(k, v))
  }
  new
}

// Merge two dictionaries recursively, resolving field clashes by merging when
// both values are dictionaries, and by keeping the second value otherwise.
#let merge-dicts(d1, d2) = {
  for (k, v2) in d2 {
    let v1 = d1.at(k, default: none)
    let merge-vals = type(v1) == dictionary and type(v2) == dictionary
    d1.insert(k, if merge-vals { merge-dicts(v1, v2) } else { v2 })
  }
  d1
}

// Merge several dictionaries recursively, processing them in order with
// `merge-dicts`.
#let merge-all-dicts(..dicts) = dicts.pos().fold((:), merge-dicts)


// Return the first positional argument after `on` that is different from `on`,
// and returns `on` if none is different.
#let coalesce(on: none, ..args) = {
  for x in args.pos() {
    if x != on { return x }
  }
  return on
}

/*
  Return a dict with fields `left`, `right`, `top`, `bottom`.
  `margins` can take the same values as typst's page.margin.
  Fields that can't be determined from `margins` are set to `auto`.
*/
#let standard-margin-fields(margins) = {
  if margins == auto or type(margins) in (length, relative) {
    return standard-margin-fields((rest: margins))
  }
  if type(margins) != dictionary {
    panic("Unsupported margins type " + repr(type(margins)) + " (value " + repr(margins) + ")")
  }
  (
    left:   dict-at-any(margins, ("left",   "x", "inside", "outside", "rest"), default: auto),
    right:  dict-at-any(margins, ("right",  "x", "inside", "outside", "rest"), default: auto),
    top:    dict-at-any(margins, ("top",    "y", "rest"), default: auto),
    bottom: dict-at-any(margins, ("bottom", "y", "rest"), default: auto),
  )
}

/*
  Return a dict of absolute lengths for `left`, `right`, `top`, `bottom`.
  `margins` and `default` can take the same values as typst's page.margin.
  The absolute lengths are calculated using the given page and text sizes.
*/
#let absolute-margins(margins, page-size, text-size, default: auto) = {
  let default-val = calc.min(page-size.width, page-size.height) * 2.5/21
  let user = standard-margin-fields(margins)
  let dflt = standard-margin-fields(default)
  let merged = map-dict(user, (k,v) => coalesce(on: auto, v, dflt.at(k), default-val))
  (
    left:   length-to-abs(merged.left,   page-size.width,  text-size),
    right:  length-to-abs(merged.right,  page-size.width,  text-size),
    top:    length-to-abs(merged.top,    page-size.height, text-size),
    bottom: length-to-abs(merged.bottom, page-size.height, text-size),
  )
}

// Take a color palette (a multi-level dictionary of colors) and recursively
// switch the bg and fg fields.
#let switch-bg-fg(d) = {
  let colors = (:)
  for (k, v) in d {
    if k == "bg" {
      colors.insert("fg", v)
    } else if k == "fg" {
      colors.insert("bg", v)
    } else if type(v) == dictionary {
      colors.insert(k, switch-bg-fg(v))
    } else {
      colors.insert(k, v)
    }
  }
  colors
}
