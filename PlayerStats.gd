extends HBoxContainer

# =====================================================
#  PlayerStats.gd
#  Attach to: PlayerStatsRoot (HBoxContainer)
#  Path: res://scripts/battle/PlayerStats.gd
# =====================================================

@onready var name_label  : Label     = $NameLabel
@onready var lv_label    : Label     = $LVLabel
@onready var hp_label    : Label     = $HPLabel
@onready var red_bar     : ColorRect = $HPBarRoot/RedBar
@onready var yellow_bar  : ColorRect = $HPBarRoot/YellowBar
@onready var hp_value    : Label     = $HpValue

const PIXELS_PER_HP : float = 2.5  # 1 HP = 2.5px wide

var _tween : Tween = null

func _ready() -> void:
	red_bar.color    = Color(0.85, 0.1,  0.1,  1.0)   # red
	yellow_bar.color = Color(0.95, 0.85, 0.1,  1.0)   # yellow
	hp_label.text    = "HP"

# ─────────────────────────────────────────
#  Call this on battle start
# ─────────────────────────────────────────
func setup(p_name: String, p_lv: int, current_hp: int, max_hp: int) -> void:
	name_label.text = p_name
	lv_label.text   = "LV " + str(p_lv)

	var full_width : float = max_hp * PIXELS_PER_HP
	red_bar.size.x         = full_width
	red_bar.size.y         = 16
	yellow_bar.size.x      = current_hp * PIXELS_PER_HP
	yellow_bar.size.y      = 16
	hp_value.text          = "%d / %d" % [current_hp, max_hp]

# ─────────────────────────────────────────
#  Call this when player takes damage
#  Yellow shrinks first, red follows after
# ─────────────────────────────────────────
func update_hp(current_hp: int, max_hp: int) -> void:
	var target_width : float = current_hp * PIXELS_PER_HP

	if _tween and _tween.is_valid():
		_tween.kill()

	# Yellow bar shrinks immediately
	_tween = create_tween()
	_tween.tween_property(yellow_bar, "size:x", target_width, 0.25).set_trans(Tween.TRANS_SINE)

	# Red bar follows slightly after (shows the "damage" gap briefly)
	await get_tree().create_timer(0.3).timeout
	var t2 := create_tween()
	t2.tween_property(red_bar, "size:x", target_width, 0.4).set_trans(Tween.TRANS_SINE)

	hp_value.text = "%d / %d" % [current_hp, max_hp]

# ─────────────────────────────────────────
#  Call this on LV UP
#  Bar physically grows longer
# ─────────────────────────────────────────
func level_up(p_lv: int, new_hp: int, new_max_hp: int) -> void:
	lv_label.text = "LV " + str(p_lv)
	var full_width : float = new_max_hp * PIXELS_PER_HP
	red_bar.size.x    = full_width
	yellow_bar.size.x = new_hp * PIXELS_PER_HP
	hp_value.text     = "%d / %d" % [new_hp, new_max_hp]
