extends CharacterBody2D
## Placeholder player character.
##
## Drawn in code (no image files needed) so the prototype runs with zero
## art assets. To swap in real art later: replace the body of _draw() with
## a Sprite2D/AnimatedSprite2D child, but keep its visual origin at the
## character's *feet* (roughly y=0 here) -- Y-sort depends on that.

const SPEED := 220.0

var body_color := Color(0.95, 0.55, 0.2)

func _physics_process(_delta: float) -> void:
	# Don't move the character while the player is typing in chat.
	if get_viewport().gui_get_focus_owner() != null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1

	velocity = direction.normalized() * SPEED
	move_and_slide()
	queue_redraw()

func set_body_color(new_color: Color) -> void:
	body_color = new_color
	queue_redraw()

func _draw() -> void:
	# Soft shadow at the feet -- this point (the node origin) is what Y-sort
	# uses to decide what draws in front of / behind what.
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 14, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Body + head, stacked upward from the feet.
	draw_rect(Rect2(-14, -26, 28, 26), body_color.darkened(0.15), true)
	draw_circle(Vector2(0, -34), 16, body_color)
