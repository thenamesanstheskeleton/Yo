extends Node

# =====================================================
#  VNEngine.gd — reusable dialogue component
#  Attach as child of any chapter scene
#
#  FIXES vs old version:
#  ✅ AudioM.play_sfx(src, vol) — vol now supported in AudioM
#  ✅ AudioM.fade_out_bgm() — now exists in AudioM
#  ✅ _tween_alpha guard for null nodes in choice restore
# =====================================================

@export var bg_rect          : TextureRect
@export var char_left        : TextureRect
@export var char_right       : TextureRect
@export var char_center      : TextureRect
@export var dialog_box       : ColorRect
@export var name_box         : ColorRect
@export var name_label       : Label
@export var dialog_text      : RichTextLabel
@export var next_arrow       : Label
@export var choice_container : VBoxContainer
@export var black_screen     : ColorRect
@export var fade_player      : AnimationPlayer

@onready var SavM   = get_node_or_null("/root/SavM")
@onready var AudioM = get_node_or_null("/root/AudioM")

var script_data : Dictionary = {}

var scene_key       : String = "start"
var step_index      : int    = 0
var is_typing       : bool   = false
var full_text       : String = ""
var shown_text      : String = ""
var type_timer      : float  = 0.0
var waiting         : bool   = false
var current_speaker : String = ""
var is_narration    : bool   = false

var _pages        : Array = []
var _current_page : int   = 0
const CHARS_PER_PAGE : int = 160

var choice_buttons : Array = []

const TYPE_SPEED  : float = 0.030
const NARR_SPEED  : float = 0.025
const SHAKE_EXPRS         = ["enchanted","angry","shook","scream","scared"]
const SHAKE_TEXTS         = ["!!","NYEH","!?"]

signal chapter_ended(next_chapter: int)
# Fired when an "event" step is hit — chapter scene handles it
# then calls engine.resume() to continue
signal chapter_event(event_id: String)

# ── Pause state for event steps ───────────────────────
var _is_paused : bool = false
var _scene_stack : Array = []


# =====================================================
#  PUBLIC API
# =====================================================
func load_chapter(data: Dictionary) -> void:
	script_data = data

func start(entry_key: String = "start") -> void:
	_scene_stack.clear()
	var saved : String = ""
	if SavM:
		saved = SavM.data.get("current_scene", "")
	_start_scene(saved if saved != "" else entry_key)

func jump_to(key: String) -> void:
	_scene_stack.clear()
	_start_scene(key)

func push_scene(key: String) -> void:
	# Save the current chapter position, then run a cutscene scene key.
	_scene_stack.append({
		"scene_key": scene_key,
		"step_index": step_index,
	})
	_start_scene(key)

func return_from_cutscene() -> void:
	if _scene_stack.is_empty():
		resume()
		return

	var prev : Dictionary = _scene_stack.pop_back()
	scene_key = prev.get("scene_key", "start")
	step_index = int(prev.get("step_index", 0)) + 1
	_is_paused = false
	if SavM:
		SavM.data["current_scene"] = scene_key
	_run_step()

# Called by the chapter scene after handling a chapter_event
func resume() -> void:
	if not _is_paused: return
	_is_paused  = false
	step_index += 1
	_run_step()


# =====================================================
#  SCENE RUNNER
# =====================================================
func _start_scene(key: String) -> void:
	scene_key  = key
	step_index = 0
	_is_paused = false
	if SavM: SavM.data["current_scene"] = key
	_clear_choices()
	_run_step()


func _run_step() -> void:
	_clear_choices()
	var steps : Array = script_data.get(scene_key, [])
	if step_index >= steps.size():
		return

	var step : Dictionary = steps[step_index]
	match step.get("type", ""):

		"scene":
			_do_scene(step)
			step_index += 1
			_run_step()

		"dialogue":
			_do_dialogue(step)

		"narration":
			_do_narration(step)

		"choice":
			_do_choice(step)

		"goto":
			_start_scene(step["goto"])

		"load_scene":
			var path : String = step.get("scene", "")
			if path != "": _fade_then_change(path)

		"sfx":
			# ✅ Fixed: AudioM.play_sfx now accepts optional vol_db
			if AudioM:
				var src : String = step.get("src", "")
				var vol : float  = step.get("vol", -999.0)
				AudioM.play_sfx(src, vol)
			step_index += 1
			_run_step()

		"relationship_hit":
			_do_relationship_hit(step)
			step_index += 1
			_run_step()

		"event":
			# Pause VNEngine — chapter scene handles this
			# then calls engine.resume() to continue
			_is_paused = true
			chapter_event.emit(step.get("id", ""))

		"ending":
			_do_ending(step)

		_:
			step_index += 1
			_run_step()


