extends Control

@onready var shadow_label: Label = $ShadowLabel
@onready var main_label: Label = $MainLabel

@export var rise_speed: float = 90.0
@export var fade_time: float = 0.8
@export var drift_speed: float = 12.0

var _time: float = 0.0

func setup(amount: int) -> void:
	var text: String = str(amount)

	shadow_label.text = text
	main_label.text = text

	main_label.add_theme_color_override("font_color", Color(0.75, 0.05, 0.05))
	main_label.add_theme_constant_override("outline_size", 4)

	shadow_label.add_theme_color_override("font_color", Color(0.08, 0.0, 0.0))

	modulate.a = 1.0
	scale = Vector2.ONE
	_time = 0.0

func _process(delta: float) -> void:
	_time += delta

	position.y -= rise_speed * delta
	position.x += drift_speed * delta

	var t: float = clamp(_time / fade_time, 0.0, 1.0)

	modulate.a = 1.0 - t
	scale = Vector2.ONE * (1.0 + (0.12 * (1.0 - t)))

	if _time >= fade_time:
		queue_free()
