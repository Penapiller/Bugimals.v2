extends CharacterBody2D
## Player character: 2D movement/collision as before, but the visible
## sprite is now a real-time render of the 3D model (see SubViewport in
## Player.tscn), composited on top like a normal 2D sprite.
##
## The model's own coordinate scale is unknown/tiny (Blockbench exports
## are often a fraction of a meter), so on startup this measures the
## model's actual size and scales/repositions it to a known world height
## instead of guessing a fixed number.

const SPEED := 220.0

## World-space height (in the SubViewport's 3D scene) the model is
## auto-scaled to. Paired with Camera3D.size in Player.tscn -- if you
## change one, the other likely needs a matching tweak.
@export var target_height_m := 1.6

## If set above 0, skips auto-scaling and uses this scale directly.
@export var manual_scale_override := 0.0

## The rendered character is unlikely to be pixel-perfect on the first
## run (there's no way to preview a 3D render without opening the editor)
## -- nudge this if the model faces the wrong way when walking.
@export var facing_offset_degrees := 0.0

var body_tint := Color.WHITE

@onready var viewport_sprite: Sprite2D = $Sprite2D
@onready var character_viewport: SubViewport = $SubViewport
@onready var character_rig: Node3D = $SubViewport/CharacterRig
@onready var anim_player: AnimationPlayer = _find_animation_player(character_rig)

func _ready() -> void:
	viewport_sprite.texture = character_viewport.get_texture()
	_fit_character_scale()
	_play_animation("Idol Animation ")

func _physics_process(_delta: float) -> void:
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

	if direction != Vector2.ZERO:
		var facing_angle := atan2(direction.x, direction.y)
		character_rig.rotation.y = facing_angle + deg_to_rad(facing_offset_degrees)
		_play_animation("Walk")
	else:
		_play_animation("Idol Animation ")

func set_body_color(new_color: Color) -> void:
	# Placeholder customization: tints the whole rendered character.
	# Once the model has separate materials per part (skin/shirt/etc.),
	# this should target those materials individually instead.
	body_tint = new_color
	viewport_sprite.modulate = new_color

func _play_animation(anim_name: String) -> void:
	if anim_player and anim_player.has_animation(anim_name) and anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _fit_character_scale() -> void:
	if manual_scale_override > 0.0:
		character_rig.scale = Vector3.ONE * manual_scale_override
		return

	var aabb := _measure_model_aabb()
	if aabb.size.y <= 0.0001:
		push_warning("Player: couldn't measure model size, using a fallback scale.")
		character_rig.scale = Vector3.ONE * 20.0
		return

	var scale_factor := target_height_m / aabb.size.y
	character_rig.scale = Vector3.ONE * scale_factor
	# Drop the model so its lowest point sits at y=0 (the ground).
	character_rig.position.y = -aabb.position.y * scale_factor

func _measure_model_aabb() -> AABB:
	var state := {"combined": AABB(), "has_any": false}
	_accumulate_aabb(character_rig, character_rig, state)
	return state["combined"]

func _accumulate_aabb(root: Node3D, node: Node, state: Dictionary) -> void:
	for child in node.get_children():
		if child is VisualInstance3D:
			var relative_transform: Transform3D = root.global_transform.affine_inverse() * child.global_transform
			var world_aabb: AABB = _transform_aabb(child.get_aabb(), relative_transform)
			if state["has_any"]:
				state["combined"] = state["combined"].merge(world_aabb)
			else:
				state["combined"] = world_aabb
				state["has_any"] = true
		_accumulate_aabb(root, child, state)

func _transform_aabb(local_aabb: AABB, transform: Transform3D) -> AABB:
	var result := AABB()
	var first := true
	for i in range(8):
		var corner: Vector3 = local_aabb.position + Vector3(
			local_aabb.size.x * (i & 1),
			local_aabb.size.y * ((i >> 1) & 1),
			local_aabb.size.z * ((i >> 2) & 1)
		)
		var world_corner: Vector3 = transform * corner
		if first:
			result = AABB(world_corner, Vector3.ZERO)
			first = false
		else:
			result = result.expand(world_corner)
	return result
