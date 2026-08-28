extends StaticBody2D
## Placeholder "walk behind me" scenery object.
##
## Any object dropped into the World Y-sort group will automatically draw
## in front of or behind the player based on vertical position -- that's
## the whole trick behind the Animal Jam Classic-style occlusion.

@export var trunk_color := Color(0.45, 0.3, 0.15)
@export var leaf_color := Color(0.2, 0.5, 0.25)

func _draw() -> void:
	draw_set_transform(Vector2(0, 4), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 20, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_rect(Rect2(-6, -50, 12, 50), trunk_color, true)
	draw_circle(Vector2(0, -70), 34, leaf_color)
