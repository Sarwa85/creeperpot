# TODO

## Optional

- [ ] **Support-free lid: 45° chamfer under the lid plate** (`creeperpot.scad:108`, `lid()`)
  - Problem: in print orientation the 66×66 mm lid plate overhangs the Ø56 mm insert
    (~5 mm at the sides, ~19 mm at the corners). Bambu Studio warns about a floating
    cantilever and the lid needs supports.
  - Idea: add a hollow 45° loft from the insert cylinder up to a 62×62 mm square
    (pot inner size, `pot_pocket_width()`) right under the lid plate. Only a 2 mm rim
    would remain, which prints fine without supports.
  - Fits inside the pot, so the lid fit and outer look stay unchanged.
  - Cost: ~16 mm of extra height under the plate (corner distance 31·√2 − 28 ≈ 15.8 mm),
    a bit more filament, and the chamfer hides part of the cup.
  - After the change: update the MakerWorld description (lid would no longer need supports).
