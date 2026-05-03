extends Control

# =====================================================
#  MainMenu.gd — Dynamic Weather Main Menu
#  Atmosphere changes based on player's chapter/location
#
#  Weather modes:
#    "snow"     → gentle Snowdin snowfall (CPUParticles2D)
#    "blizzard" → snowstorm (particles HEAVY + blizzard sprite)
#    "rain"     → Waterfall rain (particles, blue tint)
#    "none"     → still/dark (Hotland / new game)
#
#  Spritesheet: assign blizzard_sprite.texture in editor
#  (8×8 grid, 64 frames — see blizzard spritesheet)
# =====================================================

# ── Node refs ────────────────────────────────────────
@onready var bg_overlay     : ColorRect       = $BgOverlay
@onready var bg_texture     : TextureRect     = $BgTexture
@onready var snow_particles : CPUParticles2D  = $WeatherLayer/SnowParticles
@onready var blizzard_spr   : Sprite2D        = $WeatherLayer/BlizzardSprite
@onready var blizzard_anim  : AnimationPlayer = $WeatherLayer/BlizzardSprite/BlizzardAnim
@onready var sans_sprite    : TextureRect     = $SansSprite
@onready var press_prompt   : Label           = $PressPrompt
@onready var menu_buttons   : VBoxContainer   = $MenuButtons
@onready var black_screen   : ColorRect       = $BlackScreenTransition
@onready var fade_anim      : AnimationPlayer = $BlackScreenTransition/AnimationPlayer
@onready var easter_timer   : Timer           = $EasterEggTrigger/Timer

@onready var btn_new_game   : Button = $MenuButtons/NewGameButton
@onready var btn_continue   : Button = $MenuButtons/ContinueButton
@onready var btn_gallery    : Button = $MenuButtons/GalleryButton
@onready var btn_settings   : Button = $MenuButtons/SettingsButton
@onready var btn_quit       : Button = $MenuButtons/QuitButton

# ── Location → weather mode ───────────────────────────
# chapter 0/1 = Snowdin (gentle snow)
# chapter 2    = Snowdin morning (gentle snow)
# chapter 3    = Waterfall (rain)
const CHAPTER_WEATHER := {
	0: "snow",
	1: "snow",
	2: "snow",
	3: "rain",
}

# ── Location → background overlay color ───────────────
const CHAPTER_BG_COLOR := {
	0: Color(0.04, 0.06, 0.12, 1.0),   # deep night blue — Snowdin
	1: Color(0.04, 0.06, 0.12, 1.0),
	2: Color(0.06, 0.07, 0.10, 1.0),   # slightly lighter — morning
	3: Color(0.02, 0.04, 0.10, 1.0),   # deep blue — Waterfall
}

# ── BGM map ───────────────────────────────────────────
const BGM_FIRST   : String = "res://assets/audio/bgm/main_menu.mp3"
const BGM_MAP := {
	"sans":    "res://assets/audio/bgm/sans_theme.mp3",
	"papyrus": "res://assets/audio/bgm/bonetrousle.mp3",
	"undyne":  "res://assets/audio/bgm/spear_of_justice.mp3",
	"toriel":  "res://assets/audio/bgm/memory.mp3",
	"default": "res://assets/audio/bgm/main_menu.mp3",
}

# ── Ambient wind path (assign if you have the file) ───
const WIND_AMBIENCE : String = "res://assets/Surface/audio/ambient/wind-_ambience_-undertale.ogg"

# ── Sprite map ────────────────────────────────────────
const SPRITE_MAP := {
	"sans":    "res://assets/images/characters/sans_merged/neutral.png",
	"toriel":  "res://assets/images/characters/toriel_new/toriel-neutral.png",
	"undyne":  "res://assets/images/characters/undyne_new/neutral.png",
	"papyrus": "res://assets/images/characters/papyrus_merged/neutral.png",
}

# ── State ─────────────────────────────────────────────
var _first_visit      : bool = true
var _is_transitioning : bool = false
var _current_weather  : String = "snow"


# =====================================================
func _ready() -> void:
	_load_save_state()
	_connect_buttons()
	_setup_easter_egg()
	menu_buttons.modulate.a = 0.0
	press_prompt.modulate.a = 0.0
	fade_anim.animation_finished.connect(_on_fade_in_done)


