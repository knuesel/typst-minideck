# minideck themes

A theme is implemented through a configuration function that has the following positional inputs:

  - `minideck.slide` function

and must accept at least the following named input:

  - `paper`: can be a string specifying a standard paper size such as
             "presentation-4-3", or a dict with `width` and `height` lengths

and return as output a dictionary of configured functions including at least

  - `template`: a template for the whole document
  - `slide`: the input `slide` function or a wrapper for it
  - `title-slide`: the input `slide` function or a wrapper for it

The configuration function can accept additional parameters and return
additional values in the output dictionary.
The functions in the output dictionary can also accept non-standard parameters.

The returned functions that make slides (`slide`, `title-slide` and possibly
others) should generally use the `slide` input function to respect how it was
configured by the user.


An `ocean` theme from a `fancy-themes` package could be used like this:

```
import "minideck"
import "fancy-themes"
#let (template, slide, title-slide) = minideck.config(theme: fancy-themes.ocean)
#show: template
```

or when theme configuration is required:

```
import "minideck"
import "fancy-themes"
#let (template, slide, title-slide) = minideck.config(
  theme: fancy-themes.ocean.with(variant: "dark"),
)
#show: template
```
