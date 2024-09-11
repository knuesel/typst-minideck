#import "themes/themes.typ"
#import "lib/layouts.typ"
#import "lib/colors.typ"
#import "lib/fonts.typ"
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

// Template to update `heading.outline` using the given value.
// If `outlined` is `auto`, it is set `true` if the current slide comes before
// the `end-slide` label, `false` otherwise.
#let _apply-outlined(outlined, it) = context {
  let want-outlined = outlined
  if want-outlined == auto {
    // Selector for end-slide label before current slide
    let end-before = selector(<end-slide>).before(here(), inclusive: false)
    // Current slide is backup slide if there is such a label before
    want-outlined = query(end-before).len() == 0
  }
  set heading(outlined: want-outlined)
  it
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
  outlined: auto,
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
  set heading(offset: offset)
  show: _apply-outlined.with(outlined)
  logic.subslides(handout: handout, steps: steps, it)
}

// Return paper name for given format string
#let _paper(format) = (
  "4:3": "presentation-4-3",
  "16:9": "presentation-16-9",
).at(format, default: format)

// Return page arguments for given format
#let _format-arg(format) = {
  if type(format) == str {
    return (paper: _paper(format))
  }
  return format
}

// Return the presentation metadata
#let _metadata(author, affiliation, logo, date) = (
  author: author,
  affiliation: affiliation,
  logo: logo,
  date: date,
)

// Gets a field from the dictionary returned by a theme function.
// The theme can be given as a standard theme name or as a function.
// Returns `none` if the theme was not found.
#let _get-theme-field(get-config, field, theme) = {
  if type(theme) == str {
    if theme not in themes {
      return none
    }
    // Resolve theme name to function
    theme = themes.at(theme)
  }
  return theme(get-config, _plain-slide).at(field)
}

// Function used by themes to get the configuration from the user.
// Minideck configures the first four arguments before passing this function to
// the theme. The theme uses the keyword arguments to request particular shades,
// etc.
// XXX
#let _get-config(
  format: "4:3",
  meta-data: _metadata(none, none, none, none),
  font-scheme-args: (:),
  color-scheme-args: (:),
  n-fonts: 1,
  default-font-scheme: "default",
  shade-samples: (0%, 100%),
  n-accents: 2,
  default-color-scheme: "default",
) = {
  let make-font-scheme(user-spec) = fonts._font-scheme(
    // To get theme defaults we can pass _get-config with default arguments
    _get-theme-field.with(_get-config, "default-font-scheme"),
    base: default-font-scheme,
    ..user-spec,
  )
  // Make sure we have an array of font scheme specs
  if type(font-scheme-args) != array {
    font-scheme-args = (font-scheme-args,)
  }
  font-scheme-args = font-scheme-args.map(spec =>
    if type(spec) == dictionary { 
      spec
    } else {
      (base: spec)
    }
  )
    
  // Make a font scheme for each user specification
  let font-schemes = font-scheme-args.map(make-font-scheme)

  let color-scheme = colors._color-scheme(
    _get-theme-field.with(_get-config, "default-color-scheme"),
    base: default-color-scheme,
    ..color-scheme-args,
  )
  return (
    page-args: _format-arg(format),
    metadata: meta-data,
    fonts: fonts.get-fonts(font-schemes, n-fonts),
    colors: colors.get-colors(color-scheme, shade-samples, n-accents),
    default-font-scheme: default-font-scheme,
    default-color-scheme: default-color-scheme,
  )
}

// We have some spaghetti code here due to mutual recursion between three
// functions: colors.color-scheme needs get-theme-color-scheme to resolve
// schemes passed by theme. And get-theme-color-scheme needs get-config to call
// the theme function to get the defaults. And get-config needs color-scheme to
// resolve the user scheme specification before giving it to the theme.
// Hopefully this will be improved once typst gets user types (which we could
// use to expose the theme defaults).
// To get the theme defaults we can pass _get-config with default arguments
#let font-scheme = fonts._font-scheme.with(
  _get-theme-field.with(_get-config, "default-font-scheme"))
#let color-scheme = colors._color-scheme.with(
  _get-theme-field.with(_get-config, "default-color-scheme"))

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
// date: name of event, formatted date...
// Author, affiliation, logo and date are defined here so that minideck can
// normalize them before handing the values to the theme (while the theme and
// title slide functions are controlled directly by the theme).
#let config(
  format: "4:3",
  font-scheme: (:),
  color-scheme: (:),
  theme: "simple",
  handout: auto,
  cetz: none,
  fletcher: none,
  author: none,
  affiliation: none,
  logo: none,
  date: none,
) = {
  let plain-slide = _plain-slide.with(handout: handout)
  let get-config = _get-config.with(
    format: format,
    meta-data: _metadata(author, affiliation, logo, date),
    font-scheme-args: font-scheme,
    color-scheme-args: color-scheme,
  )

  // Resolve theme if given as name
  if type(theme) == str {
    theme = dictionary(themes).at(theme)
  }

  (
    // theme sets cfg, template, and slide functions
    ..theme(get-config, plain-slide),
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
