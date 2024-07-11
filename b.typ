#import "@preview/cetz:0.2.2" as cetz: *

#let myshape() = {
  import draw: *
  group(anchor: "default", {
    anchor("a", (rel: (0,0)))
    circle((), radius: 1)
    rect((rel: (-1,-1)), (rel: (6,2)))
    // anchor("default", (1.5, 0.5))
    content("a")[a]
  })
}

#canvas({
  import draw: *
  line((0,0), (3,3), (4,3))
  myshape()
})
