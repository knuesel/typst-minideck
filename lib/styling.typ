#include "colors.typ"

/*
  Heading selectors:
   - offset 0 depth 1 level 1: presentation titles
   - offset 0 depth 2 level 2: presentation subtitle
   - offset 2 depth 1 level 3: section titles
   - offset 2 depth 2 level 4: section subtitle
   - offset 4 depth 1 level 5: slide title
   - offset 4 depth 2 level 6: slide subtitle
   - offset 6 depth 1 level 7: block title
   - offset 6 depth 2 level 8: block subtitle
*/
#let presentation-title =    heading.where(offset: 0, depth: 1)
#let presentation-subtitle = heading.where(offset: 0, depth: 2)
#let section-title =         heading.where(offset: 2, depth: 1)
#let section-subtitle =      heading.where(offset: 2, depth: 2)
#let slide-title =           heading.where(offset: 4, depth: 1)
#let slide-subtitle =        heading.where(offset: 4, depth: 2)
#let block-title =           heading.where(offset: 6, depth: 1)
#let block-subtitle =        heading.where(offset: 6, depth: 2)

/*

  Minideck supports outlines with section titles, with slide titles, or both.
  
  Typst lets users select outline content in three ways:

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
#let outline-only-sections = outline.where(depth: 3)
  .or(outline.where(target: section-title))

// Selector for an outline with only slide titles (no section title)
// (only works if section titles are exluded through `outline.target` rather
// than by setting `outlined: false` on section headings).
#let outline-only-slides = outline.where(target: slide-title)

// Selector for an outline with both section and slide titles
// (only works if titles are not excluded with `outlined: false` on headings.
#let outline-sections-and-slides = (
  // depth includes slide titles
  outline.where(depth: none).or(outline.where(depth: 5))
).and(
  // target includes both section and slide titles
  outline.where(target: heading.where(outlined: true)) // default
    .or(outline.where(target: section-title.or(slide-title)))
    .or(outline.where(target: slide-title.or(section-title)))
)

// This template is written to be used as `show: outline-template` rather than
// `show outline: outline-template` as otherwise the nested show-it rule for
// `outline.entry` would be hard for users to override.
#let outline-template(cfg, spacing: 1em, indent: 0em, title-gap: 0em, doc) = {
  // Spacing between sections (paragraphs)
  show outline: set block(spacing: spacing)
  // Indent slide titles (every line after first paragraph line) under section
  show outline-sections-and-slides: set par(hanging-indent: indent)

  /*
    Outline entry: avoid `par` manipulations here as they would cause a new
    paragraph (which affects vertical spacing). We want a new paragraph between
    sections but not between slide titles.
  */

  // Don't show fill and page number in outline entry.
  // This rule must come first to be processed last, as it returns a
  // non-outline.entry object which prevents further rules from being applied.
  show outline.entry: it => it.body
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
#let bibliography-template(cfg, doc) = {
  show bibliography: it => {
    let (font-scheme, ..) = cfg.fonts
    set block(spacing: 2em)
    set par(justify: false) // in case it's true globally
    show regex("\[[0-9]+\]"): set align(top)
    show "[Online]. Available: ": none
    it
  }
  doc
}

// Basic template: settings that most themes should apply.
#let basic-template(cfg, it) = {
  let (paper, fonts, shades) = cfg
  let (font-scheme, ..) = fonts
  let (regular, medium, bold) = font-scheme.text-weights
  let (bg-color, .., fg-color) = shades

  set page(
    paper: paper,
    header-ascent: 0pt,
    footer-descent: 0pt,
    fill: bg-color,
  )

  // General text
  set text(fg-color, weight: regular, ..font-scheme.text)
  show math.equation: set text(..font-scheme.math)
  set strong(delta: font-scheme.delta)

  // Raw text
  show raw: set text(..font-scheme.raw)
  show raw: set underline(stroke: 0pt) // no underline, it looks awful
  show raw.where(block: true): set par(justify: false) // in case it's true globally

  // Bibliography
  set bibliography(title: none)
  
  // Footnotes: recreate default separator but with our foreground color
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + fg-color))

  // Outline: unset title for consistency (all slide titles are defined through
  // headings) and so the slide layout works when the user shows the outline
  // in two columns. Default to only section titles in outline.
  set outline(title: none, depth: 3)

  /* Headings */

  // Use the font-scheme's definition of bold for all headings
  show heading: set text(weight: bold) // XXX replace with show text.where

  // Only section titles and slide titles should appear in outline
  // (and slide titles are disabled by default with outline(depth: 3))
  show presentation-title
    .or(presentation-subtitle)
    .or(section-subtitle): set heading(outlined: false)

  // Numbering: number only sections and show section titles without useless 
  // numbering of level 1 and 2 (which are always 0).
  let section-numbering(..args) = str(args.pos().at(2)) + "."
  show section-title: set heading(numbering: section-numbering)
    
  // Exclude certain titles from PDF outline: only section titles, slide titles
  // and slide subtitles make sense. Section slides should only have a subtitle
  // on the same slide, while normal "slides" can spread on several pages that
  // might have different subtitles.
  show presentation-title
    .or(presentation-subtitle)
    .or(section-subtitle)
    .or(block-title)
    .or(block-subtitle): set heading(bookmarked: false)

  // Better default spacing for headings that are not "placed"
  show heading: set block(below: 1.5em)

  it
}
