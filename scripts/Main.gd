extends Node2D
## Wires up the prototype: local-only chat log and a color-swatch
## customization panel for the player character.
##
## Both panels are stubs -- chat only echoes to your own screen, and the
## color choice isn't saved anywhere. That's on purpose: this scene proves
## the UI/UX, and networking + persistence (see README) hook in later
## without changing this file's shape.

@onready var player: CharacterBody2D = $World/Player

var chat_log: RichTextLabel
var chat_input: LineEdit

const SWATCHES := [
	Color(0.95, 0.55, 0.2),
	Color(0.30, 0.60, 0.90),
	Color(0.85, 0.30, 0.55),
	Color(0.40, 0.80, 0.40),
	Color(0.90, 0.85, 0.20),
]

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	_build_chat_panel(ui)
	_build_customize_panel(ui)

func _build_chat_panel(ui: CanvasLayer) -> void:
	var chat_box := PanelContainer.new()
	chat_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	chat_box.position = Vector2(16, -180)
	chat_box.custom_minimum_size = Vector2(360, 164)
	ui.add_child(chat_box)

	var chat_vbox := VBoxContainer.new()
	chat_box.add_child(chat_vbox)

	chat_log = RichTextLabel.new()
	chat_log.custom_minimum_size = Vector2(340, 120)
	chat_log.bbcode_enabled = true
	chat_log.scroll_following = true
	chat_log.append_text("[i]Press Enter to chat (local-only for now).[/i]\n")
	chat_vbox.add_child(chat_log)

	chat_input = LineEdit.new()
	chat_input.placeholder_text = "Press Enter to chat..."
	chat_input.text_submitted.connect(_on_chat_submitted)
	chat_vbox.add_child(chat_input)

func _build_customize_panel(ui: CanvasLayer) -> void:
	var custom_box := PanelContainer.new()
	custom_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	custom_box.position = Vector2(-190, 16)
	custom_box.custom_minimum_size = Vector2(174, 64)
	ui.add_child(custom_box)

	var custom_vbox := VBoxContainer.new()
	custom_box.add_child(custom_vbox)

	var label := Label.new()
	label.text = "Customize"
	custom_vbox.add_child(label)

	var swatch_row := HBoxContainer.new()
	custom_vbox.add_child(swatch_row)

	for color in SWATCHES:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(28, 28)
		btn.self_modulate = color
		btn.pressed.connect(_on_swatch_pressed.bind(color))
		swatch_row.add_child(btn)

func _on_swatch_pressed(color: Color) -> void:
	player.set_body_color(color)

func _on_chat_submitted(text: String) -> void:
	chat_input.clear()
	chat_input.release_focus()
	var trimmed := text.strip_edges()
	if trimmed == "":
		return
	chat_log.append_text("[b]You:[/b] %s\n" % trimmed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if not chat_input.has_focus():
				chat_input.grab_focus()
				get_viewport().set_input_as_handled()
