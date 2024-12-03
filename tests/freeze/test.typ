#import "/package.typ" as minideck

#let (template, slide, pause, uncover, only) = minideck.config()

#show: template

#set heading(numbering: "1.")
#set math.equation(numbering: "1)")

// Just a bunch of multi-step slides with equations is enough to cause a convergence failure

#slide(steps: 2)[
  $ x $
]
#slide(steps: 2)[
  $ x $
]
#slide(steps: 2)[
  $ x $
]
#slide(steps: 2)[
  $ x $
]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #only(2)[
//     $ y $
//   ]
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #only(2)[
//     $ y $
//   ]
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #only(2)[
//     $ y $
//   ]
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #only(2)[
//     $ y $
//   ]
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #show: pause
//   $ y $
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #show: pause
//   $ y $
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #show: pause
//   $ y $
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #show: pause
//   $ y $
// ]

// #slide(steps: 2)[
//   = Title
//   Text#footnote[X]
//   $ x $
//   #show: pause
//   $ y $
// ]
