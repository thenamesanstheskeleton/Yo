extends Node

# =====================================================
#  AudioM.gd  (AudioManager)
#  Autoload: AudioM="*res://scripts/AudioM.gd"
#  Handles: BGM crossfade, SFX (+volume), voice blips
#
#  FIXES vs old version:
#  ✅ Added fade_out_bgm(duration)   — was missing
#  ✅ Added reset_voice_timer()      — was missing
#  ✅ play_sfx() now accepts optional vol param
#  ✅ Added ambient_* for wind/rain on main menu
# =====================================================

# ── VOLUME DEFAULTS ───────────────────────────────────
var bgm_volume    : float = -6.0
var sfx_volume    : float =  0.0
var voice_volume  : float = -3.0
var ambient_volume: float = -8.0

# ── CROSSFADE DURATION ────────────────────────────────
const FADE_TIME : float = 1.2

# ── CURRENT BGM TRACKING ─────────────────────────────
var _current_bgm_path : String = ""

# ── VOICE COOLDOWN ────────────────────────────────────
const VOICE_COOLDOWN : float = 0.055
var _voice_timer     : float = 0.0

# ── NODES ─────────────────────────────────────────────
var _bgm_a      : AudioStreamPlayer
var _bgm_b      : AudioStreamPlayer
var _bgm_active : bool = true
var _sfx        : AudioStreamPlayer
var _voice      : AudioStreamPlayer
var _ambient    : AudioStreamPlayer   # ← NEW: for wind/rain ambience

# ── CHARACTER → BLIP MAP ──────────────────────────────
const VOICE_MAP : Dictionary = {
	"Sans"     : "res://assets/audio/sfx/sans_voice.mp3",
	"Papyrus"  : "res://assets/audio/voice/papyrus.wav",
	"Undyne"   : "res://assets/audio/voice/undyne1.wav",
	"Mettaton" : "res://assets/audio/voice/mettaton.mp3",
	"???"      : "res://assets/audio/voice/blip_default.ogg",
}
const DEFAULT_BLIP : String = "res://assets/audio/voice/blip_default.ogg"


# =====================================================
#  _ready
# =====================================================
func _ready() -> void:
	_bgm_a = AudioStreamPlayer.new()
	_bgm_a.name = "BGM_A"
	_bgm_a.volume_db = bgm_volume
	add_child(_bgm_a)

	_bgm_b = AudioStreamPlayer.new()
	_bgm_b.name = "BGM_B"
	_bgm_b.volume_db = -80.0
	add_child(_bgm_b)

	_sfx = AudioStreamPlayer.new()
	_sfx.name = "SFX"
	_sfx.volume_db = sfx_volume
	add_child(_sfx)

	_voice = AudioStreamPlayer.new()
	_voice.name = "Voice"
	_voice.volume_db = voice_volume
	add_child(_voice)

	_ambient = AudioStreamPlayer.new()
	_ambient.name = "Ambient"
	_ambient.volume_db = -80.0
	_ambient.bus = "Ambient" if AudioServer.get_bus_index("Ambient") >= 0 else "Master"
	add_child(_ambient)


# =====================================================
#  _process — voice cooldown
# =====================================================
func _process(delta: float) -> void:
	if _voice_timer > 0.0:
		_voice_timer -= delta


# =====================================================
#  BGM
# =====================================================

func play_bgm(path: String) -> void:
	if path == _current_bgm_path:
		return
	if path == "":
		stop_bgm()
		return

	_current_bgm_path = path
	var stream = load(path)
	if not stream:
		push_error("AudioM: BGM not found → " + path)
		return
	if _bgm_a == null or _bgm_b == null:
		push_error("AudioM: BGM players not initialized!")
		return

	var incoming : AudioStreamPlayer = _bgm_b if _bgm_active else _bgm_a
	var outgoing : AudioStreamPlayer = _bgm_a if _bgm_active else _bgm_b
	_bgm_active = !_bgm_active

	incoming.stream = stream
	incoming.volume_db = -80.0
	incoming.play()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(incoming, "volume_db", bgm_volume, FADE_TIME)
	tween.tween_property(outgoing, "volume_db", -80.0,      FADE_TIME)
	tween.tween_callback(outgoing.stop).set_delay(FADE_TIME)


func stop_bgm() -> void:
	_current_bgm_path = ""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_bgm_a, "volume_db", -80.0, FADE_TIME)
	tween.tween_property(_bgm_b, "volume_db", -80.0, FADE_TIME)
	tween.tween_callback(_bgm_a.stop).set_delay(FADE_TIME)
	tween.tween_callback(_bgm_b.stop).set_delay(FADE_TIME)


