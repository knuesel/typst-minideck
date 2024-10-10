#import "util.typ"

// Return dict of values for all four sides by applying rules of precedence.
#let _sides-dict(
  all: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  x: auto,
  y: auto,
  rest: auto,
  default,
) = (
   left:   util.coalesce(all, left,   x, rest, default),
   right:  util.coalesce(all, right,  x, rest, default),
   top:    util.coalesce(all, top,    y, rest, default),
   bottom: util.coalesce(all, bottom, y, rest, default),
)

// Protrusion for given relative length and reference margin/bar size.
// The `em` length given by the user must be taken relative to the current
// `text.size` rather than the page text size.
#let _protrusion(rel, reference) = {
  return util.length-to-abs(rel, reference, text.size)
}

#let _protrusions(rels, refs, default) = {
  if type(rels) != dictionary {
    rels = (all: rels)
  }
  let dict = _sides-dict(..rels, default)
  return (
    left:   _protrusion(dict.left,   refs.left),
    right:  _protrusion(dict.right,  refs.right),
    top:    _protrusion(dict.top,    refs.top),
    bottom: _protrusion(dict.bottom, refs.bottom),
  )
}

  
// Let `it` protrude in the margin on the specified sides by lengths relative to
// the page margins. Relative lengths or ratios can be given for `left`,
// `right`, `top` and `bottom` (highest precedence), `x` and `y` (lower
// precendence), and `rest` (lowest precedence). Setting a value to `auto` is
// equivalent to leaving it unspecified.
//
// The ratio component of each length is taken relative to the corresponding
// margin, so with a left margin of `2cm` and a right margin of `3cm` the
// argument `x: 100%` is equivalent to `left: 2cm, right: 3cm`.
// The protrusion amount can be miscalculated in cases where the margin is
// specified with `em` units and the text size was changed since page creation
// (see https://github.com/typst/typst/issues/3636 ).
//
// Examples:
//
// Make a red box accross the whole page width:
//
//   `#use-magin(x: 100%, box(width: 100%, height: 1cm, fill: red))`
// 
// Place an image flush with the page bottom and halfway in the right
// margin:
//
//   `#place(bottom+right, use-margin(bottom: 100%, right: 50%, image(...)))`
//
#let use-margin(..args, it) = context {
  for (k, _) in args.named() {
    if k not in ("left", "right", "top", "bottom", "x", "y", "rest") {
      panic("invalid use-margin argument: " + k)
    }
  }
  if args.pos().len() > 1 {
    panic("use-margin accepts at most 1 positional argument")
  }
  let default = if args.pos().len() == 1 {
    args.pos().first()
  } else {
    0pt
  }

  let margins = util.margins()

  // Get normalized sides
  let margin-prot = _protrusions(args.named(), margins, default)
  let padding = util.map-dict(margin-prot, (_, v) => -v)

  return pad(..padding, it)
}

// Calculate x shift corresponding to the given anchor alignment
#let _anchor-x-shift(anchor, size) = {
  if anchor.x == right {
    -size.width
  } else if anchor.x == center {
    -size.width / 2
  } else { // left, start, end or nothing
    0pt
  }
}

// Calculate y shift corresponding to the given anchor alignment
#let _anchor-y-shift(anchor, size) = {
  if anchor.y == bottom {
    -size.height
  } else if anchor.y == horizon {
    -size.height / 2
  } else { // top or nothing
     0pt
  }
}

// XXX finish
#let _target-position(target) = {
  let targets = query(target)
  if (index >= targets.len() or index < -targets.len()) {
    default(it)
  } else {
    let this = here().position()
    let other = targets.at(index).location().position()
  }
}

