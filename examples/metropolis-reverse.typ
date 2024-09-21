#import "@local/minideck:0.3.0" // XXX
#import minideck.themes: *

#let (template, slide, title-block) = minideck.config(
  color-scheme: (reverse: true),
  theme: "metropolis",
)

#show: template

#slide(footer: none)[
  = Dark variant

  For a dark variant, simply reverse the color shades:

  #v(1em)
  #title-block(transparent: false, width: 100%)[Configuration][
    ```

    #minideck.config(
      theme: "metropolis",
      color-scheme: (reverse: true),
    )

    
    ```
  ]
]
