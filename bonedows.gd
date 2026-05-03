extends Control

# =====================================================
#  bonedows.gd  —  Bonedows OS Brain
#  Viewport: 1280 × 720  (16:9 desktop mode)
#
#  Real asset paths (confirmed from project tree):
#    Icons    → res://assets/images/Bonedows/icons/
#    Wallpaper→ res://assets/images/Bonedows/wallpaper/bonedows_wallpaper.jpg
#    Audio    → res://assets/audio/bonedows/
#    Fonts    → res://assets/fonts/
#
#  Save flags written to SavM.data:
#    "earned_g"           → bool  (quiz completed + G deposited)
#    "bonedows_opened"    → bool  (player has ever opened Bonedows)
#
#  Signals:
#    bonedows_closed → Chapter2.gd resumes VNEngine
# =====================================================

signal bonedows_closed

# ── Asset paths ────────────────────────────────────────
const ICONS  = "res://assets/images/Bonedows/icons/"
const WP     = "res://assets/images/Bonedows/wallpaper/bonedows_wallpaper.jpg"
const SND    = "res://assets/audio/bonedows/"
const FONT   = "res://assets/fonts/DTM-Sans.otf"
const MONO   = "res://assets/fonts/DTM-Mono.otf"

# ── App paths ──────────────────────────────────────────
const APP_QUIZ   = "res://scenes/Bonedows/bonedows_apps/quiz_app.tscn"
const APP_MAIL   = "res://scenes/Bonedows/bonedows_apps/mail_app.tscn"
const APP_FILES  = "res://scenes/Bonedows/bonedows_apps/files_app.tscn"
const APP_SECRET = "res://scenes/Bonedows/bonedows_apps/very_secret_app.tscn"

# ── Node refs ─────────────────────────────────────────
@onready var wallpaper     : TextureRect     = $Wallpaper
@onready var desktop       : Control         = $Desktop
@onready var icon_grid     : VBoxContainer   = $Desktop/IconGrid
@onready var app_layer     : Control         = $AppLayer
@onready var top_bar       : Panel           = $TopBar
@onready var clock_label   : Label           = $TopBar/ClockLabel
@onready var exit_btn      : Button          = $Taskbar/ExitButton
@onready var boot_screen   : ColorRect       = $BootScreen
@onready var boot_label    : RichTextLabel   = $BootScreen/BootLabel
@onready var taskbar       : Panel           = $Taskbar
@onready var taskbar_label : Label           = $Taskbar/ActiveAppLabel
@onready var os_label      : Label           = $TopBar/OSLabel
@onready var label_quiz    : Label           = $Desktop/IconGrid/IconRow_Quiz/Label_Quiz
@onready var label_mail    : Label           = $Desktop/IconGrid/IconRow_Mail/Label_Mail
@onready var label_files   : Label           = $Desktop/IconGrid/IconRow_Files/Label_Files
@onready var label_secret  : Label           = $Desktop/IconGrid/IconRow_Secret/Label_Secret

# ── Icon buttons ───────────────────────────────────────
var _icon_quiz   : TextureButton = null
var _icon_mail   : TextureButton = null
var _icon_files  : TextureButton = null
var _icon_secret : TextureButton = null

# ── State ─────────────────────────────────────────────
var _current_app  : Node   = null
var _app_open     : bool   = false
var _clock_timer  : float  = 0.0
var _quiz_done    : bool   = false


