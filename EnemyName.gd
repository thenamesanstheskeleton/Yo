extends Button

# =====================================================
#  EnemyName.gd
#  Attach to: EnemyNameBtn (Button)
#  Path: res://scripts/battle/EnemyName.gd
# =====================================================

signal enemy_name_pressed

func _ready() -> void:
	flat = true
	add_theme_color_override("font_color",        Color.WHITE)
	add_theme_color_override("font_hover_color",  Color.YELLOW)
	add_theme_color_override("font_focus_color",  Color.YELLOW)
	add_theme_font_size_override("font_size", 22)
	pressed.connect(_on_pressed)

# Call this to set the enemy name text
# e.g. set_enemy_name("Greater Dog")
func set_enemy_name(enemy_name: String) -> void:
	text = "* " + enemy_name

func _on_pressed() -> void:
	emit_signal("enemy_name_pressed")
