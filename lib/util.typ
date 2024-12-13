// Return the index and value of the (first) minimum element in v
#let find-min(v) = v.enumerate().fold((0, v.first()), (a, b) => {
  let (ia, xa) = a
  let (ib, xb) = b
  if xb < xa { b } else { a }
}) 

// Return `n` evenly-spaced values between `a` and `b`
#let linspace(a, b, n) = {
  if n == 0 { return () }
  if n == 1 { return ((a + b) / 2,) }
  range(n).map(i => a + (b - a)/(n - 1) * i)
}

// Convert length to absolute length for given text size.
// If text-size is auto, len.to-asbolute() is used (requires context)
#let simple-length-to-abs(len, text-size) = {
  if text-size == auto {
    len.to-absolute()
  } else {
    len.abs + text-size * len.em
  }
}

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

// Return copy of `d` keeping only pairs `k: v` for which `f(k, v)` is `true`
#let filter-dict(d, f) = {
  let new = (:)
  for (k, v) in d.pairs().filter(pair => f(..pair)) {
    new.insert(k, v)
  }
  new
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


// Return target elements for given outline (for headings only)
#let outline-elements(it) = query(it.target).filter(
  x => x.func() == heading and (it.depth == none or x.level <= it.depth)
)

// Return outline headings as groups `(title: ..., children: (...,))`,
// with one group for each `level1` heading. In each group, the `title`
// field contains the `level1` heading, and the `children` field contains all
// `level2` headings between this `level1` heading and the next one.
#let outline-groups(level1, level2, elements) = {
  let groups = ()
  let title = none
  let children = ()
  for e in elements {
    if e.level == level1 {
      if title != none or children.len() > 0 {
        groups.push((title: title, children: children))
      }
      title = e
      children = ()
    }
    if e.level == level2  {
      children.push(e)
    }
  }
  if title != none or children.len() > 0 {
    groups.push((title: title, children: children))
  }
  return groups
}

// Return outline items ready to be used for layout. If `levels` is 1, each
// item corresponds to a single title (section or slide).
// If `levels` is 2, each item is a dict with keys `title` (the section title)
// and `children` (the slide titles, as simple links to the slides rather than
// outline entries).
// If `levels` is auto it is determined automatically based on `it`.
// and `children` (the array of slide titles for that section).
// The parameters `level1` and `level2` control the heading levels for the title
// and children respectively. If `auto`, they are determined automatically.
#let outline-items(
  levels: auto,
  level1: auto,
  level2: auto,
  it,
) = {
  let elements = outline-elements(it)
  let unique-levels = elements.map(e => e.level).dedup().sorted()
  levels = coalesce(levels, calc.min(2, unique-levels.len()))
  if levels == 1 {
    return elements
  }
  level1 = coalesce(level1, unique-levels.at(0))
  level2 = coalesce(level2, unique-levels.at(1))
  let groups = outline-groups(level1, level2, elements)

  groups.map(group => {
    let children = group.children.map(child => {
      // Construct non-heading items to avoid recursion issues
      link(child.location(), child.body)
    })
    (
      title: group.title,
      children: children,
    )
  })
}