# ✅ NEW — fade out BGM over given duration then stop
# Called by: MainMenu, Chapter1, VNEngine, NameInput
func fade_out_bgm(duration: float = 0.5) -> void:
	_current_bgm_path = ""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_bgm_a, "volume_db", -80.0, duration)
	tween.tween_property(_bgm_b, "volume_db", -80.0, duration)
	tween.tween_callback(_bgm_a.stop).set_delay(duration)
	tween.tween_callback(_bgm_b.stop).set_delay(duration)


func pause_bgm() -> void:
	_bgm_a.stream_paused = true
	_bgm_b.stream_paused = true


func resume_bgm() -> void:
	_bgm_a.stream_paused = false
	_bgm_b.stream_paused = false


# =====================================================
#  AMBIENT — for wind, rain etc. on main menu
# =====================================================

func play_ambient(path: String, vol_db: float = -8.0) -> void:
	if path == "": return
	var stream = load(path)
	if not stream: return
	_ambient.stream = stream
	_ambient.volume_db = -80.0
	_ambient.play()
	var tween = create_tween()
	tween.tween_property(_ambient, "volume_db", vol_db, 1.5)


func stop_ambient(fade: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(_ambient, "volume_db", -80.0, fade)
	tween.tween_callback(_ambient.stop).set_delay(fade)


# =====================================================
#  SFX — ✅ now accepts optional volume in dB
# =====================================================

# vol_db: override volume for this specific SFX
# default = sfx_volume (class-level setting)
func play_sfx(path: String, vol_db: float = -999.0) -> void:
	if path == "": return
	var stream = load(path)
	if not stream:
		push_error("AudioM: SFX not found → " + path)
		return
	_sfx.stream = stream
	# -999 = sentinel meaning "use default sfx_volume"
	_sfx.volume_db = sfx_volume if vol_db <= -999.0 else vol_db
	_sfx.play()


# ── SFX shortcuts ─────────────────────────────────────
func sfx_confirm()   -> void: play_sfx("res://assets/audio/sfx/menu_confirm.ogg")
func sfx_cancel()    -> void: play_sfx("res://assets/audio/sfx/menu_cancel.ogg")
func sfx_scroll()    -> void: play_sfx("res://assets/audio/sfx/menu_scroll.ogg")
func sfx_save()      -> void: play_sfx("res://assets/audio/sfx/save_point.wav")
func sfx_shortcut()  -> void: play_sfx("res://assets/audio/sfx/shortcut.wav")
func sfx_rimshot()   -> void: play_sfx("res://assets/audio/sfx/rimshot.mp3")
func sfx_notice()    -> void: play_sfx("res://assets/audio/sfx/notice.mp3")
func sfx_footsteps() -> void: play_sfx("res://assets/audio/sfx/footsteps.mp3")


# =====================================================
#  VOICE BLIPS
# =====================================================

func play_voice(character: String) -> void:
	if _voice_timer > 0.0: return
	_voice_timer = VOICE_COOLDOWN
	var path = VOICE_MAP.get(character) if VOICE_MAP.has(character) else DEFAULT_BLIP
	var stream = load(path)
	if not stream: return
	if _voice.stream != stream or not _voice.playing:
		_voice.stream = stream
	_voice.volume_db = voice_volume
	_voice.play()


func stop_voice() -> void:
	_voice.stop()


# ✅ NEW — resets voice cooldown timer
# Called by VNEngine on new dialogue page start
func reset_voice_timer() -> void:
	_voice_timer = 0.0


# =====================================================
#  VOLUME CONTROL (for settings menu)
# =====================================================

func set_bgm_volume(db: float) -> void:
	bgm_volume = db
	if _bgm_active: _bgm_a.volume_db = db
	else:           _bgm_b.volume_db = db


func set_sfx_volume(db: float) -> void:
	sfx_volume = db
	_sfx.volume_db = db


func set_voice_volume(db: float) -> void:
	voice_volume = db
	_voice.volume_db = db


func set_ambient_volume(db: float) -> void:
	ambient_volume = db
	_ambient.volume_db = db


# Convert 0.0–1.0 slider → dB (for settings UI)
static func linear_to_db(linear: float) -> float:
	if linear <= 0.0: return -80.0
	return 20.0 * log(linear) / log(10.0)
