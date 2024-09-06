#import "@local/minideck:0.3.0" // XXX
#import minideck.themes: *

#let (template, slide, title-block) = minideck.config(
  color-scheme: (shades: (white, navy)),
  theme: metropolis.with(variant: "dark"),
)

#show minideck.slide-title: set text(0.9em)
#show minideck.slide-title: pad.with(-3mm)

#show: template


#slide(margin: 1cm, footer: none)[
  = Example

  Dark theme variant, custom color shades, smaller text and less spacing in the title bar, smaller margins.

  #v(1fr)
  #show raw.where(block: true): set text(0.9em)
  #show raw.where(block: true): set block(inset: 0.5em)
  #title-block(transparent: false)[Configuration][
    ```
    #let (template, slide, title-block) = minideck.config(
      color-scheme: (shades: (white, navy)),
      theme: metropolis.with(variant: "dark"),
    )
    #show minideck.slide-title: set text(0.9em)
    #show minideck.slide-title: pad.with(-3mm)
    #show: template

    #slide(margin: 1cm)[ // Just for this slide
      ...
    ]
    ```
  ]
  #v(1fr)

  To change margins globally, use `set page(margin: 1cm)`
]
