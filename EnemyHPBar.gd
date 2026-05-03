extends Control

# =====================================================
#  EnemyHPBar.gd
#  Attach to: EnemyHPBarRoot (Control)
#  Path: res://scripts/battle/EnemyHPBar.gd
# =====================================================

@onready var red_bar   : ColorRect = $RedBar
@onready var green_bar : ColorRect = $GreenBar

const PIXELS_PER_HP : float = 2.0  # 1 HP = 2px wide

var _tween : Tween = null

func _ready() -> void:
	red_bar.color   = Color(0.6, 0.0, 0.0, 1.0)   # dark red
	green_bar.color = Color(0.2, 0.9, 0.2, 1.0)   # bright green

# ─────────────────────────────────────────
#  Call this on battle start
#  Sets full bar width based on max HP
# ─────────────────────────────────────────
func setup(current_hp: int, max_hp: int) -> void:
	var full_width : float = max_hp * PIXELS_PER_HP
	red_bar.size.x         = full_width
	green_bar.size.x       = current_hp * PIXELS_PER_HP
	red_bar.size.y         = 16
	green_bar.size.y       = 16

# ─────────────────────────────────────────
#  Call this when enemy takes damage
#  Smoothly shrinks green bar
# ─────────────────────────────────────────
func update_hp(current_hp: int, max_hp: int) -> void:
	var target_width : float = current_hp * PIXELS_PER_HP

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(green_bar, "size:x", target_width, 0.3).set_trans(Tween.TRANS_SINE)