// Place `it` relative to the `index`-th match of the `target` selector.
// If the target is not found (or the index invalid), `it` is passed to the
// `default` function for placement.
// The `anchor` determines which point of `it` is aligned with the target
// position.
// The final position can be adjusted with `dx` and `dy`.
// The relative placement can be overriden for a particular axis using `x` or
// `y`: for example `x: 1cm` will disregard the `target` horizontal position,
// instead shifting by `1cm` from the parent's origin.
#let place-relative(
  target,
  index: 0,
  anchor: top+left,
  
  x: auto,
  y: auto,
  dx: 0pt,
  dy: 0pt,
  default: place,
  it,
) = context {
  // Workaround for typst 0.11, see https://github.com/typst/typst/issues/3614
  metadata(none)
  
  let targets = query(target)
  if (index >= targets.len() or index < -targets.len()) {
    default(it)
  } else {
    let this = here().position()
    let other = targets.at(index).location().position()
    let size = measure(it)
    let x-shift = dx + _anchor-x-shift(anchor, size)
    let y-shift = dy + _anchor-y-shift(anchor, size)
    x-shift += if x == auto { other.x - this.x  + dx } else { x }
    y-shift += if y == auto { other.y - this.y  + dy } else { y}
    place(dx: x-shift, dy: y-shift, it)
  }
}

// Place a bar across the whole slide width at the top or bottom of the slide,
// displacing other content down or up respectively.
// The `y-align` parameter must be `top` or `bottom`.
// If label is not `none`, metadata with the given label will be added after
// the block. The metadata will include a `height` field with the bar height.
// Additional parameters are passed to the block wrapper.
#let _slide-bar(dy: 0pt, label: none, y-align, ..args) = {
  let b = block(width: util.page-size().width, ..args)
  if label != none {
    b += [#metadata((height: measure(b).height))#label]
  }
  let dx = -util.margins().left
  place(y-align+left, dx: dx, dy: dy, float: true, clearance: 0pt, b)
}

// Place a full-width block at the top of the slide, displacing the margin
// below itself.
// Note: This won't work in a heading show rule when margins are given in ems,
// as the heading size is typically different from the initial page text size
// Top bars should not be used together with a page header.
// Additional parameters are passed to the block wrapper.
#let top-bar(dy: 0pt, ..args) = context _slide-bar(
  dy: -util.margins().top + dy,
  label: <__minideck-bar-top>,
  top,
  ..args,
)

// Place a full-width block at the bottom of the slide, displacing the margin
// above itself.
// Note: This won't work in a heading show rule when margins are given in ems,
// as the heading size is typically different from the initial page text size
// Top bars should not be used together with a page footer.
#let bottom-bar(dy: 0pt, ..args) = context _slide-bar(
  dy: util.margins().bottom + dy,
  label: <__minideck-bar-bottom>,
  bottom,
  ..args,
)

// Return a simple header layout with the given content.
// The default value is used as content if `it` is `auto`.
#let basic-header(it, default: none) = {
  set align(top)
  use-margin(x: 100%, util.coalesce(it, default))
}

// Return a simple footer layout with the given content.
// The default value is used as footer text if `it` is `auto`.
#let basic-footer(it, padding: 1.5em, default: none) = {
  set align(bottom)
  use-margin(x: 100%, pad(x: padding, bottom: padding, {
    place(bottom+end, context counter(page).display())
    util.coalesce(it, default)
  }))
}

#let title-block(width: auto, title: (:), body: (:), title-it, body-it) = {
  set heading(offset: 6)
  let b1 = block.with(
    below: 0pt,
    inset: 0.6em,
    ..title,
    heading(depth: 1, title-it),
  )
  let b2 = block.with(
    above: 0pt,
    inset: 0.6em,
    ..body,
    body-it,
  )
  block({
    if width == auto {
      // Calculate width as the largest between the two blocks but at most 100%.
      // This computation can be expensive. Note that even without fill,
      // having the same width for the title as the content can matter e.g.
      // when centering the title. 
      layout(size => {
        let w1 = measure(b1()).width
        let w2 = measure(b2()).width
        let w = calc.min(size.width, calc.max(w1, w2))
        b1(width: w)
        b2(width: w)
      })
    } else {
      b1(width: width)
      b2(width: width)
    }
  })
}