# =====================================================
#  SAVE STATE + WEATHER SETUP
# =====================================================
func _load_save_state() -> void:
	var chapter_id    : int    = 0
	var last_char     : String = "sans"
	var is_first_time : bool   = true

	if has_node("/root/SavM"):
		var sav = get_node("/root/SavM")
		if sav.load_save():
			is_first_time = false
			chapter_id = sav.data.get("chapter") if sav.data.has("chapter") else 1
			last_char  = sav.data.get("last_character") if sav.data.has("last_character") else "sans"

	_first_visit = is_first_time

	# ── Background overlay color ───────────────────────
	var bg_col : Color = CHAPTER_BG_COLOR[chapter_id] \
		if CHAPTER_BG_COLOR.has(chapter_id) else CHAPTER_BG_COLOR[0]
	bg_overlay.color = bg_col

	# ── Weather effect ─────────────────────────────────
	_current_weather = CHAPTER_WEATHER[chapter_id] \
		if CHAPTER_WEATHER.has(chapter_id) else "snow"
	_apply_weather(_current_weather)

	# ── Character sprite ───────────────────────────────
	var sprite_path : String = SPRITE_MAP[last_char] \
		if SPRITE_MAP.has(last_char) else SPRITE_MAP["sans"]
	var sprite_tex : Texture2D = load(sprite_path)
	if sprite_tex:
		sans_sprite.texture = sprite_tex

	# ── BGM ────────────────────────────────────────────
	if has_node("/root/AudioM"):
		var audio = get_node("/root/AudioM")
		var bgm_path : String = BGM_FIRST if is_first_time \
			else (BGM_MAP[last_char] if BGM_MAP.has(last_char) else BGM_MAP["default"])
		audio.play_bgm(bgm_path)

	# ── Button visibility based on save state ──────────
	# No save  → show New Game only
	# Has save → show Continue only (New Game hidden)
	var save_exists : bool = has_node("/root/SavSlots") and get_node("/root/SavSlots").has_any_save()
	btn_continue.visible = save_exists
	btn_new_game.visible = not save_exists


# =====================================================
#  WEATHER SYSTEM
# =====================================================
func _apply_weather(mode: String) -> void:
	# Reset all first
	snow_particles.emitting = false
	blizzard_spr.visible    = false
	if blizzard_anim.is_playing(): blizzard_anim.stop()

	match mode:
		"snow":
			_setup_gentle_snow()
			snow_particles.emitting = true

		"blizzard":
			_setup_blizzard_snow()
			snow_particles.emitting = true
			blizzard_spr.visible    = true
			if blizzard_anim.has_animation("Play"):
				blizzard_anim.play("Play")
			# Play wind ambience
			if has_node("/root/AudioM"):
				get_node("/root/AudioM").play_ambient(WIND_AMBIENCE, -12.0)

		"rain":
			_setup_rain()
			snow_particles.emitting = true

		"none":
			pass   # pure dark atmosphere


func _setup_gentle_snow() -> void:
	snow_particles.amount              = 80
	snow_particles.lifetime            = 8.0
	snow_particles.direction           = Vector2(0.15, 1.0)
	snow_particles.spread              = 15.0
	snow_particles.gravity             = Vector2(8.0, 35.0)
	snow_particles.initial_velocity_min= 20.0
	snow_particles.initial_velocity_max= 50.0
	snow_particles.scale_amount_min    = 2.0
	snow_particles.scale_amount_max    = 4.0
	snow_particles.color               = Color(1, 1, 1, 0.7)
	snow_particles.emission_shape      = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	# Covers full screen — set in _ready after viewport known
	var vp := get_viewport().get_visible_rect().size
	snow_particles.emission_rect_extents = Vector2(vp.x / 2.0 + 40, 2)
	snow_particles.position            = Vector2(vp.x / 2.0, -4)


func _setup_blizzard_snow() -> void:
	_setup_gentle_snow()
	# Heavier, faster, more horizontal
	snow_particles.amount              = 200
	snow_particles.lifetime            = 4.0
	snow_particles.direction           = Vector2(0.6, 1.0)
	snow_particles.spread              = 25.0
	snow_particles.gravity             = Vector2(60.0, 80.0)
	snow_particles.initial_velocity_min= 80.0
	snow_particles.initial_velocity_max= 180.0
	snow_particles.scale_amount_min    = 1.5
	snow_particles.scale_amount_max    = 5.0
	snow_particles.color               = Color(1, 1, 1, 0.55)


func _setup_rain() -> void:
	var vp := get_viewport().get_visible_rect().size
	snow_particles.amount              = 150
	snow_particles.lifetime            = 1.5
	snow_particles.direction           = Vector2(0.1, 1.0)
	snow_particles.spread              = 5.0
	snow_particles.gravity             = Vector2(10.0, 200.0)
	snow_particles.initial_velocity_min= 150.0
	snow_particles.initial_velocity_max= 250.0
	snow_particles.scale_amount_min    = 1.0
	snow_particles.scale_amount_max    = 2.0
	# Blue-tinted rain streaks
	snow_particles.color               = Color(0.7, 0.8, 1.0, 0.5)
	snow_particles.emission_shape      = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow_particles.emission_rect_extents = Vector2(vp.x / 2.0 + 40, 2)
	snow_particles.position            = Vector2(vp.x / 2.0, -4)


