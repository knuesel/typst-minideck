#import "@local/minideck:0.3.0" // XXX

#let (template, slide, pause, uncover, only) = minideck.config()

#show: template

#slide[
  = Subslides with `pause`

  A
  #only(2)[D]

  #show: pause

  B

  #show: pause

  C
]
