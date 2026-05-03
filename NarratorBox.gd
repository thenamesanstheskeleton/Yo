extends PanelContainer

# =====================================================
#  NarratorBox.gd (UPDATED)
#  Attach to: NarratorBox (PanelContainer)
#  Path: res://scripts/battle/NarratorBox.gd
# =====================================================

@onready var narrator_text    : RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/narratortext
@onready var choice_container : GridContainer = $MarginContainer/VBoxContainer/ChoiceContainer

const TYPEWRITER_SPEED : float = 0.03  # seconds per character

var _tween : Tween = null

# ─────────────────────────────────────────
#  PLAIN TEXT MODE
#  Call this to show normal dialogue
#  e.g. "* It's the Greater Dog."
# ─────────────────────────────────────────
func show_text(msg: String) -> void:
	choice_container.visible = false
	narrator_text.visible    = true
	narrator_text.text       = msg
	narrator_text.visible_ratio = 0.0

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(narrator_text, "visible_ratio", 1.0, len(msg) * TYPEWRITER_SPEED)

# Await this if you need to wait for typing to finish
func wait_for_text() -> void:
	if _tween and _tween.is_valid():
		await _tween.finished

# Skip typewriter instantly
func skip_text() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	narrator_text.visible_ratio = 1.0


# ─────────────────────────────────────────
#  CHOICE MODE — 2×2 GRID
#  Pass an array of strings like:
#  ["Check", "Pet", "Beckon", "Ignore"]
#  Returns the chosen string via signal
# ─────────────────────────────────────────
signal choice_made(option: String)

func show_choices(options: Array) -> void:
	narrator_text.visible    = false
	choice_container.visible = true

	# Ensure GridContainer is set to 2 columns
	choice_container.columns = 2

	# Clear old buttons
	for child in choice_container.get_children():
		child.queue_free()

	# Build new buttons — fills 2×2 grid
	for opt in options:
		var btn := Button.new()
		btn.text          = "* " + opt
		btn.flat          = true
		btn.custom_minimum_size = Vector2(150, 40)
		btn.add_theme_color_override("font_color",       Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.YELLOW)
		btn.add_theme_font_size_override("font_size", 22)
		choice_container.add_child(btn)
		btn.pressed.connect(func(): _on_choice_pressed(opt))

func _on_choice_pressed(option: String) -> void:
	emit_signal("choice_made", option)