# =====================================================
#  READY
# =====================================================
func _ready() -> void:
	# Read save flags from SavM
	var sav = get_node_or_null("/root/SavM")
	if sav:
		_quiz_done = sav.data.get("earned_g", false)
		# Mark that Bonedows has been opened at least once
		sav.data["bonedows_opened"] = true

	# Load wallpaper
	var wp_tex = load(WP)
	if wp_tex:
		wallpaper.texture = wp_tex

	# Hide layers until boot finishes
	desktop.hide()
	app_layer.hide()
	taskbar.hide()
	exit_btn.hide()

	# Wire icon buttons
	_icon_quiz   = $Desktop/IconGrid/IconRow_Quiz/Icon_Quiz
	_icon_mail   = $Desktop/IconGrid/IconRow_Mail/Icon_Mail
	_icon_files  = $Desktop/IconGrid/IconRow_Files/Icon_Files
	_icon_secret = $Desktop/IconGrid/IconRow_Secret/Icon_Secret

	_set_icon_textures()
	_fix_touch_filters()

	_icon_quiz.pressed.connect(func():   _launch_app(APP_QUIZ,   "ALPHYS RESEARCH PORTAL",          "quiz"))
	_icon_mail.pressed.connect(func():   _launch_app(APP_MAIL,   "BONE MAIL",                       "mail"))
	_icon_files.pressed.connect(func():  _launch_app(APP_FILES,  "GREAT PAPYRUS FILES  [VERY PRIVATE]", "files"))
	_icon_secret.pressed.connect(func(): _launch_app(APP_SECRET, "PROJECT NYEHH HEH HEH",           "secret"))
	exit_btn.pressed.connect(_on_exit_pressed)

	_update_clock()
	_play_boot_sequence()


# =====================================================
#  MOBILE TOUCH FIX
#  All Control ancestors must NOT block input.
#  TextureButtons need MOUSE_FILTER_STOP.
#  Everything else should be PASS or IGNORE.
# =====================================================
func _fix_touch_filters() -> void:
	# Root and layout containers — let input through
	mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(desktop):
		desktop.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(icon_grid):
		icon_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(app_layer):
		app_layer.mouse_filter = Control.MOUSE_FILTER_PASS

	# Each icon row VBoxContainer — pass through
	for row_name in ["IconRow_Quiz", "IconRow_Mail", "IconRow_Files", "IconRow_Secret"]:
		var row = icon_grid.get_node_or_null(row_name)
		if row:
			row.mouse_filter = Control.MOUSE_FILTER_PASS

	# Icon buttons themselves — must STOP (they handle the touch)
	for btn in [_icon_quiz, _icon_mail, _icon_files, _icon_secret]:
		if is_instance_valid(btn):
			btn.mouse_filter = Control.MOUSE_FILTER_STOP

	# Labels — ignore (they sit on top of buttons visually, must not block)
	for lbl in [label_quiz, label_mail, label_files, label_secret]:
		if is_instance_valid(lbl):
			lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Wallpaper — ignore (background, must not eat input)
	if is_instance_valid(wallpaper):
		wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE


# =====================================================
#  ICON TEXTURES
# =====================================================
func _set_icon_textures() -> void:
	var icons := {
		"quiz":   ICONS + "quiz_icon.png",
		"mail":   ICONS + "mail_icon.png",
		"files":  ICONS + "hidden_folder_icon.png",
		"secret": ICONS + "very_secret_icon.png",
	}
	for key in icons:
		var tex = load(icons[key])
		if tex == null:
			continue
		match key:
			"quiz":   _icon_quiz.texture_normal   = tex
			"mail":   _icon_mail.texture_normal   = tex
			"files":  _icon_files.texture_normal  = tex
			"secret": _icon_secret.texture_normal = tex

	# Green tint on quiz icon if already completed
	if _quiz_done and is_instance_valid(_icon_quiz):
		_icon_quiz.modulate = Color(0.6, 1.0, 0.6, 1.0)


# =====================================================
#  CLOCK
# =====================================================
func _process(delta: float) -> void:
	_clock_timer += delta
	if _clock_timer >= 1.0:
		_clock_timer = 0.0
		_update_clock()


func _update_clock() -> void:
	var t    := Time.get_time_dict_from_system()
	var h    : int = t["hour"]
	var m    : int = t["minute"]
	var ampm := "AM" if h < 12 else "PM"
	if h == 0:    h = 12
	elif h > 12:  h -= 12
	if is_instance_valid(clock_label):
		clock_label.text = "%d:%02d %s" % [h, m, ampm]


