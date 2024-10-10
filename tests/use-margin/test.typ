#import "/lib/layouts.typ": *

#set page(margin: 1cm, width: 10cm, height: 14cm)
#top-bar(height: 4cm, fill: red)
#block(width: 100%, height: 100% - 4cm)[
  #use-margin(100%, top: 0%, block(width: 100%, height: 100%, fill: green))
]

// TODO: replace test with the following after typst 0.12 release
// #block(width: 100%, height: 1fr)[
//   #use-margin(100%, top: 0%, block(width: 100%, height: 100%, fill: green))
// ]
