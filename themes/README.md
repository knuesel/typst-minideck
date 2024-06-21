# Minideck themes

A theme is a module that exports `config` and `with` functions.

The `with` function must simply forward its arguments to `config.with`.

The `config` function has the following positional inputs:

  - `minideck.slide` function

and must accept at least the following named inputs:

  - `paper`: a string specifying a standard paper size

and return as output a dictionary of configured functions including at least

  - `theme`: a template for the whole document
  - `slide`: the input `slide` function or a wrapper for it
  - `title-slide`: the input `slide` function or a wrapper for it

The `config` function can accept additional parameters and return additional
values in the output dictionary. The functions in the output dictionary can
accept non-standard parameters.

The returned functions that make slides (`slide`, `title-slide` and possibly
others) should generally use the `slide` input function to respect how it was
configured by the user.


A theme module is meant to be used like this:

```
import "minideck"
import "fancy-theme"
#let (theme, slide, title-slide) = minideck.config(theme: fancy-theme)
#show: theme
```

or when theme configuration is required:

```
import "minideck"
import "fancy-theme"
#let (theme, slide, title-slide) = minideck.config(
  theme: fancy-theme.with(variant: "dark"),
)
#show: theme
```

Direct use of external themes without going through `minideck.config` might be
implemented once typst has support for set/show rules on user-defined types.