# =====================================================
#  BOOT SEQUENCE
# =====================================================
func _play_boot_sequence() -> void:
	boot_screen.show()
	boot_label.text = ""

	var lines := [
		"[color=#00ff44]BONEDOWS OS  v1.0[/color]",
		"[color=#00ff44]Developed by: THE GREAT PAPYRUS[/color]",
		"[color=#888888]Copyright © The Great Papyrus. All rights reserved.[/color]",
		"",
		"[color=#cccccc]Loading skeleton modules.......... [color=#00ff44]OK[/color][/color]",
		"[color=#cccccc]Initializing bone drivers......... [color=#00ff44]OK[/color][/color]",
		"[color=#cccccc]Checking spaghetti integrity...... [color=#00ff44]OK[/color][/color]",
		"[color=#cccccc]Mounting puzzle filesystem........ [color=#00ff44]OK[/color][/color]",
		"[color=#cccccc]Starting Nyeh-Heh services........ [color=#00ff44]OK[/color][/color]",
		"",
		"[color=#ffdd55][b]BOOT COMPLETE. NYEH HEH HEH.[/b][/color]",
	]

	for line in lines:
		boot_label.text += line + "\n"
		await get_tree().create_timer(0.22).timeout

	_play_snd("Windows Logon Sound.wav")
	await get_tree().create_timer(1.0).timeout

	var tw := create_tween()
	tw.tween_property(boot_screen, "modulate:a", 0.0, 0.5)
	await tw.finished
	boot_screen.hide()
	boot_screen.modulate.a = 1.0

	desktop.show()
	top_bar.show()
	taskbar.show()
	exit_btn.show()

	_set_icon_textures()
	_fix_touch_filters()


# =====================================================
#  APP LAUNCH
# =====================================================
func _launch_app(scene_path: String, app_name: String, _app_key: String) -> void:
	if _app_open:
		_play_snd("Windows Error.wav")
		return

	_play_snd("Windows Ding.wav")
	await get_tree().create_timer(0.12).timeout

	var scene = load(scene_path)
	if scene == null:
		_play_snd("Windows Error.wav")
		push_error("Bonedows: app scene not found: " + scene_path)
		return

	_current_app = scene.instantiate()
	app_layer.add_child(_current_app)
	app_layer.show()
	desktop.hide()

	if _current_app.has_signal("app_closed"):
		_current_app.app_closed.connect(_on_app_closed)

	# Pass quiz completion state if the app wants it
	if _current_app.has_method("set_already_completed"):
		_current_app.set_already_completed(_quiz_done)

	_app_open = true
	taskbar_label.text = "  " + app_name

	_play_snd("Windows Notify.wav")


func _on_app_closed(result: Dictionary) -> void:
	_play_snd("Windows Ding.wav")

	# Write G earned flag to SavM
	if result.get("g_earned", false) and not _quiz_done:
		_quiz_done = true
		var sav = get_node_or_null("/root/SavM")
		if sav:
			sav.data["earned_g"] = true

	if is_instance_valid(_current_app):
		_current_app.queue_free()
	_current_app = null
	_app_open    = false

	app_layer.hide()
	desktop.show()
	taskbar_label.text = "  Desktop"

	_set_icon_textures()
	_fix_touch_filters()


# =====================================================
#  EXIT
# =====================================================
func _on_exit_pressed() -> void:
	_play_snd("Windows Logoff Sound.wav")

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var tw := create_tween()
	tw.tween_property(overlay, "color:a", 1.0, 0.7)
	await tw.finished

	bonedows_closed.emit()


# =====================================================
#  AUDIO HELPER
# =====================================================
func _play_snd(filename: String) -> void:
	var audio = get_node_or_null("/root/AudioM")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx(SND + filename)
