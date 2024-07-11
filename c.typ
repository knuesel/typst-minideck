#import "@preview/cetz:0.2.2" as cetz: *

#let fancy-shape() = {
  import draw: *
  circle((), radius: 1)
  rect((rel: (-1,-1)), (rel: (2,2)))
}

#canvas({
  import draw: *
  line((0,0), (3,1))
  shapes()
})
