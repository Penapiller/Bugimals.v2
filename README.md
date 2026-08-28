# Bugimals Prototype

A first playable prototype for a Ponytown/Animal Jam Classic-style game:
a walkable scene with objects you can go behind, a local chat box, and
basic character color customization. No multiplayer or accounts yet —
this is deliberately just the core feel of the game.

## 1. Install Godot (one-time, ~5 minutes)

1. Go to https://godotengine.org/download and download **Godot 4.3**
   (or newer 4.x), **Standard** build (not the ".NET" version — this
   project uses GDScript, not C#).
2. It's a single executable — no installer, just unzip and run it.

## 2. Open the project

1. Launch Godot. You'll see the **Project Manager**.
2. Click **Import**, browse to this folder, and select `project.godot`.
3. Click **Import & Edit**. The Godot editor opens with the project loaded.

## 3. Run it

Press **F5** (or the ▶ Play button, top-right). `scenes/Main.tscn` is
already set as the main scene, so it should just run.

**Controls:**
- **WASD** or **arrow keys** — move
- **Enter** — open the chat box, type, **Enter** again to send
- **Color swatches** (top-right) — click one to recolor your character

Walk your character behind/in front of the trees — that's the occlusion
effect doing its job.

**Heads up on the character's first run:** the model renders inside a
hidden 3D camera that gets composited onto your 2D character (see "How
the 3D character works" below). I set up the framing numbers by
calculation, but I have no way to actually render Godot's viewport myself
to check them — so on first launch the character's size, vertical
position, or facing direction may be a little off. That's expected, not
a bug. Three `@export` variables on `Player.gd` are the knobs to fix it —
select the Player node in `scenes/Player.tscn` and adjust them in the
Inspector (no code editing needed):
- **Target Height M** — how tall the model is scaled to (in the hidden
  3D scene). If the character looks too small/large relative to the
  trees, adjust this — but you'll likely also want to change `size` on
  the `Camera3D` node in the same scene to match (bigger height needs a
  bigger camera size to keep it framed).
- **Manual Scale Override** — set this above 0 to bypass the automatic
  sizing entirely and force an exact scale, if auto-sizing looks wrong.
- **Facing Offset Degrees** — if the character turns to face the wrong
  way when you move, nudge this in 90° steps until it's right.

If the character appears vertically misaligned (feet floating above the
shadow, or head cut off), the fix is in `scenes/Player.tscn`: nudge the
`Sprite2D` node's **Offset** (Y value), or the `Camera3D` node's
**Position**/**Size**.

## How it's built (so the "why" isn't a mystery)

```
project.godot        # engine/project settings (rendering mode, window size)
art/
  background/          # your background image
  character/            # your 3D model
  props/                  # walk-behind scenery images (not added yet)
scenes/
  Main.tscn           # the playable scene: background + world + player + trees
  Player.tscn          # the character (collision, camera, 3D render pipeline)
  Tree.tscn             # a reusable "walk behind me" scenery object (still a placeholder)
scripts/
  Main.gd              # builds the chat + customization UI, wires it up
  Player.gd            # movement, facing, animation, and the 3D-render-to-sprite setup
  Tree.gd               # draws the placeholder tree shape
```

**The trees are still code-drawn placeholders** (simple shapes via
`_draw()`) since no prop images have been added yet — see "Adding your
own art" below for the format once you have some.

## How the 3D character works

`scenes/Player.tscn` has a `SubViewport` node — think of it as an
invisible second screen that renders its own tiny 3D scene (your model +
a `Camera3D` + a light) to an image, every frame. A `Sprite2D` then just
displays that image, like any other 2D sprite. That's the entire trick
behind mixing a 3D character into a 2D game: the "3D" is real, it's just
rendered to a texture first instead of straight to your screen.

`Player.gd` also measures your model's actual size on startup and scales
it to a known height automatically — Blockbench/glTF exports are often
scaled to fractions of a meter, so hardcoding a scale number would have
been a guess. See the tuning notes above if the result needs adjusting.

**The walk-behind-scenery trick (Y-Sort):** In `Main.tscn`, the `World`
node has `y_sort_enabled = true`. Any Node2D you put inside it — the
player, a tree, a rock, a fence — automatically draws in front of or
behind its siblings based on which one is lower on screen (higher Y
value = "closer to the camera" = draws on top). That's the entire
mechanism behind Animal Jam Classic's "walk behind the tree" effect.
No per-object logic needed — just drop things into `World` and place them
where they should stand.

One rule to keep it looking right: each object's **script draws upward
from its own origin (0,0)**, and the origin represents its "feet"/base.
That's why `Player.gd` and `Tree.gd` draw everything at negative Y — the
node's actual `position` is the ground-contact point Y-sort compares.

## Adding your own art

**Background and character are already wired in** (`art/background/`,
`art/character/`). Still need: walk-behind scenery (trees, rocks, etc.)
— see `art/props/README.md` for the format. Once you upload some there,
here's the change to swap a `Tree` for real art:

1. Drag your image file (e.g. `tree_pine.png`) into the Godot editor's
   FileSystem dock — it'll be imported automatically.
2. Open `scenes/Tree.tscn`, add a child node of type **Sprite2D**.
3. Assign your image to its **Texture** property.
4. Position that Sprite2D so the *bottom* of the image sits at (0,0) —
   i.e. set its Y offset to roughly `-(image height / 2)`. That keeps the
   base at the node origin, which is what Y-sort needs.
5. Delete the `_draw()` body in `Tree.gd` (or leave it — the Sprite2D
   will just draw on top of it).

If you end up with several different props (tree, rock, bush...), it's
worth making one `Tree.tscn`-style scene per prop type rather than
reusing one scene for everything.

## Roadmap: what's deliberately not here yet

You said skip multiplayer/accounts for now, so here's where they'd plug
in later without restructuring what exists:

- **Multiplayer** — Godot has a built-in high-level multiplayer API
  (`MultiplayerSpawner`/`MultiplayerSynchronizer`) that's the standard
  way to sync player position/appearance/chat across clients. It needs a
  server to relay connections; for a browser game specifically, that
  means either Godot's WebSocket multiplayer peer, or a small relay
  service you host.
- **Web export** — this project is already configured with the
  **Compatibility** renderer (`gl_compatibility`), which is the renderer
  Godot 4 requires for HTML5/web export. When you're ready: **Project →
  Export → Add → Web**, export, and host the resulting files (e.g. on
  itch.io, or any static web host).
- **Accounts without storing passwords** — Godot doesn't include Google
  Sign-In itself, since it isn't a web framework. The usual pattern: use
  a backend auth service that supports "Sign in with Google" and hands
  your game a token — **Supabase Auth** or **Firebase Auth** are the two
  easiest for a solo/indie project (generous free tiers, both support
  Google OAuth out of the box, and both give you a database you can
  reuse for player inventories). Godot's `HTTPRequest` node calls their
  REST API directly — no password storage on your end, ever.
- **Inventories** — once you have an auth token, inventory is just rows
  in that same backend's database (Supabase/Firebase both include one),
  fetched with `HTTPRequest` on login.
- **Real character customization** — right now the color swatches just
  tint the whole rendered character (a placeholder effect). Proper
  customization (recoloring a shirt but not skin, swapping items) needs
  the model to have separate materials per part, which we can set up
  once you know what's customizable.

## If you get stuck

Godot's official docs are unusually good for beginners:
https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html
The "Your first 2D game" tutorial there covers the same concepts used
here (CharacterBody2D, `_physics_process`, scenes/nodes) in more depth.
