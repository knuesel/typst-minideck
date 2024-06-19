# typst-minideck

A minimalist package for dynamic slides in typst.

minideck provides basic functionality for dynamic slides (`pause`, `uncover`, ...) and leaves theming and layout to plain typst and other packages.

## Usage

The simplest way to use minideck is to import all exported functions with their default settings:

```typst
#import "@local/minideck:0.1.0": *

#set page(paper: "presentation-4-3")
#set text(24pt)

// A simple `slide` wrapper that centers content
#title-slide[
  = Slides with `minideck`
  == Some examples
  John Doe

  #datetime.today().display()
]

#slide[
  = Some title

  Some content

  #show: pause

  More content

  1. One
  2. Two
  #show: pause
  3. Three
]
```

Instead of `#show: pause`, you can use `#uncover(2,3)[...]` to make content visible only on subslides 2 and 3, or `#uncover(from: 2)[...]` to have it visible on subslide 2 and following.

The `only` function is similar to `uncover`, but instead of hiding the content (without affecting the layout), it removes it.

```typst
#slide[
  = `uncover` and `only`
  
  #uncover(1, from:3)[
    Content visible on subslides 1 and 3+
    (space reserved on 2).
  ]

  #only(2,3)[
    Content included on subslides 2 and 3
    (no space reserved on 1).
  ]

  Content always visible.
]
```

Contrary to `pause`, the `uncover` and `only` functions also work in math mode:

```typst
#slide[
  = Dynamic equation

  $
    f(x) &= x^2 + 2x + 1  \
         #uncover(2, $&= (x + 1)^2$)
  $
]
```

When mixing `pause` with `uncover`/`only`, the sequence of pauses should be taken as reference for the meaning of subslide indices. For example content after the first pause always appears on the second subslide, even if it's preceded by a call to `#uncover(from: 3)[...]`.

### Handout mode

minideck can make a handout version of the document, in which dynamic behavior is disabled: the content of all subslides is shown together in a single slide.

To compile a handout version, pass `--input handout=true` in the command line:

```bash
typst compile --input handout=true myfile.typ
```

It is also possible to enable handout mode from within the document, as shown in the next section.

### Configuration

The configuration system is inspired by Touying: to change the behavior of minideck, use the functions returned by a call to `minideck.config`. For example, handout mode can also be enabled like this:

```typst
#import "@local/minideck:0.1.0"
#set page(paper: "presentation-4-3")
#set text(24pt)

#let (slide, pause) = minideck.config(handout: true)

#slide[
  = Slide title
  
  Some text

  #show: pause

  More text
]
```

(The default value of `handout` is `auto`, in which case minideck checks for a command line setting as in the previous section.)

On the left-hand side of `=`, list all the functions you want to use (if you want only one, you can write for example `#let (slide,) = minideck.config(...)`).

Technically, this is equivalent to importing the functions with default behavior (as in previous sections) then redefining them with

```typst
#let slide = slide.with(handout: true)
#let pause = pause.with(handout: true)
```

Also equivalent would be to set the handout parameter in each call:

```typst
#import "@local/minideck:0.1.0": *
#set page(paper: "presentation-4-3")
#set text(24pt)

#slide(handout: true)[
  = Slide title
  
  Some text

  #show: pause.with(handout: true)

  More text
]
```

Note: if you reconfigure minideck functions with `config`, make sure you don't import the default functions with `#import "@local/minideck:0.1.0": *` (make sure you remove the `: *`). Otherwise you risk forgetting to reassign a function in the `config` call, and then get the default behavior without noticing.

### Integration with CeTZ

You can use `uncover` and `only` (but not `pause`) in CeTZ figures, with the following extra steps:

* Get CeTZ-specific functions `cetz-uncover` and `cetz-only` by passing the CeTZ module to `minideck.config` (see example below).
   
   This ensures that minideck uses CeTZ functions from the correct version of CeTZ.

