#import "@local/minideck:0.3.0" // XXX
#import minideck.themes: *

#let (template, slide, titled-block) = minideck.config(
  color-scheme: (shades: (navy, white)),
  theme: "metropolis",
)

#show minideck.slide-title: set text(0.9em)
#show minideck.slide-title: pad.with(-3mm)

#show: template

#slide(margin: 1cm, footer: none)[
  = Custom style

  Custom colors, smaller text & less spacing in title bar, smaller margins:

  #v(1em)
  #show raw.where(block: true): set text(0.9em)
  #show raw.where(block: true): set block(inset: 0.5em)
  #titled-block(transparent: false, width: 100%)[Configuration][
    ```
    #let (template, slide) = minideck.config(
      color-scheme: (shades: (navy, white)),
      theme: "metropolis",
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
  #v(1fr)
]