# =====================================================
#  STEP HANDLERS
# =====================================================
func _do_scene(step: Dictionary) -> void:
	var bg_path : String = step.get("bg", "")
	if bg_path != "" and bg_rect:
		var tex = load(bg_path)
		bg_rect.texture = tex if tex else null

	var bgm_path : String = step.get("bgm", "")
	if bgm_path != "" and AudioM:
		AudioM.play_bgm(bgm_path)

	var char_path   : String = step.get("char",       "")
	var char_l_path : String = step.get("char_left",  "")
	var char_r_path : String = step.get("char_right", "")

	if "char" in step:
		_set_center_char(char_path)
		_hide_dual_chars()
	if "char_left" in step or "char_right" in step:
		_set_dual_chars(char_l_path, char_r_path, "")
		if char_center: char_center.visible = false


func _do_dialogue(step: Dictionary) -> void:
	current_speaker = step.get("name", "")
	is_narration    = false

	if name_label:
		name_label.text    = current_speaker
		name_label.visible = current_speaker != ""
		name_label.add_theme_color_override("font_color", _speaker_color(current_speaker))
	if name_box:
		name_box.visible = current_speaker != ""

	var char_path   : String = step.get("char",       "")
	var char_l_path : String = step.get("char_left",  "")
	var char_r_path : String = step.get("char_right", "")

	if "char_left" in step or "char_right" in step:
		if char_center: char_center.visible = false
		_set_dual_chars(char_l_path, char_r_path, current_speaker)
	elif "char" in step and char_path != "":
		_hide_dual_chars()
		_set_center_char(char_path)

	_check_shake(step)
	if dialog_text:
		dialog_text.add_theme_color_override("default_color", Color.WHITE)
	_type_text(step.get("text", ""), false)


func _do_narration(step: Dictionary) -> void:
	current_speaker = ""
	is_narration    = true

	if name_label:  name_label.visible  = false
	if name_box:    name_box.visible    = false
	if char_center: char_center.visible = false
	_hide_dual_chars()

	if dialog_text:
		dialog_text.add_theme_color_override("default_color", Color(0.85, 0.85, 0.90))
	_type_text(step.get("text", ""), true)