* Add a `context` keyword outside the `canvas` call.
   
   This is required to access the minideck subslide state from within the canvas without making the content opaque (CeTZ needs to inspect the canvas content to make the drawing).

Example:

```typst
#import "@preview/cetz:0.2.2" as cetz: *
#import "@local/minideck:0.1.0"

#let (slide, only, cetz-uncover, cetz-only) = minideck.config(cetz: cetz)

#set page(paper: "presentation-4-3")
#set text(24pt)

#slide[
  = In a CeTZ figure

  Above canvas
  #context canvas({
    import draw: *
    cetz-only(3, rect((0,-2), (14,4), stroke: 3pt))
    cetz-uncover(from: 2, rect((0,-2), (16,2), stroke: blue+3pt))
    content((8,0), box(stroke: red+3pt, inset: 1em)[
      A typst box #only(2)[on 2nd subslide]
    ])
  })
  Below canvas
]
```

### Integration with fletcher

The same steps are required as for CeTZ integration (passing the fletcher module to get fletcher-specific functions), plus an additional step:

* Give explicitly the number of subslides to the `slide` function.
   
   This is required because I could not find a reliable way to update a typst state from within a fletcher diagram, so I cannot rely on the state to keep track of the number of subslides.

Example:

```typst
#import "@preview/fletcher:0.5.0" as fletcher: diagram, node, edge
#import "@local/minideck:0.1.0"
#let (slide, fletcher-uncover) = minideck.config(fletcher: fletcher)
#set page(paper: "presentation-4-3")
#set text(24pt)

#slide(steps: 2)[
  = In a fletcher diagram

  #set align(center)

  Above diagram

  #context diagram(
    node-stroke: 1pt,
    node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
    edge("-|>"),
    node((1,0), align(center)[A]),
    fletcher-uncover(from: 2, edge("d,r,u,l", "-|>", [x], label-pos: 0.1))
  )
  
  Below diagram
]
```

## Comparison with other slides packages

In short: I made minideck because [Polylux](https://github.com/andreasKroepelin/polylux) makes compilation (especially incremental compilation) slow in some cases, and [Touying](https://github.com/touying-typ/touying) is a bit complicated and overkill for my needs.

Performance: the implementation of `pause` at least can be much faster than the one in Polylux. Touying is slightly faster than minideck in my tests.

Features: minideck allows using `uncover` and `only` in CeTZ figures and fletcher diagrams (contrary to polylux) but with extra steps (see below).  

Syntax: the minideck `pause` is more cumbersome to use: one must write `#show: pause` instead of `#pause`. On the other hand minideck's `uncover` and `only` can be used directly in equations without requiring a special math environment as in Touying (I think).

Other: minideck sometimes has better error messages than Touying due to implementation differences: the minideck stack trace points back to the user's code while Touying errors sometimes point only to an output page number.

## Limitations

* `pause`, `uncover` and `only` work in enumerations but they require explicit enum indices (`1. ...` rather than `+ ...`) as they cause a reset of the list index.
* Usage in a CeTZ canvas or fletcher diagram requires a `context` keyword in front of the `canvas`/`diagram` call (see above).
* fletcher diagrams also require to specify the number of subslides explicitly (see above).
* `pause` doesn't work in CeTZ figures, fletcher diagrams and math mode.
* `pause` requires writing `#show: pause` and its effect is lost after the `#show` call goes out of scope. For example this means that one can use `pause` inside of a grid, but further `pause` calls after the grid (in the same slide) won't work as intended.

## Internals

The package uses states with the following keys:

`__minideck-subslide-count`: an array of two integers for counting pauses and keeping track of the subslide number automatically. The first value is the number of subslides so far referenced in current slide. The second value is the number of pauses seen so far in the current slide. Both values are kept in one state so that an update function can update the number of subslides based on the number of pauses, without requiring a context. This avoids problems with layout convergence.

`__minideck-subslide-step`: the current subslide being generated while processing a slide.
