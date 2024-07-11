// Convert length to absolute length for given text size
 #let simple-length-to-abs(len, text-size) = len.abs + text-size * len.em

// Convert simple or relative length to absolute for given text and layout size
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
  for (k, v) in d {
    new.insert(k, f(k, v))
  }
  new
}

// Return the first positional argument that is different from `on`,
// or return `on` if none is different.
#let coalesce(on: auto, ..args) = {
  for x in args.pos() {
    if x != on { return x }
  }
  return on
}

/*
  Return a dict with fields `left`, `right`, `top`, `bottom`.
  `margins` can take the same values as typst's page.margin, except for `inside`
  and `outside` which are ignored.
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
    left:   dict-at-any(margins, ("left",   "x", "rest"), default: auto),
    right:  dict-at-any(margins, ("right",  "x", "rest"), default: auto),
    top:    dict-at-any(margins, ("top",    "y", "rest"), default: auto),
    bottom: dict-at-any(margins, ("bottom", "y", "rest"), default: auto),
  )
}

// Return the `auto` margin size for the given page dimensions
#let auto-margin(page-width, page-height) = calc.min(page-width, page-height) * 2.5/21

// Return the margins from the current context as a dict of absolute lengths
// with fields `left`, `right`, `top`, `bottom`.
// The `text-size` parameter is used to convert em lenghts. If unspecified,
// the context's text size is used.
#let context-margins(text-size: auto) = {
  let margins = standard-margin-fields(page.margin)

  // Replace auto with default length
  let auto-length = auto-margin(page.width, page.height)
  map-dict(margins, (k, v) => coalesce(v, auto-length))

  // Convert all lengths to absolute values  
  text-size = coalesce(text-size, text.size)
  margins.left   = length-to-abs(margins.left,   page.width,  text-size)
  margins.right  = length-to-abs(margins.right,  page.width,  text-size)
  margins.top    = length-to-abs(margins.top,    page.height, text-size)
  margins.bototm = length-to-abs(margins.bottom, page.height, text-size)

  return margins
}

// Current progress in the presentation as an array
// `(current-slide, total-slides-before-appendix)`, counting all subslides as a
// single slide and ignoring slides after the <appendix> label.
// Must be called with appropriate context available.
#let progress() = {
  let i = counter(page).get().first()
  let appendix = query(<appendix>)
  let n = if appendix.len() > 0 {
    // If an appendix label was found, count slides only till the slide before.
    counter(page).at(appendix.first().location()).first() - 1
  } else {
    counter(page).final().first()
  }
  return (i, n)
}
