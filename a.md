Ah yes that works fine in many cases (including this `handout` example), thanks for clarifying.

```typst
#import "@preview/cetz:0.2.2" as cetz: *

#let fancy-shape() = {
  import draw: *
  // conditional on config...
  circle((), radius: 1)
  rect((rel: (-1,-1)), (rel: (2,2)))
}

#canvas({
  import draw: *
  fancy-shape()
})
```

The line between util and content-oriented packages is blurry though... 
