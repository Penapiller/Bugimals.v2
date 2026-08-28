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

## How it's built (so the "why" isn't a mystery)

```
project.godot        # engine/project settings (rendering mode, window size)
scenes/
  Main.tscn           # the playable scene: background + world + player + trees
  Player.tscn          # the character (collision shape + camera)
  Tree.tscn             # a reusable "walk behind me" scenery object
scripts/
  Main.gd              # builds the chat + customization UI, wires it up
  Player.gd            # movement, and draws the placeholder character
  Tree.gd               # draws the placeholder tree
```

**No image files.** Every visual (character, trees, shadows) is drawn
directly in GDScript with `_draw()` calls, so the prototype runs with zero
art assets. This is a placeholder — see "Adding your own art" below.

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

You said you can supply placeholder sprites — here's the smallest change
to use them:

1. Drag your image file (e.g. `character.png`) into the Godot editor's
   FileSystem dock (bottom-left) — it'll be imported automatically.
2. Open `scenes/Player.tscn`, add a child node of type **Sprite2D**
   (or **AnimatedSprite2D** if you have a walk-cycle spritesheet).
3. Assign your image to its **Texture** property.
4. Position that Sprite2D so the *bottom* of the image sits at (0,0) —
   i.e. set its Y offset to roughly `-(image height / 2)`. That keeps the
   feet at the node origin, which is what Y-sort needs.
5. Optionally delete the `_draw()` body in `Player.gd` (or leave it — the
   Sprite2D will just draw on top of it).

Same idea for `Tree.tscn`/`Tree.gd` for scenery.

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
- **3D character upgrade** — if you later want an actual 3D model instead
  of a flat sprite (closer to true Animal Jam Classic), the technique is
  a `SubViewport` containing a small 3D scene (character + camera),
  displayed as a texture on a `Sprite2D`/`TextureRect` in the 2D world.
  It's a bigger lift (rigging, animation, lighting) — worth doing once
  the 2D gameplay loop already feels right, not before.

## If you get stuck

Godot's official docs are unusually good for beginners:
https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html
The "Your first 2D game" tutorial there covers the same concepts used
here (CharacterBody2D, `_physics_process`, scenes/nodes) in more depth.
