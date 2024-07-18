#let font-themes = (
  default: (
    text: (:),
    raw: (:), 
    math: (:),
    presentation-title: (size: 1.4em), // relative to level 4 default
    presentation-subtitle: (size: 1.2em), // relative to level 5 default
    section-title: (:),
    section-subtitle: (:),
    slide-title: (:),
    slide-subtitle: (:),
    strong: (:),
  ),
  fira-sans: (
    text: (font: "Fira Sans",),
    raw: (font: "Fira Mono",),
    math: (font: "Fira Math",),
    presentation-subtitle: (weight: "regular",),
  ),
  fira-sans-light: (
    text: (font: "Fira Sans", weight: "light"),
    raw: (font: "Fira Mono", weight: "light"), // or bolder?
    math: (font: "Fira Math", weight: "light"),
    presentation-title: (weight: "regular",),
    presentation-subtitle: (weight: "light",),
    section-title: (weight: "regular",),
    section-subtitle: (weight: "light",),
    slide-title: (weight: "regular",),
    slide-subtitle: (weight: "regular",),
    strong: (delta: 100),
  ),
  libertinus-sans: (
    text: (font: "Libertinus Sans",),
    raw: (font: "DejaVu Sans Mono",),
    math: (font: "New Computer Modern Math",),
  ),
)
