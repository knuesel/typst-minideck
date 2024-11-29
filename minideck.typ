#import "themes/themes.typ"
#import "lib/layouts.typ"
#import "lib/colors.typ"
#import "lib/fonts.typ"
#import "lib/logic.typ"
#import "lib/util.typ"

// `field` is "header" or "footer"
#let _process-head-foot(page-args, field, func, txt) = {
  if field in page-args {
    // If footer is set explicitly, this takes precedence so nothing to do
    return page-args
  }
  if func == none {
    // No callback defined means we should not change anything
    return page-args
  }
  page-args.insert(field, func(txt))
  return page-args
}

// Template to update `heading.outlined` using the given value.
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

// XXX rewrite docstring
// page arguments can be used to override the current page settings for this slide
// The footer of a slide can be overriden using either `footer` or
// `footer-text`:
//
// - `footer` can be used to set directly the page footer. If not specified,
//   `footer-text` will be considered instead.
//   
// - `footer-text` takes simple content (typically a string) that will be
//   passed to a theme function for transformation and layout,
//   and the result will be used as page footer. The value `auto` can be used
//   to let the theme function use the default text for this type of slide.
//
// - `footer-func` is the theme function called with `footer-text` as parameter
//   to make the footer for this type of slide.
//
// To leave the footer as it is (from a global `page` configuration), set
// `footer-func` to `none`.
#let _plain-slide(
  ..args,
  header-func: none,
  footer-func: none,
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
#let _format-args(format) = {
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

// Helper function to convert `user-scheme` to arguments for
// `fonts.font-scheme`.
// TODO: merge this with the similar code for color schemes
#let _one-font-scheme(theme-default, user-scheme) = {
  if type(user-scheme) == str {
    // Full scheme given by name, no use for defaults
    return fonts.font-scheme(base: user-scheme)
  }
  if user-scheme == auto {
    user-scheme = (:)
  }
  return fonts.font-scheme(base: theme-default, ..user-scheme)
}

// Make requested number of font schemes based on the user specification and
// theme default. Both the user and the theme can specifiy an array of schemes,
// or a single scheme which will be treated as an array of one or, for the user,
// the value `auto` to use the theme specification without modification.
// Each array value can be a scheme name or a scheme dict (complete or with only
// a subset of the valid keys), or `auto` to use a default value.
// For each array position, the user settings override the theme settings.
// If the user specified fewer schemes than the theme, the additional schemes
// from the theme are ignored (the user can append `auto` values to their array
// to prevent this). If more schemes are
// required that specified, the first scheme (which should be the most generic)
// is reused as many times as necessary.
#let _n-font-schemes(theme-default, user-schemes, n) = {
  // Make sure we have arrays of schemes
  if type(theme-default) != array {
    theme-default = (theme-default,)
  }
  if user-schemes == auto {
    // Special meaning of auto: use full theme array rather than an array
    // (auto,) that would use only the first value of the theme array
    user-schemes = theme-default
  }
  if type(user-schemes) != array {
    user-schemes = (user-schemes,)
  }

  // Ignore theme schemes beyond the user array length
  theme-default = theme-default.slice(0, user-schemes.len())

  // Repeat first scheme if theme has not enough
  for _ in range(theme-default.len(), n) {
    theme-default.push(theme-default.first())
  }
  // Same for user
  for _ in range(user-schemes.len(), n) {
    user-schemes.push(user-schemes.first())
  }

  return array.zip(theme-default, user-schemes).slice(0, n).map(
    ((theme, user)) => _one-font-scheme(theme, user)
  )
}

// Helper function to convert `user-scheme` to arguments for
// `colors.color-scheme`.
#let _color-scheme(theme-default, user-scheme) = {
  if type(user-scheme) == str {
    // Full scheme given by name, no use for defaults
    return colors.color-scheme(base: user-scheme)
  }
  if user-scheme == auto {
    user-scheme = (:)
  }
  return colors.color-scheme(base: theme-default, ..user-scheme)
}

// Resolve theme function if given as name
#let _resolve-theme(theme) = {
  if type(theme) == str {
    let theme-dict = dictionary(themes)
    if theme not in theme-dict {
      panic("No theme named " + repr(theme))
    }
    return theme-dict.at(theme)
  }
  return theme
}

// Prepare configuration for a single (non-composite) theme
#let _theme-config(
  plain-slide: none,
  format: none,
  metadata: none,
  font-scheme: none,
  color-scheme: none,
  theme,
) = {
  theme = _resolve-theme(theme)

  let props = theme()
  let req = props.requirements
  let fonts = _n-font-schemes(props.font-scheme, font-scheme, req.n-fonts)
  let color-scheme = _color-scheme(props.color-scheme, color-scheme)
  let colors = colors.get-colors(color-scheme, req.shade-samples, req.n-accents)

  return (
    plain-slide: plain-slide,
    page-args: _format-args(format),
    metadata: metadata,
    fonts: fonts,
    colors: colors,
  )
}

#let _theme-values(theme-config, theme) = {
  theme = _resolve-theme(theme)
  let cfg = theme-config(theme)
  return theme(cfg: cfg)
}

#let _compose-theme(theme-values, theme-spec) = {
  if type(theme-spec) != dictionary {
    theme-spec = (base: theme-spec)
  }

  if "base" not in theme-spec {
    panic("A composite theme must define a base theme")
  }

  let values = (:)

  if theme-spec.base != none {
    values += theme-values(theme-spec.base)
  }

  for (name, theme) in theme-spec {
    if name == "base" {
      continue
    }
    if theme == none {
      values.at(name) = none
      continue
    }
    let v = theme-values(theme)
    if name not in v {
      let theme-str = if type(theme) == str { theme } else { repr(theme) }
      panic("Cannot find '" + name + "' in theme '" + theme-str + "'")
    }
    values.at(name) = v.at(name)
  }

  // Make single template function from all templates
  let templates = ()
  for (name, val) in values {
    if name.ends-with("-template") and val != none {
      templates.push(val)
    }
  }

  // Remove sub-templates
  values = util.filter-dict(values, (k, v) => not k.ends-with("-template"))

  // Add template composed of sub-templates
  values.template = it => templates.fold(it, (acc, f) => {
   show: f
   acc
  })

  return values
}

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
  font-scheme: auto,
  color-scheme: auto,
  theme: "simple",
  handout: auto,
  cetz: none,
  fletcher: none,
  author: none,
  affiliation: none,
  logo: none,
  date: none,
) = {
  let theme-config = _theme-config.with(
    plain-slide: _plain-slide.with(handout: handout),
    format: format,
    metadata: _metadata(author, affiliation, logo, date),
    font-scheme: font-scheme,
    color-scheme: color-scheme,
  )
  let composed-values = _compose-theme(
    _theme-values.with(theme-config),
    theme,
  )
  
  (
    pause: logic.pause.with(handout: handout),
    uncover: logic.uncover.with(handout: handout),
    only: logic.only.with(handout: handout),
    ..composed-values,
    // Can be used to configure a theme and inspect the returned values
    theme-config: theme-config,
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
