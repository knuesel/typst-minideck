#import "util.typ"

// Let `it` protrude on the given sides by an amount equal to the
// corresponding page margins.
// The `sides` argument can be an array of values or a single value among
// `left`, `right`, `top`, `bottom`.
// The protrusion amount can be miscalculated in cases where the margin is
// specified with `em` units and the text size was changed since page creation
// (see https://github.com/typst/typst/issues/3636). As a workaround, you can
// pass the correct text size with the `text-size` parameter.
//
// Examples:
//
// Make a red box accross the whole page width:
//
//   `#protrude((left, right), box(width: 100%, height: 1cm, fill: red))`
// 
// Place an image in the bottom left corner of the page:
//
//   `#place(bottom+left, protrude((bottom, left), image(...)))`
//
#let protrude(sides, text-size: auto, it) = context {
  let sides = if type(sides) == array { sides } else { (sides,) }
  let margins = util.context-margins(text-size: text-size)
  let pads = (:)
  if left   in sides { pads.left   = -margins.left }
  if right  in sides { pads.right  = -margins.right }
  if top    in sides { pads.top    = -margins.top }
  if bottom in sides { pads.bottom = -margins.bottom }
  pad(..pads, it)
}

#let anchor-x-shift(anchor, size) = {
  if anchor.x == right {
    -size.width
  } else if anchor.x == center {
    -size.width / 2
  } else { // left, start, end or nothing
    0pt
  }
}

#let anchor-y-shift(anchor, size) = {
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
    let x-shift = other.x - this.x + anchor-x-shift(anchor, size) + dx
    let y-shift = other.y - this.y + anchor-y-shift(anchor, size) + dy
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
  let b = context block(width: page.width, ..style, it)
  place(y-align+center, dy: dy, float: not overlay, clearance: 0pt, b)
}

// Return a header layout with the given content.
// The default value is used content if `it` is `auto`.
#let header(it, default: none) = {
  set align(top)
  protrude((left, right), util.coalesce(it, default))
}

// Return a footer layout with the given content.
// The default value is used as footer text if `it` is `auto`.
#let footer(it, padding: 1.5em, default: none) = {
  set align(bottom)
  protrude((left, right), pad(x: padding, bottom: padding, {
    place(bottom+end, context counter(page).display()) // XXX remove context?
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
