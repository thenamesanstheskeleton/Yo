extends Control

# =====================================================
#  Chapter1.gd
#  Controls chapter 1 scene
#
#  Responsibilities:
#    - Wire all scene nodes into VNEngine
#    - Handle chapter_ended signal → transition
#    - Handle chapter_event signal → custom chapter
#      animations/events, then call engine.resume()
#
#  HOW TO ADD CUSTOM EVENTS:
#    1. Add an animation to ChapterEvents AnimationPlayer
#    2. Add { "type":"event", "id":"your_id" } in chapter1 data
#    3. Handle it in _on_chapter_event() below
#    4. Call engine.resume() when your event is done
# =====================================================

const CHAPTER_DATA = preload("res://scripts/data/chapter1.gd")

@onready var engine          : Node            = $VNEngine
@onready var bg_rect         : TextureRect     = $Background
@onready var char_center     : TextureRect     = $CharCenter
@onready var char_left       : TextureRect     = $CharLeft
@onready var char_right      : TextureRect     = $CharRight
@onready var dialog_box      : ColorRect       = $DialogueLayer/DialogBox
@onready var name_box        : ColorRect       = $DialogueLayer/NameBox
@onready var name_label      : Label           = $DialogueLayer/NameLabel
@onready var dialog_text     : RichTextLabel   = $DialogueLayer/DialogText
@onready var next_arrow      : Label           = $DialogueLayer/NextArrow
@onready var choice_cont     : VBoxContainer   = $DialogueLayer/ChoiceContainer
@onready var black_screen    : ColorRect       = $BlackScreenTransition
@onready var fade_player     : AnimationPlayer = $BlackScreenTransition/FadePlayer
@onready var chapter_events  : AnimationPlayer = $ChapterEvents


func _ready() -> void:
	# ── Wire node refs into VNEngine ──────────────────
	engine.bg_rect          = bg_rect
	engine.char_center      = char_center
	engine.char_left        = char_left
	engine.char_right       = char_right
	engine.dialog_box       = dialog_box
	engine.name_box         = name_box
	engine.name_label       = name_label
	engine.dialog_text      = dialog_text
	engine.next_arrow       = next_arrow
	engine.choice_container = choice_cont
	engine.black_screen     = black_screen
	engine.fade_player      = fade_player

	# ── Connect signals ───────────────────────────────
	engine.chapter_ended.connect(_on_chapter_ended)
	engine.chapter_event.connect(_on_chapter_event)

	# ── Load data + start ─────────────────────────────
	var data_obj = CHAPTER_DATA.new()
	engine.load_chapter(data_obj.DATA)
	engine.start("start")


# =====================================================
#  CHAPTER ENDED → transition to next
# =====================================================
func _on_chapter_ended(next_chapter: int) -> void:
	if has_node("/root/AudioM"):
		get_node("/root/AudioM").fade_out_bgm(0.5)

	fade_player.play("FadeOut")
	await fade_player.animation_finished

	var next_scene := "res://scenes/chapter%d.tscn" % next_chapter
	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# =====================================================
#  CHAPTER EVENT — custom per-chapter animations
#
#  VNEngine pauses and fires this signal when it hits
#  a { "type": "event", "id": "some_id" } step.
#  Do your thing here, then call engine.resume().
#
#  Example events you might add later:
#    "papyrus_run_in"   → play a run-in animation
#    "screen_shake"     → shake the whole scene
#    "snow_burst"       → particle burst effect
#    "sans_teleport"    → flash + reposition
# =====================================================
func _on_chapter_event(event_id: String) -> void:
	match event_id:

		# ── Add your chapter 1 events here ────────────
		# Example (commented out until you add the anim):
		# "papyrus_run_in":
		#     chapter_events.play("PapyrusRunIn")
		#     await chapter_events.animation_finished
		#     engine.resume()

		# ── Default — unknown event, just resume ──────
		_:
			engine.resume()
