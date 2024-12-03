// Counter for pauses and for automatic tracking of subslide number.
// First value: number of subslides so far referenced in current slide.
// Second value: number of pauses so far in current slide.
// Both values are kept in one state so that an update function can update the
// number of subslides based on the number of pauses, without requiring a
// context. This avoids problems with layout convergence.
#let _subslide-count = state("__minideck-subslide-count", (0, 0))

// Current subslide being generated for current slide
#let _subslide-step = state("__minideck-subslide-step", 0)

// Return a state update for `_subslide_count` ensuring that the subslide count
// (first counter value) is at least `n`.
#let update-subslide-count(n) = _subslide-count.update(((x, y)) => (calc.max(n, x), y))

// Return a state update for `_subslide_count` to increment the pause index
// (first value) and to ensure that the subslide count is at least equal to the
// new pause index.
#let update-by-pause() = _subslide-count.update(((x, y)) => (calc.max(x, y+2), y+1))

// If `handout` is `auto`, infer its value from command-line input
#let _is-handout(handout) = {
  if handout == auto {
    sys.inputs.at("handout", default: none) == "true"
  } else {
    handout
  }
}

// Show one subslide of the slide.
// The subslide counter starts at 0 for every subslide, so that its
// value can be used in the subslide to compare with `_subslide-step`.
#let _subslide(n, freeze, it) = {
  if freeze == auto {
    // freeze = (page, heading, footnote, math.equation).map(counter)
    freeze = (math.equation,).map(counter)
  } else if freeze == none {
    freeze = ()
  }

  // Do state updates in-between weak pagebreaks so they don't affect the footer
  // of the previous subslide, and are in force for the header of the next one.
  pagebreak(weak: true)
  _subslide-step.update(n)
  // We don't reset the first value here as it's unnecessary and causes
  // convergence issues in Typst 0.12
  _subslide-count.update(((x, y)) => (x, 0))
  // Freeze some states and counters
  if n == 0 {
    [#metadata(none)<__minideck-slide>]
  } else  {
    context {
      let loc = query(selector(<__minideck-slide>).before(here()))
        .last().location()
      for s in freeze {
        s.update(s.at(loc))
      }
    }
  }
  pagebreak(weak: true)

  if n > 0 {
    set heading(outlined: false)
    it
  } else {
    it
  }
}
      
// Hide content if current subslide step is smaller than pause index.
#let _pause(updater, hider, it) = {
  let pause-index = _subslide-count.get().at(1)
  if _subslide-step.get() < pause-index{ hider(it) } else { it } 
}

// Increase pause counter and hide content if current `_subslide-step` is
// smaller. Use this function as `#show: pause` or `#show: pause.with(...)`.
// `updater` is a callback that returns a state update for `_subslide-count` to
// increment the pause index (second counter value) and to ensure that the
// subslide count (first counter value) is at least the pause index plus 1. This
// callback is normally `update-by-pause`.
// `hider` is the callback used to hide `it` when appropriate.
// If `handout` is `true`, dynamic features are disabled: all slide content is
// shown in a single subslide. If `auto`, the value is taken as `true` if
// `--input handout=true` is passed on the command line, `false` otherwise.
// If `opaque` is true, the result will already have `context` invoked, otherwise
// the caller is responsible for invoking `context` in a suitable scope.
#let pause(handout: auto, opaque: true, updater: update-by-pause, hider: hide, it) = {
  if _is-handout(handout) {
    return it
  }
  update-by-pause()
  if opaque {
    context _pause(updater, hider, it)
  } else {
    // return non-opaque content: caller must ensure context is available
    _pause(updater, hider, it)
  }
}

// Hide `it` on all given subslide indices and/or starting at `from`.
// Subslide indices start at 1.
#let _hide-or-show(updater, hider, indices, from, it) = {
  // Convert zero-based subslide step to 1-based user-facing subslide index
  let j = _subslide-step.get() + 1
  let visible = (from != none and j >= from) or j in indices
  if visible { it } else { hider(it) }
}

// Hide `it` on all given subslide indices and/or starting at `from`.
// Subslide indices start at 1.
// This is used by `uncover` (hider=hide) and `only` (hider=`it=>none`).
// `updater` is a callback that takes a number `n` and returns a state update
// for `_subslide-count` to ensure that the first counter value is at least `n`.
// This callback is normally `update-subslide-count`, but CeTZ needs one that
// returns a CeTZ element.
// `hider` is the callback used to hide `it` when appropriate.
// If `handout` is `true`, dynamic features are disabled: all slide content is
// shown in a single subslide. If `auto`, the value is taken as `true` if
// `--input handout=true` is passed on the command line, `false` otherwise.
// If `opaque` is true, the result will already have `context` invoked, otherwise
// the caller is responsible for invoking `context` in a suitable scope.
#let _process(handout, opaque, updater, hider, indices, from, it) = {
  if _is-handout(handout) {
    return it
  }
  let from-array = if from == none { () } else { (from,) }

  if updater != none {
    updater(calc.max(..indices, ..from-array))
  }

  if opaque {
    context _hide-or-show(updater, hider, indices, from, it)
  } else {
    // return non-opaque content: caller must ensure context is available
    _hide-or-show(updater, hider, indices, from, it)
  }
}

// Uncover `it` on all given subslide indices and/or from given index.
// Subslide indices start at 1.
// See `_process` for the other parameters.
#let uncover(
  from: none,
  handout: auto,
  opaque: true,
  updater: update-subslide-count,
  hider: hide,
  ..indices,
  it,
) = _process(handout, opaque, updater, hider, indices.pos(), from, it)

// Include `it` on all given subslide indices and/or from given index.
// Subslide indices start at 1.
// See `_process` for the other parameters.
#let only(
  from: none,
  handout: auto,
  opaque: true,
  updater: update-subslide-count,
  hider: it => none,
  ..indices,
  it,
) = _process(handout, opaque, updater, hider, indices.pos(), from, it)

// Generate subslides with number of steps given explicitly
#let _subslides-explicit(steps, freeze, it) = {
  for i in range(0, steps) {
    _subslide(i, freeze, it)
  }
}

// Generate subslides with number of steps derived from the subslide counter.
// This requires an up-to-date subslide counter (see `slide`).
#let _subslides-auto(freeze, it) = {
  // Each slide is shown at least once
  _subslide(0, freeze, it)
  // After showing slide once, _subslide-count holds the number of subslides
  context {
    let n = _subslide-count.get().first()
    for i in range(1, n) {
      _subslide(i, freeze, it)
    }
  }
}

// Make `steps` subslides. If `steps` is `auto`, the number
// of subslides is determined automatically by updating a state (this requires
// that `uncover` and `only` are configured with a valid updater callback,
// and that they are called from a place where the update can be inserted).
// If `handout` is `true`, dynamic features are disabled: all slide content is
// shown in a single subslide. If `auto`, the value is taken as `true` if
// `--input handout=true` is passed on the command line, `false` otherwise.
#let subslides(handout: auto, steps: auto, freeze: auto, it) = {
  if _is-handout(handout) {
    return pagebreak(weak: true) + it
  }
  _subslide-count.update((1, 0))
  if steps == auto {
    _subslides-auto(freeze, it)
  } else {
    _subslides-explicit(steps, freeze, it)
  }
}
