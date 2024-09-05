#import "util.typ"

// Protrusion for given relative length and margin size.
// The `em` length given by the user must be taken relative to the current
// `text.size` rather than the page text size.
#let _protrusion(rel, size) = util.length-to-abs(rel, size, text.size)

// Let `it` protrude on the given sides by lengths relative to the page margins.
// Relative lengths or ratios can be given for `left`, `right`, `top`, `bottom`,
// `x` and `y`. These last two are only used when the corresponding sides are
// set to `auto`.
// The ratio component of each length is taken relative to the corresponding
// margin, so with a left margin of `2cm` and a right margin of `3cm` the
// argument `x: 100%` is equivalent to `left: 2cm, right: 3cm`.
// The protrusion amount can be miscalculated in cases where the margin is
// specified with `em` units and the text size was changed since page creation
// (see https://github.com/typst/typst/issues/3636). As a workaround, you can
// pass the correct text size with the `page-text-size` parameter.
//
// Examples:
//
// Make a red box accross the whole page width:
//
//   `#protrude(x: 100%, box(width: 100%, height: 1cm, fill: red))`
// 
// Place an image flush with the page bottom bottom and halfway in the right
// margin:
//
//   `#place(bottom+right, protrude(bottom: 100%, right: 50%, image(...)))`
//
#let protrude(left: auto, right: auto, top: auto, bottom: auto,
              x: 0pt, y: 0pt, page-text-size: auto, it) = context {
  let margins = util.context-margins(text-size: page-text-size)
  pad(
    left:   - _protrusion(util.coalesce(left, x),   margins.left),
    right:  - _protrusion(util.coalesce(right, x),  margins.right),
    top:    - _protrusion(util.coalesce(top, y),    margins.top),
    bottom: - _protrusion(util.coalesce(bottom, y), margins.bottom),
    it,
  )
}

#let _anchor-x-shift(anchor, size) = {
  if anchor.x == right {
    -size.width
  } else if anchor.x == center {
    -size.width / 2
  } else { // left, start, end or nothing
    0pt
  }
}

#let _anchor-y-shift(anchor, size) = {
  if anchor.y == bottom {
    -size.height
  } else if anchor.y == horizon {
    -size.height / 2
  } else { // top or nothing
     0pt
  }
}

#let place-relative(
  target,
  index: 0,
  anchor: top+left,
  dx: 0pt,
  dy: 0pt,
  default: place,
  it,
) = {
  // Workaround for typst 0.11, see https://github.com/typst/typst/issues/3614
  metadata(none)
  
  let targets = query(target)
  if (index >= targets.len() or index < -targets.len()) {
    default(it)
  } else {
    let this = here().position()
    let other = targets.at(index).location().position()
    let size = measure(it)
    let x-shift = other.x - this.x + _anchor-x-shift(anchor, size) + dx
    let y-shift = other.y - this.y + _anchor-y-shift(anchor, size) + dy
    place(dx: x-shift, dy: y-shift, it)
  }
}

// Place a bar across the whole slide width.
// When overlay is false, the bar uses floating placement to the top or bottom,
// displacing other content down or up respectively. When overlay is true the
// bar doesn't affect the layout of other objects.
// The `y-align` parameter must be `top` or `bottom`.
// Use for example `y-align: top` with `dy: -margin.top` to make a bar aligned
// with the page border.
// Options can be passed to the block wrapper using the `style` parameter.
#let slide-bar(dy: 0pt, overlay: false, style: (:), y-align, it) = {
  let b = block(width: util.page-size().width, ..style, it)
  place(y-align+center, dy: dy, float: not overlay, clearance: 0pt, b)
}

// Place a full-width block at the top of the slide, displacing the margin
// below itself. The `style` argument can be used to configure th block.
// Note: This won't work in a heading show rule when margins are given in ems,
// as the heading size is typically different from the initial page text size
#let top-bar(dy: 0pt, style: (:), it) = context slide-bar(
  dy: -util.context-margins().top + dy,
  style: style,
  top,
  it,
)

// Place a full-width block at the bottom of the slide, displacing the margin
// above itself. The `style` argument can be used to configure th block.
// Note: This won't work in a heading show rule when margins are given in ems,
// as the heading size is typically different from the initial page text size
#let bottom-bar(dy: 0pt, style: (:), it) = context slide-bar(
  dy: util.context-margins().bottom + dy,
  style: style,
  bottom,
  it,
)

// Return a header layout with the given content.
// The default value is used content if `it` is `auto`.
#let header(it, default: none) = {
  set align(top)
  protrude(x: 100%, util.coalesce(it, default))
}

// Return a footer layout with the given content.
// The default value is used as footer text if `it` is `auto`.
#let footer(it, padding: 1.5em, default: none) = {
  set align(bottom)
  protrude(x: 100%, pad(x: padding, bottom: padding, {
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
