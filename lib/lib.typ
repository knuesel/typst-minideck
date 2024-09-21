// Library module imported by package.typ (the user-facing module), and by
// standard themes: this ensures that themes use only exported functions.
// (Themes cannot import the package itself as themes are included in the
// package and we cannot have circular dependencies).
#import "util.typ"
#import "fonts.typ"
#import "colors.typ"
#import "layouts.typ"
#import "layouts.typ": use-margin
#import "styling.typ"
#import "styling.typ": presentation-title, presentation-subtitle, section-title, section-subtitle, slide-title, slide-subtitle, block-title, block-subtitle
