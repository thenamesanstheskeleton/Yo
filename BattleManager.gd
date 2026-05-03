extends Control

# =====================================================
#  BattleManager.gd (FULLY REFINED & ERROR-FREE)
#  Target Resolution: 1920x1080
# =====================================================

# ── Battle Box & Arena ──────────────────────────────
@onready var battle_box       : Control         = $UI/BattleBox
@onready var bullet_container : Node2D          = $UI/BattleBox/BoxVisual/ViewportContainer/SubViewport/Bulletcontainer
@onready var box_anim         : AnimationPlayer = $UI/BattleBox/BoxAnim
@onready var soul_node        : CharacterBody2D = $UI/BattleBox/BoxVisual/ViewportContainer/SubViewport/Soul

# ── UI Components ───────────────────────────────────
@onready var enemy_sprite     : Sprite2D        = $UI/EnemyLayer/EnemySprite
@onready var menu_row         : HBoxContainer   = $UI/MenuRow
@onready var fight_btn        : TextureButton   = $UI/MenuRow/FightBtn
@onready var act_btn          : TextureButton   = $UI/MenuRow/ActBtn
@onready var item_btn         : TextureButton   = $UI/MenuRow/ItemBtn
@onready var mercy_btn        : TextureButton   = $UI/MenuRow/MercyBtn
@onready var fight_meter      : Control         = $UI/FightMeter
@onready var act_submenu      : Control         = $UI/ActSubmenu

# ── New UI Scripts ──────────────────────────────────
@onready var narrator_box     : PanelContainer  = $UI/NarratorBox
@onready var enemy_name_btn   : PanelContainer = $UI/EnemyNameBtn
@onready var enemy_hp_bar     : Control         = $UI/EnemyHPBarRoot
@onready var player_stats     : HBoxContainer   = $UI/PlayerStatsRoot

# ── Selector Heart ──────────────────────────────────
# Now a child of MenuRow for hierarchy locking
@onready var menu_selector    : Sprite2D        = $UI/MenuRow/MenuSelector

# ── Enemy Data ──────────────────────────────────────
var enemy_name        : String = "Lesser Dog"
var enemy_hp          : int    = 20
var enemy_hp_max      : int    = 20
var enemy_at          : int    = 6
var enemy_df          : int    = 2
var enemy_xp          : int    = 50
var enemy_gold        : int    = 40
var enemy_flavor      : String = "* It's a dog."
var enemy_act_options : Array  = ["Check", "Pet", "Ignore"]
var can_spare         : bool   = false

# ── Player Data ─────────────────────────────────────
var player_hp      : int    = 20
var player_hp_max  : int    = 20
var player_at      : int    = 10
var player_lv      : int    = 1
var player_name    : String = "CHARA"

# ── State Machine ───────────────────────────────────
enum State { PLAYER_TURN, ENEMY_TURN, FIGHT_METER, ACT_MENU, RESULT }
var state : State = State.PLAYER_TURN

# ── Menu Navigation ─────────────────────────────────
var _menu_index   : int   = 0
var _menu_buttons : Array = []

# ── Box Tween ───────────────────────────────────────
var _box_tween : Tween = null

signal box_restored


# =====================================================
#  READY
# =====================================================
func _ready() -> void:
	_menu_buttons = [fight_btn, act_btn, item_btn, mercy_btn]

	fight_btn.pressed.connect(_on_fight_pressed)
	act_btn.pressed.connect(_on_act_pressed)
	item_btn.pressed.connect(_on_item_pressed)
	mercy_btn.pressed.connect(_on_mercy_pressed)

	# Soul starts hidden, selector starts visible
	soul_node.visible = false
	if menu_selector:
		menu_selector.visible = true

	_init_narrator_box()
	_init_enemy_name()
	_init_enemy_hp_bar()
	_init_player_stats()

	_set_state(State.PLAYER_TURN)


# =====================================================
#  UI INITIALIZATION
# =====================================================
func _init_narrator_box() -> void:
	if narrator_box and narrator_box.has_method("show_text"):
		narrator_box.show_text("* " + enemy_flavor)
		narrator_box.choice_made.connect(_on_narrator_choice)

func _init_enemy_name() -> void:
	if enemy_name_btn and enemy_name_btn.has_method("set_enemy_name"):
		enemy_name_btn.set_enemy_name(enemy_name)
		enemy_name_btn.enemy_name_pressed.connect(_on_enemy_name_pressed)

func _init_enemy_hp_bar() -> void:
	if enemy_hp_bar and enemy_hp_bar.has_method("setup"):
		enemy_hp_bar.setup(enemy_hp, enemy_hp_max)

func _init_player_stats() -> void:
	if player_stats and player_stats.has_method("setup"):
		player_stats.setup(player_name, player_lv, player_hp, player_hp_max)


# =====================================================
#  PROCESS (Navigation)
# =====================================================
func _process(_delta: float) -> void:
	if state == State.PLAYER_TURN:
		_handle_menu_navigation()

func _handle_menu_navigation() -> void:
	if Input.is_action_just_pressed("ui_left"):
		_menu_index = wrapi(_menu_index - 1, 0, 4)
		_update_selector()
	elif Input.is_action_just_pressed("ui_right"):
		_menu_index = wrapi(_menu_index + 1, 0, 4)
		_update_selector()
	elif Input.is_action_just_pressed("ui_accept"): # Z or Enter
		_activate_menu(_menu_index)