# ── Public — call from anywhere to trigger storm ───────
func trigger_blizzard() -> void:
	_apply_weather("blizzard")

func stop_blizzard() -> void:
	_apply_weather("snow")


# =====================================================
#  BUTTONS
# =====================================================
func _connect_buttons() -> void:
	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_gallery.pressed.connect(_on_gallery)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)


func _on_new_game() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	# Reset full save state — SavM data + all SavSlots
	if has_node("/root/SavM"):
		get_node("/root/SavM").reset()
	if has_node("/root/SavSlots"):
		var slots = get_node("/root/SavSlots")
		for i in slots.SLOT_COUNT:
			slots.delete_slot(i)
	_fade_to_scene("res://scenes/name_input.tscn")

func _on_continue() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	# Load the most recent save slot then go to chapter
	if has_node("/root/SavSlots"):
		var slots = get_node("/root/SavSlots")
		var slot_idx : int = slots.get_most_recent_slot()
		if slot_idx >= 0:
			slots.load_slot(slot_idx)
	# Now read chapter from SavM (freshly loaded)
	var ch : int = 1
	if has_node("/root/SavM"):
		var sav = get_node("/root/SavM")
		ch = sav.data.get("chapter", 1)
	# Guard: clamp to existing chapters only
	# Increase max as new chapter scenes get added
	ch = clampi(ch, 1, 2)
	_fade_to_scene("res://scenes/chapter%d.tscn" % ch)

func _on_gallery() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	_fade_to_scene("res://scenes/gallery.tscn")

func _on_settings() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	_fade_to_scene("res://scenes/settings.tscn")

func _on_quit() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	if has_node("/root/AudioM"):
		var audio = get_node("/root/AudioM")
		audio.fade_out_bgm(0.4)
		audio.stop_ambient(0.4)
	fade_anim.play("FadeOut")
	await fade_anim.animation_finished
	get_tree().quit()


# =====================================================
#  TRANSITION
# =====================================================
func _fade_to_scene(scene_path: String) -> void:
	if has_node("/root/AudioM"):
		var audio = get_node("/root/AudioM")
		audio.fade_out_bgm(0.5)
		audio.stop_ambient(0.5)
	fade_anim.play("FadeOut")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file(scene_path)


# =====================================================
#  FADE-IN DONE → reveal buttons
# =====================================================
func _on_fade_in_done(anim_name: String) -> void:
	if anim_name != "FadeIn": return
	var tween := create_tween().set_parallel(false)
	tween.tween_property(menu_buttons, "modulate:a", 1.0, 0.35)
	if _first_visit:
		press_prompt.visible = true
		tween.tween_property(press_prompt, "modulate:a", 1.0, 0.25)
	else:
		press_prompt.visible = false
	easter_timer.start()


# =====================================================
#  INPUT
# =====================================================
func _input(event: InputEvent) -> void:
	if _is_transitioning: return
	if not _first_visit:  return
	if event is InputEventScreenTouch or \
	   event is InputEventMouseButton or \
	   event is InputEventKey:
		_first_visit         = false
		press_prompt.visible = false
		_check_easter_egg_input(event)


# =====================================================
#  EASTER EGG
# =====================================================
var _tap_count     : int   = 0
var _tap_timer_acc : float = 0.0
const TAP_WINDOW  : float  = 2.0
const TAPS_NEEDED : int    = 5

func _setup_easter_egg() -> void:
	easter_timer.timeout.connect(_on_idle_easter_egg)

func _on_idle_easter_egg() -> void:
	if not has_node("/root/SavM"): return
	var sav = get_node("/root/SavM")
	var unlocked : bool = sav.data.get("bonedows_unlocked") \
		if sav.data.has("bonedows_unlocked") else false
	if unlocked:
		_fade_to_scene("res://scenes/Bonedows/bonedows.tscn")

func _check_easter_egg_input(_event: InputEvent) -> void:
	easter_timer.stop()
	easter_timer.start()
	_tap_timer_acc = 0.0
	_tap_count += 1
	if _tap_count >= TAPS_NEEDED:
		_tap_count = 0
		_trigger_secret()

func _process(delta: float) -> void:
	if _tap_count > 0:
		_tap_timer_acc += delta
		if _tap_timer_acc > TAP_WINDOW:
			_tap_count     = 0
			_tap_timer_acc = 0.0

func _trigger_secret() -> void:
	if not has_node("/root/SavM"): return
	var sav = get_node("/root/SavM")
	var unlocked : bool = sav.data.get("bonedows_unlocked") \
		if sav.data.has("bonedows_unlocked") else false
	if unlocked:
		_fade_to_scene("res://scenes/Bonedows/bonedows.tscn")


# =====================================================
#  UTIL
# =====================================================
# _has_save() removed — SavSlots.has_any_save() handles this now
# SavSlots tracks slot existence properly via saveslots.save
