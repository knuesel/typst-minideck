#import "@preview/cetz:0.2.2"
#import "/lib/colors.typ": *

#set page(margin: 1cm)

#let show-colors(colors) = colors.enumerate().map(((i, c)) =>
  box(square(size: 1cm, fill: c)[#i])).join()

#let show-hues(colors, dots: black) = box({
  if type(dots) == color {
    dots = colors.map(x => dots)
  }
  cetz.canvas({
    import cetz.draw
    draw.circle((0,0), radius: 5mm)
    for (i, c) in colors.enumerate() {
      let (lightness, chroma, hue, alpha) = oklch(c).components()
      draw.circle((hue, 5mm), stroke: none, fill: dots.at(i), radius: 2pt)
      draw.content((hue, 8mm), [#i])
    }
  })
})

#let show-accents(accents, n) = {
  let new = _n-accents(accents, n)
  show-colors(new)
  h(1cm)
  let dots = range(calc.min(accents.len(), new.len())).map(_ => black)
  if new.len() > accents.len() {
    dots += range(accents.len(), new.len()).map(_ => red)
  }
  show-hues(new, dots: dots)
}

`n-accents`:\
#show-accents((red,), 3)\
#show-accents((red,), 6)

#show-accents((red, red), 3)\
#show-accents((red, red.rotate(90deg)), 3)\
#show-accents((red, green, blue), 2)\

Palette from yellow doesn't work well due to 
#link("https://github.com/typst/typst/issues/4816"):\
#show-accents((yellow,), 8)\


Other example:\ 
#let c = rgb("#00ffe0").rotate(0deg)
#show-colors((c, c.rotate(40deg)))

`sample-shades`:\
#show-colors(_sample-shades((white, red, black), 2))\
#show-colors(_sample-shades((white, red, black), 3))\
#show-colors(_sample-shades((white, red, black), 4))\
#show-colors(_sample-shades(gradient.linear(white, navy), 4))\
#show-colors(_sample-shades(gradient.linear(white, navy), (10%, 90%, 100%)))\
// Gradient samples in matching number -> disregard gradient positions
#show-colors(_sample-shades((white, red, black), (10%, 90%, 100%)))\


#show-colors(get-shades(auto, samples: 4, default: "metropolis"))