func _update_selector() -> void:
	if not menu_selector or _menu_buttons.is_empty():
		return
	var target = _menu_buttons[_menu_index]
	# Alignment: Heart to the left of the button
	menu_selector.global_position = target.global_position + Vector2(-30, target.size.y / 2)
func _on_button_focused(button: Button):
	# Calculate where the heart should go relative to the button
	# UT style: Heart sits to the left of the "*" or text
	var offset = Vector2(-25, button.size.y / 2)
	menu_selector.global_position = button.global_position + offset

# =====================================================
#  STATE MACHINE
# =====================================================
func _set_state(new_state: State) -> void:
	state = new_state

	match state:
		State.PLAYER_TURN:
			soul_node.visible = false
			if menu_selector: menu_selector.visible = true
			enemy_sprite.visible = true
			menu_row.visible = true
			narrator_box.visible = true
			fight_meter.visible = false
			_update_selector()
			_clear_bullets()
			if narrator_box:
				narrator_box.show_text("* " + enemy_flavor)

		State.ENEMY_TURN:
			menu_row.visible = false
			if menu_selector: menu_selector.visible = false
			soul_node.visible = true
			narrator_box.visible = true
			reset_soul_to_start()
			_clear_bullets()
			if narrator_box:
				narrator_box.show_text("")
			await get_tree().create_timer(0.8).timeout
			_set_state(State.PLAYER_TURN)

		State.FIGHT_METER:
			menu_row.visible = false
			if menu_selector: menu_selector.visible = false
			soul_node.visible = false
			narrator_box.visible = false
			enemy_sprite.visible = true
			fight_meter.visible = true
			_show_enemy_hp()

		State.ACT_MENU:
			menu_row.visible = false
			if menu_selector: menu_selector.visible = false
			soul_node.visible = false
			narrator_box.visible = true
			if narrator_box:
				narrator_box.show_choices(enemy_act_options)

		State.RESULT:
			menu_row.visible = false
			if menu_selector: menu_selector.visible = false
			soul_node.visible = false
			narrator_box.visible = true
			if narrator_box:
				narrator_box.show_text("* YOU WON!\n* You earned %d XP and %d gold." % [enemy_xp, enemy_gold])


# =====================================================
#  SOUL & LOGIC HELPERS
# =====================================================
func reset_soul_to_start() -> void:
	if soul_node:
		soul_node.position = Vector2(260, 190)
		soul_node.visible = true

func _on_narrator_choice(option: String) -> void:
	_do_act(option)

func _on_enemy_name_pressed() -> void:
	if state == State.PLAYER_TURN:
		_on_fight_pressed()

func _activate_menu(index: int) -> void:
	match index:
		0: _on_fight_pressed()
		1: _on_act_pressed()
		2: _on_item_pressed()
		3: _on_mercy_pressed()

func _on_fight_pressed() -> void:
	if state == State.PLAYER_TURN:
		_set_state(State.FIGHT_METER)

func _on_act_pressed() -> void:
	if state == State.PLAYER_TURN:
		_set_state(State.ACT_MENU)

func _on_item_pressed() -> void:
	if state == State.PLAYER_TURN:
		if narrator_box: narrator_box.show_text("* (No items yet.)")

func _on_mercy_pressed() -> void:
	if state == State.PLAYER_TURN:
		if can_spare:
			_set_state(State.RESULT)
		else:
			if narrator_box: narrator_box.show_text("* But it was unwilling to stop.")
			await get_tree().create_timer(1.2).timeout
			_set_state(State.ENEMY_TURN)

func _do_act(option: String) -> void:
	match option:
		"Check":
			if narrator_box: narrator_box.show_text("* %s\n* ATK %d  DEF %d\n* A very good dog." % [enemy_name, enemy_at, enemy_df])
		"Pet":
			if narrator_box: narrator_box.show_text("* You pet the " + enemy_name + ".\n* It wiggled its tail!")
			can_spare = true
	await get_tree().create_timer(1.2).timeout
	_set_state(State.ENEMY_TURN)

func on_fight_confirmed(multiplier: float) -> void:
	fight_meter.visible = false
	narrator_box.visible = true
	_apply_enemy_damage(multiplier)

func _apply_enemy_damage(multiplier: float) -> void:
	var scaled_offense: int = int(round(float(player_at + (player_lv * 2)) * multiplier))
	var real_dmg: int = max(1, scaled_offense - enemy_df)
	enemy_hp = max(0, enemy_hp - real_dmg)
	if enemy_hp_bar: enemy_hp_bar.update_hp(enemy_hp, enemy_hp_max)
	if enemy_hp <= 0: _enemy_die()
	else: _set_state(State.ENEMY_TURN)


func _show_enemy_hp() -> void:
	if enemy_hp_bar:
		enemy_hp_bar.visible = true
		enemy_hp_bar.setup(enemy_hp, enemy_hp_max)

func _clear_bullets() -> void:
	for child in bullet_container.get_children():
		child.queue_free()

func _enemy_die() -> void:
	var t := create_tween()
	t.tween_property(enemy_sprite, "modulate:a", 0.0, 0.8)
	await t.finished
	_set_state(State.RESULT)
func _shake_enemy():
	var tween = create_tween()
	var original_pos = enemy_sprite.position
	for i in range(4):
		tween.tween_property(enemy_sprite, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(enemy_sprite, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(enemy_sprite, "position", original_pos, 0.05)
	
