#import "themes/themes.typ"
#import "lib/layouts.typ"
#import "lib/colors.typ"
#import "lib/fonts.typ" as fonts-module
#import "lib/logic.typ"

// `field` is "header" or "footer"
#let _process-head-foot(page-args, field, func, txt) = {
  if page-args.at(field, default: none) == auto {
    page-args.remove(field)
  }
  if field not in page-args and txt != none {
    page-args.insert(field, func(txt))
  }
  return page-args
}

// XXX rewrite
// page arguments can be used to override the current page settings for this slide
// The footer of a slide can be overriden using either `footer` or
// `footer-text`:
//
// - `footer` takes content or `none`, to be used directly as the page footer.
//   The value `auto` can be passed to disable this behavior and consider
//   `footer-text` instead (this is the same as leaving `footer` unspecified).
//   
// - `footer-text` takes simple content (typically a string) that, if not
//   `none`, will be passed to a theme function for transformation and layout,
//   and the result will be  used as page footer. The value `auto` can be used
//   to let the theme function use the default value for this type of slide.
//
// Use `footer: auto` and `footer-text: none` to leave the page footer as it is.
#let _plain-slide(
  ..args,
  header-func: layouts.header,
  footer-func: layouts.footer,
  header-text: auto,
  footer-text: auto,
  handout: auto,
  steps: auto,
  offset: none,
  outlined: true,
  it,
) = {
  if args.pos().len() > 0 {
    panic("too many positional arguments")
  }
  if offset == none {
    panic("offset must be set to an integer value: 0 for title slide, 2 for section slide, 4 for normal slide")
  }
  let page-args = args.named()
  page-args = _process-head-foot(page-args, "header", header-func, header-text)
  page-args = _process-head-foot(page-args, "footer", footer-func, footer-text)
  set page(..page-args) if page-args.len() > 0
  set heading(outlined: false, numbering: none) if not outlined
  set heading(offset: offset)

  logic.subslides(handout: handout, steps: steps, it)
}

#let _paper(format) = (
  "4:3": "presentation-4-3",
  "16:9": "presentation-16-9",
).at(format, default: format)

#let _format-arg(format) = {
  if type(format) == str {
    return (paper: _paper(format))
  }
  return format
}

#let _get-cfg(format, flipped, font-scheme, color-scheme, shades: (), accents: (), fonts: ()) = (
  page-args: _format-arg(format) + (flipped: flipped),
  fonts: fonts-module.get-fonts(font-scheme, ..fonts),
  shades: colors.get-shades(color-scheme, ..shades),
  accents: colors.get-accents(color-scheme, ..accents),
)

// Return a dictionary of functions that implement the given configuration
// settings. For example use `(slide, uncover) = config(handout: true)` to
// define `slide` and `uncover` functions that work in handout mode. 
// The dictionary also includes a field `cfg` that holds the configuration
// (pag and text sizes, font and color schemes) in normalized form:
// absolute lengths for all sizes, complete font weight list, and gradients
// for color shades and accents.
//
// Named parameters:
//
// - format: a string for one of the paper size names recognized by page.paper
//   or one of the shorthands "16:9" or "4:3". Default: "4:3".
// - landscape: use the paper size in landscape orientation. Default: `true`
// - width: page width as an absolute length, takes precedence over `format`
// - height: page height as an absolute length, takes precedence over `format`
// - handout: when `true`, dynamic features are disabled: all slide content is
//   shown in a single subslide. When set to `auto`, the value used is `true` if
//   `--input handout=true` is passed on the command line, `false` otherwise.
// - theme: the theme to use, either as a name (string) or as a theme function
//   (defaulting to `themes.simple`)
// - cetz: if the CeTZ module is passed here, the returned dictionary will
//   include `cetz-uncover` and `cetz-only`, which are versions of `uncover`
//   and `only` configured to use cetz methods for hiding and state update.
// - fletcher: if the fletcher module is passed here, the returned dictionary
//   will include `fletcher-uncover` and `fletcher-only`, which are versions
//   of `uncover` and `only` that use `fletcher.hide` for hiding and that
//   disable state update (so the number of slide steps must be given to `slide`
//   explicitly).
//
// Functions configured for CeTZ and fletcher return non-opaque content, so the
// caller is responsible for invoking `context` in a suitable scope, typically
// as in `#context cetz.canvas({...})`.
// XXX update docstring above
#let config(
  format: "4:3",
  flipped: false,
  font-scheme: auto,
  color-scheme: auto,
  theme: "simple",
  handout: auto,
  cetz: none,
  fletcher: none,
) = {
  let plain-slide = _plain-slide.with(handout: handout)
  let get-cfg = _get-cfg.with(format, flipped, font-scheme, color-scheme)

  // Resolve theme if given as name
  if type(theme) == str {
    theme = dictionary(themes).at(theme)
  }

  (
    // theme sets cfg, template, and slide functions
    ..theme(get-cfg, plain-slide),
    pause: logic.pause.with(handout: handout),
    uncover: logic.uncover.with(handout: handout),
    only: logic.only.with(handout: handout),
    plain-slide: plain-slide,
  )
  if cetz != none {
    let cetz-update(n) = cetz.draw.content((), logic.update-subslide-count(n))
    (
      cetz-uncover: logic.uncover.with(
        handout: handout,
        opaque: false,
        updater: cetz-update,
        hider: it => cetz.draw.hide(it, bounds: true),
      ), 
      cetz-only: logic.only.with(
        handout: handout,
        opaque: false,
        updater: cetz-update,
      ),
    )
  }
  if fletcher != none {
    (
      fletcher-uncover: logic.uncover.with(
        handout: handout,
        opaque: false,
        updater: none,
        hider: it => fletcher.hide(it, bounds: true),
      ),
      fletcher-only: logic.only.with(
        handout: handout,
        opaque: false,
        updater: none,
      ),
    )
  }
}