func _do_choice(step: Dictionary) -> void:
	is_typing = false
	waiting   = false
	if next_arrow:  next_arrow.visible  = false
	if dialog_text: dialog_text.text    = ""
	if name_label:  name_label.visible  = false
	if name_box:    name_box.visible    = false

	const DIM : float = 0.45
	if char_center and char_center.visible: _tween_alpha(char_center, DIM)
	if char_left   and char_left.visible:   _tween_alpha(char_left,   DIM)
	if char_right  and char_right.visible:  _tween_alpha(char_right,  DIM)

	if not choice_container: return
	choice_container.visible = true

	var options : Array = step.get("options", [])
	# ── Dynamic sizing: fewer choices = bigger buttons ──────────
	var count      : int   = max(options.size(), 1)
	var btn_height : float = clamp(180.0 - (count - 1) * 22.0, 90.0, 180.0)
	var font_size  : int   = 48 if count <= 2 else (44 if count <= 3 else 40)

	for opt in options:
		if opt.get("type", "") == "separator":
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(0, 24)
			spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			choice_container.add_child(spacer)
			continue

		var btn := Button.new()
		btn.text = opt.get("text", "")
		btn.custom_minimum_size = Vector2(0, btn_height)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", font_size)
		btn.add_theme_color_override("font_color",         Color.WHITE)
		btn.add_theme_color_override("font_hover_color",   Color(1.0, 0.92, 0.2))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.2))

		var sb := StyleBoxFlat.new()
		sb.bg_color     = Color(0.0, 0.0, 0.0, 0.78)
		sb.border_color = Color(1.0, 1.0, 1.0, 0.45)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(0)
		sb.content_margin_left   = 28
		sb.content_margin_right  = 28
		sb.content_margin_top    = 14
		sb.content_margin_bottom = 14
		btn.add_theme_stylebox_override("normal", sb)

		var sb_h := StyleBoxFlat.new()
		sb_h.bg_color     = Color(0.10, 0.10, 0.10, 0.92)
		sb_h.border_color = Color(1.0, 0.92, 0.2, 1.0)
		sb_h.set_border_width_all(3)
		sb_h.set_corner_radius_all(0)
		sb_h.content_margin_left   = 28
		sb_h.content_margin_right  = 28
		sb_h.content_margin_top    = 14
		sb_h.content_margin_bottom = 14
		btn.add_theme_stylebox_override("hover",   sb_h)
		btn.add_theme_stylebox_override("pressed", sb_h)

		var goto_key : String = opt.get("goto", "")
		btn.pressed.connect(func(): _on_choice_selected(goto_key))
		choice_container.add_child(btn)
		choice_buttons.append(btn)

		# Staggered fade-in per button ──────────────────────────
		btn.modulate.a = 0.0
		var delay : float = choice_buttons.size() * 0.08
		var t := create_tween()
		t.tween_interval(delay)
		t.tween_property(btn, "modulate:a", 1.0, 0.15)

	if choice_buttons.size() > 0:
		choice_buttons[0].grab_focus()


func _do_relationship_hit(step: Dictionary) -> void:
	if not SavM: return
	var char_name : String = step.get("char",   "")
	var amount    : int    = step.get("amount",  0)
	var strain    : int    = step.get("strain",  0)
	var flag      : String = step.get("flag",   "")
	if char_name != "": SavM.change_relationship(char_name, amount)
	if strain > 0:      SavM.strain_sans(strain)
	if flag != "":      SavM.set_harsh(flag)


func _do_ending(step: Dictionary) -> void:
	_scene_stack.clear()
	is_typing = false
	waiting   = false
	if next_arrow:  next_arrow.visible  = false
	if char_center: char_center.visible = false
	if name_label:  name_label.visible  = false
	if name_box:    name_box.visible    = false
	_hide_dual_chars()

	var title    : String = step.get("title",    "")
	var subtitle : String = step.get("subtitle", "")
	if dialog_text:
		dialog_text.bbcode_text = \
			"[center][b]" + title + "[/b]\n\n" + subtitle + "[/center]"

	var next_ch : int = 1
	if SavM:
		next_ch = SavM.data.get("chapter", 1) + 1
		SavM.data["chapter"]       = next_ch
		SavM.data["current_scene"] = "start"
		SavM.save()
	if AudioM: AudioM.sfx_save()

	await get_tree().create_timer(2.2).timeout
	chapter_ended.emit(next_ch)


# =====================================================
#  CHOICE SELECTED
# =====================================================
func _on_choice_selected(goto_key: String) -> void:
	if SavM: SavM.record_choice(scene_key + "_choice", goto_key)
	if AudioM: AudioM.sfx_confirm()

	# ✅ Guard: only tween if nodes are valid
	if is_instance_valid(char_center): _tween_alpha(char_center, 1.0)
	if is_instance_valid(char_left):   _tween_alpha(char_left,   1.0)
	if is_instance_valid(char_right):  _tween_alpha(char_right,  1.0)

	_clear_choices()
	_start_scene(goto_key)


func _clear_choices() -> void:
	for btn in choice_buttons:
		btn.queue_free()
	choice_buttons.clear()
	if choice_container: choice_container.visible = false


# =====================================================
#  TYPEWRITER
# =====================================================
func _type_text(text: String, narration: bool) -> void:
	var raw : String = "[i]" + text + "[/i]" if narration else text
	_pages        = _split_pages(raw)
	_current_page = 0
	_start_page()


