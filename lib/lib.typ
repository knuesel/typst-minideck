// Library module imported by package.typ (the user-facing module), and by
// standard themes: this ensures that themes use only exported functions.
// (Themes cannot import the package itself as themes are included in the
// package and we cannot have circular dependencies).
#import "styling.typ": *
#import "util.typ"
#import "fonts.typ"
#import "colors.typ"
#import "layouts.typ"
