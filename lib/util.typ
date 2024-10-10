// Return `n` evenly-spaced values between `a` and `b`
#let linspace(a, b, n) = {
  if n == 0 { return () }
  if n == 1 { return ((a + b) / 2,) }
  range(n).map(i => a + (b - a)/(n - 1) * i)
}

// Convert length to absolute length for given text size
 #let simple-length-to-abs(len, text-size) = len.abs + text-size * len.em

// Convert ratios simple or relative length or ratios to absolute for given text
// and layout size
#let length-to-abs(len, layout-size, text-size) = {
  if type(len) == relative {
    simple-length-to-abs(len.length, text-size) + layout-size * len.ratio
  } else if type(len) == ratio {
    layout-size * len
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

// Return dict of values for all four sides by applying rules of precedence.
#let sides-dict(
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  x: auto,
  y: auto,
  rest: auto,
  default,
) = (
   left:   coalesce(left,   x, rest, default),
   right:  coalesce(right,  x, rest, default),
   top:    coalesce(top,    y, rest, default),
   bottom: coalesce(bottom, y, rest, default),
)

// Return a dict with the width and height of the current page, taking
// `page.flipped` into account.
#let page-size() = {
  if page.flipped {
    (width: page.height, height: page.width)
  } else {
    (width: page.width, height: page.height)
  }
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
// The `text-size` parameter is used to convert em lengths. If unspecified,
// the context's text size is used, but that might give wrong results.
#let margins(text-size: auto) = {
  let p-size = page-size() 
  let margins = standard-margin-fields(page.margin)

  // Replace auto with default length
  let auto-length = auto-margin(p-size.width, p-size.height)
  margins = map-dict(margins, (k, v) => coalesce(v, auto-length))

  // Convert all lengths to absolute values  
  text-size = coalesce(text-size, text.size)
  margins.left   = length-to-abs(margins.left,   p-size.width,  text-size)
  margins.right  = length-to-abs(margins.right,  p-size.width,  text-size)
  margins.top    = length-to-abs(margins.top,    p-size.height, text-size)
  margins.bottom = length-to-abs(margins.bottom, p-size.height, text-size)

  return margins
}

#let bars(page: auto) = {
  if page == auto {
    page = here().page()
  }
  let (t, b, l, r) = (
    <__minideck-bar-top>,
    <__minideck-bar-bottom>,
    <__minideck-bar-left>,
    <__minideck-bar-right>,
  ).map(lbl => query(lbl).filter(x => x.location().page() == page))
  return (
    top:    t.map(x => x.value.height),
    bottom: b.map(x => x.value.height),
    left:   l.map(x => x.value.width),
    right:  r.map(x => x.value.width),
  )
}

// Current progress in the presentation as an array of 1-based slide numbers
// `(current-slide, end-slide)`, counting all subslides as a
// single slide and ignoring slides after the one marked with `<end-slide>`.
// Must be called with appropriate context available.
#let progress() = {
  let i = counter(page).get().first()
  let end-slide = query(<end-slide>)
  let n = if end-slide.len() > 0 {
    // If an end-slide label was found, count slides only till that one
    counter(page).at(end-slide.first().location()).first()
  } else {
    // Count till last slide
    counter(page).final().first()
  }
  return (i, n)
}