func _split_pages(text: String) -> Array:
	var words   : PackedStringArray = text.split(" ")
	var pages   : Array  = []
	var current : String = ""
	for word in words:
		var test  : String = current + (" " if current != "" else "") + word
		var plain : String = test.replace("[i]","").replace("[/i]","") \
								 .replace("[b]","").replace("[/b]","")
		if plain.length() > CHARS_PER_PAGE and current != "":
			pages.append(current)
			current = word
		else:
			current = test
	if current != "":
		pages.append(current)
	return pages if pages.size() > 0 else [""]


func _start_page() -> void:
	full_text  = _pages[_current_page]
	shown_text = ""
	is_typing  = true
	waiting    = false
	type_timer = 0.0
	if next_arrow: next_arrow.visible = false
	if AudioM:
		AudioM.stop_voice()
		AudioM.reset_voice_timer()   # ✅ now exists
	if dialog_text: dialog_text.text = ""


# ── Page-reset: fade out text → clear → start next page ───────
func _page_reset_then_start() -> void:
	if not dialog_text: _start_page(); return
	var t := create_tween()
	t.tween_property(dialog_text, "modulate:a", 0.0, 0.10)
	t.tween_callback(func():
		dialog_text.modulate.a = 1.0
		_start_page()
	)

# ── Page-reset: fade out text → clear → advance to next step ──
func _page_reset_then_advance() -> void:
	if not dialog_text:
		step_index += 1
		_run_step()
		return
	var t := create_tween()
	t.tween_property(dialog_text, "modulate:a", 0.0, 0.10)
	t.tween_callback(func():
		dialog_text.modulate.a = 1.0
		step_index += 1
		_run_step()
	)


func _process(delta: float) -> void:
	if not is_typing: return
	type_timer += delta
	var speed : float = NARR_SPEED if is_narration else TYPE_SPEED
	if type_timer >= speed:
		type_timer = 0.0
		if shown_text.length() < full_text.length():
			shown_text += full_text[shown_text.length()]
			if dialog_text: dialog_text.bbcode_text = shown_text
			if not is_narration and current_speaker != "" and AudioM:
				AudioM.play_voice(current_speaker)
		else:
			is_typing = false
			waiting   = true
			if next_arrow: next_arrow.visible = true
			if AudioM:     AudioM.stop_voice()


# =====================================================
#  INPUT
# =====================================================
func _input(event: InputEvent) -> void:
	if choice_buttons.size() > 0: return

	var pressed : bool = false
	if event is InputEventScreenTouch and event.pressed:   pressed = true
	elif event is InputEventMouseButton and event.pressed: pressed = true
	elif event is InputEventKey and event.pressed:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_Z]: pressed = true

	if not pressed: return

	if is_typing:
		shown_text = full_text
		if dialog_text: dialog_text.bbcode_text = full_text
		is_typing = false
		waiting   = true
		if next_arrow: next_arrow.visible = true
		if AudioM:     AudioM.stop_voice()
		return

	if waiting:
		waiting = false
		if next_arrow: next_arrow.visible = false
		if _current_page < _pages.size() - 1:
			# More pages in this dialogue — reset animation then show next page
			_current_page += 1
			_page_reset_then_start()
		else:
			# Last page — advance to next step
			_page_reset_then_advance()


# =====================================================
#  CHARACTER SPRITE HELPERS
# =====================================================
func _set_center_char(path: String) -> void:
	if not char_center: return
	if path == "":
		char_center.visible = false
		return
	var tex = load(path)
	if tex:
		char_center.texture    = tex
		char_center.visible    = true
		char_center.modulate.a = 1.0


func _set_dual_chars(left_path: String, right_path: String, speaker: String) -> void:
	if char_left:
		if left_path != "":
			var ltex = load(left_path)
			if ltex:
				char_left.texture = ltex
				char_left.visible = true
				char_left.set_meta("char_name", _name_from_path(left_path))
		else:
			char_left.visible = false

	if char_right:
		if right_path != "":
			var rtex = load(right_path)
			if rtex:
				char_right.texture = rtex
				char_right.visible = true
				char_right.set_meta("char_name", _name_from_path(right_path))
		else:
			char_right.visible = false

	_apply_speaker_focus(speaker)


