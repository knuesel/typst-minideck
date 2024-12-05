#import "fonts.typ"
#import "util.typ"

//  Heading selectors
#let presentation-title =    heading.where(level: 1)
#let presentation-subtitle = heading.where(level: 2)
#let section-title =         heading.where(level: 3)
#let section-subtitle =      heading.where(level: 4)
#let slide-title =           heading.where(level: 5)
#let slide-subtitle =        heading.where(level: 6)
#let block-title =           heading.where(level: 7)
#let block-subtitle =        heading.where(level: 8)

#let _in-outline = state("__minideck-in-outline", false)

/*

  Minideck supports outlines with section titles, with slide titles, or both.
  
  Typst lets users select outline content in at least three ways:

  1. `set outline(depth: 3)`
  2. `set outline(target: slide-title)`
  3. `show section-title: set heading(outlined: false)`

  Minideck assumes the user uses only 1. and 2. to select the type of outline,
  and 3. is only used to include/exclude titles of particular slides (such
  as table of contents and bibliography slides). This way themes can setup
 `outline` show rules that simply look at the `outline` fields to adjust the
  output depending on the type of outline.
*/

// Selector for an outline with only section titles
// (only works if slide titles are excluded through outline `depth` and
// `target` rather than with `outlined: false` on slide headings.
#let outline-only-sections = selector.or(
  outline.where(depth: 3),
  outline.where(target: section-title),
)

// Selector for an outline with only slide titles (no section title)
// (only works if section titles are exluded through `outline.target` rather
// than by setting `outlined: false` on section headings).
#let outline-only-slides = outline.where(target: slide-title)

// Selector for an outline with both section and slide titles
// (only works if titles are not excluded with `outlined: false` on headings.
#let outline-sections-and-slides = selector.and(
  selector.or(
    // depth includes slide titles
    outline.where(depth: none),
    outline.where(depth: 5),
  ),
  selector.or(
    // target includes both section and slide titles
    outline.where(target: heading.where(outlined: true)), // default
    outline.where(target: section-title.or(slide-title)),
    outline.where(target: slide-title.or(section-title)),
  ),
)

// Template to format the outline using one paragraph per section, with section
// title on the first line and slide titles (if enabled by `outline.depth` and
// `outline.target` as additional lines. One block/paragraph per section makes
// it easy to style a section and its slides as a single unit.
// Control the spacing between sections with `spacing`, the indentation of
// slide titles with `indent` and the spacing between section and first slide
// title with `title-gap`.
// Note that `core-template` also applies some outline rules.
#let outline-template(cfg, spacing: 1em, indent: 0em, title-gap: 0em, doc) = {

  // Spacing between sections (paragraphs)
  show outline: set par(spacing: spacing)
  
  // Indent slide titles (every line after first paragraph line) under section
  show outline-sections-and-slides: set par(hanging-indent: indent)

  /*
    Outline entry: avoid `par` manipulations here as they would cause a new
    paragraph. We want a new paragraph between sections (which can include
    several slide titles each on one line) but not between individual slide
    titles.
  */

  // Don't show fill and page number in outline entry.
  // This rule must come first to be processed last, as it returns a
  // non-outline.entry object which prevents further rules from being applied.
  show outline.entry: it => link(it.element.location(), it.body)

  // Make each section its own paragraph (with large spacing between
  // paragraphs using the outline block spacing).
  show outline.entry.where(level: 3): it => {
      parbreak()
      // Add some spacing between section title and slide title without breaking
      // into two paragraphs.
      box(inset: (bottom: title-gap), it)
  }

  doc
}

// Bibliography template
// Note that `core-template` also applies some bibliography rules.
#let bibliography-template(cfg, doc) = {
  show bibliography: it => {
    set block(spacing: 2em)
    set par(justify: false) // in case it's true globally
    show regex("\[[0-9]+\]"): set align(top)
    show "[Online]. Available: ": none
    it
  }
  doc
}

// Template to override all font weights for `font` using `weights`.
// If `font` is `none` or `weights` are all default, no rule is applied.
#let weights-template(font, weights, doc) = {
  if font == none or fonts.is-default-weights(weights) {
    return doc
  }
  let (f, w) = (font, weights)
  show text.where(font: f, weight: "thin"):       set text(weight: w.thin)
  show text.where(font: f, weight: "extralight"): set text(weight: w.extralight)
  show text.where(font: f, weight: "light"):      set text(weight: w.light)
  show text.where(font: f, weight: "regular"):    set text(weight: w.regular)
  show text.where(font: f, weight: "medium"):     set text(weight: w.medium)
  show text.where(font: f, weight: "semibold"):   set text(weight: w.semibold)
  show text.where(font: f, weight: "bold"):       set text(weight: w.bold)
  show text.where(font: f, weight: "extrabold"):  set text(weight: w.extrabold)
  show text.where(font: f, weight: "black"):      set text(weight: w.black)
  doc
}

// Core rules that should almost always be applied for correct functionality
// (applied automatically by minideck, but themes or the user can disable it
// by specifiying `core-template: none`)
#let core-template(doc) = {
  // Bibliography
  set bibliography(title: none)
  
  // Outline: unset title for consistency (all slide titles are defined through
  // headings) and so the slide layout works when the user shows the outline
  // in two columns. Default to only section titles in outline.
  set outline(title: none, depth: 3)

  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }

  /* Headings */

  // Only section titles and slide titles should appear in outline
  // (and slide titles are disabled by default with outline(depth: 3))
  show selector.or(
    presentation-title,
    presentation-subtitle,
    section-subtitle,
  ): set heading(outlined: false)

  // Numbering: number only sections and show section titles without useless 
  // numbering of level 1 and 2 (which are always 0).
  let section-numbering(..args) = str(args.pos().at(2)) + "."
  show section-title: set heading(numbering: section-numbering)
    
  // Exclude certain titles from PDF outline: only section titles, slide titles
  // and slide subtitles make sense. Section slides should only have a subtitle
  // on the same slide, while normal "slides" can spread on several pages that
  // might have different subtitles.
  show selector.or(
    presentation-title,
    presentation-subtitle,
    section-subtitle,
    block-title,
    block-subtitle,
  ): set heading(bookmarked: false)

  doc
}

// Basic appearance settings that use only standard cfg fields.
// Most themes will want to apply this template.
#let basic-template(cfg, doc) = {
  let (page-args, fonts, colors) = cfg
  let (bg-color, .., fg-color) = colors.shades
  let (font-scheme, ..) = fonts

  set page(
    fill: bg-color,
    ..page-args,
  )

  // General text
  set text(fg-color, ..font-scheme.text)
  show math.equation: set text(..font-scheme.math)
  set strong(delta: font-scheme.delta)

 // Redefine text weights according to font scheme
  show: weights-template.with(
    font-scheme.text.at("font", default: none),
    font-scheme.text-weights,
  )

  // Raw text
  show raw: set text(..font-scheme.raw)
  show raw: set underline(stroke: 0pt) // no underline, it looks awful
  show raw.where(block: true): set par(justify: false) // in case it's true globally

  // Footnotes: recreate default separator but with our foreground color
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + fg-color))

  // Better default spacing for headings that are not "placed"
  show heading: set block(below: 1.5em)

  doc
}
