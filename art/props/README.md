# Props (walk-behind scenery)

Drop individual scenery images here, e.g. `tree_pine.png`, `rock_01.png`.

- Format: PNG with transparency (alpha channel)
- One object per file, not a spritesheet/atlas
- Crop tight, with **no empty transparent space below the object's base**
  — the bottom row of visible pixels should be exactly where the object
  touches the ground. This point is used to line up depth-sorting
  (whether the player draws in front of or behind it), so padding here
  will throw off the alignment.
- Any reasonable size is fine (a few hundred px tall is plenty).