func _hide_dual_chars() -> void:
	if char_left:  char_left.visible  = false
	if char_right: char_right.visible = false


func _apply_speaker_focus(speaker: String) -> void:
	const DIM   : float = 0.50
	const BRIGHT: float = 1.00
	if speaker == "":
		_tween_alpha(char_left,  DIM)
		_tween_alpha(char_right, DIM)
		return
	var left_name  : String = char_left.get_meta("char_name",  "") if char_left  else ""
	var right_name : String = char_right.get_meta("char_name", "") if char_right else ""
	if left_name == speaker:
		_tween_alpha(char_left,  BRIGHT)
		_tween_alpha(char_right, DIM)
	elif right_name == speaker:
		_tween_alpha(char_left,  DIM)
		_tween_alpha(char_right, BRIGHT)
	else:
		_tween_alpha(char_left,  BRIGHT)
		_tween_alpha(char_right, BRIGHT)


func _tween_alpha(node: TextureRect, target: float) -> void:
	if not is_instance_valid(node): return
	if abs(node.modulate.a - target) < 0.01: return
	var t := create_tween()
	t.tween_property(node, "modulate:a", target, 0.18)


func _speaker_color(speaker: String) -> Color:
	match speaker:
		"Sans":     return Color(0.85, 0.85, 1.00)
		"Papyrus":  return Color(1.00, 0.85, 0.30)
		"Undyne":   return Color(0.40, 0.90, 0.60)
		"Toriel":   return Color(1.00, 0.70, 0.50)
		"Flowey":   return Color(0.95, 0.95, 0.30)
		"Chara":    return Color(0.90, 0.30, 0.30)
		"Asgore":   return Color(0.80, 0.60, 1.00)
		"Mettaton": return Color(1.00, 0.50, 0.70)
		"Gaster":   return Color(0.60, 0.90, 0.90)
		_:          return Color.WHITE


func _name_from_path(path: String) -> String:
	var p := path.to_lower()
	if "sans"    in p: return "Sans"
	if "papyrus" in p: return "Papyrus"
	if "undyne"  in p: return "Undyne"
	if "toriel"  in p: return "Toriel"
	if "flowey"  in p: return "Flowey"
	if "asgore"  in p: return "Asgore"
	if "chara"   in p: return "Chara"
	if "asriel"  in p: return "Asriel"
	return ""


# =====================================================
#  SHAKE SYSTEM
# =====================================================
func _check_shake(step: Dictionary) -> void:
	var text    : String = step.get("text", "")
	var char_l  : String = step.get("char_left",  step.get("char", ""))
	var char_r  : String = step.get("char_right", "")
	var speaker : String = step.get("name", "")

	var text_shakes   : bool = false
	var sprite_shakes : bool = false
	for t in SHAKE_TEXTS:
		if t in text: text_shakes = true
	for expr in SHAKE_EXPRS:
		if expr in char_l or expr in char_r: sprite_shakes = true

	if not (text_shakes or sprite_shakes): return

	var target : TextureRect = null
	if char_left and char_right and char_left.visible and char_right.visible:
		var left_name : String = char_left.get_meta("char_name", "")
		target = char_left if left_name == speaker else char_right
	elif char_center and char_center.visible:
		target = char_center

	if target: _do_shake(target)


func _do_shake(node: TextureRect) -> void:
	var origin : Vector2 = node.position
	var s      : float   = 10.0
	var t := create_tween()
	t.tween_property(node, "position", origin + Vector2(s,     0), 0.04)
	t.tween_property(node, "position", origin + Vector2(-s,    0), 0.04)
	t.tween_property(node, "position", origin + Vector2(s*0.5, 0), 0.03)
	t.tween_property(node, "position", origin + Vector2(-s*0.5,0), 0.03)
	t.tween_property(node, "position", origin,                     0.03)


# =====================================================
#  TRANSITION
# =====================================================
func _fade_then_change(scene_path: String) -> void:
	if AudioM: AudioM.fade_out_bgm(0.5)   # ✅ now exists
	if fade_player:
		fade_player.play("FadeOut")
		await fade_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
