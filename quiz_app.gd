extends Control

# =====================================================
#  quiz_app.gd  —  ALPHYS RESEARCH PORTAL
#  Real asset: res://assets/images/Bonedows/icons/alphys_icon.png
#  for the Alphys message panel header portrait.
# =====================================================

signal app_closed(result: Dictionary)

const ALPHYS_ICON = "res://assets/images/Bonedows/icons/alphys_icon.png"
const FONT        = "res://assets/fonts/DTM-Sans.otf"
const MONO        = "res://assets/fonts/DTM-Mono.otf"

@onready var close_btn      : Button           = $TitleBar/CloseBtn
@onready var content_scroll : ScrollContainer  = $ContentArea/ScrollContainer
@onready var question_label : RichTextLabel    = $ContentArea/ScrollContainer/VBox/QuestionLabel
@onready var question_note  : Label            = $ContentArea/ScrollContainer/VBox/QuestionNote
@onready var answers_vbox   : VBoxContainer    = $ContentArea/ScrollContainer/VBox/AnswersVBox
@onready var progress_label : Label            = $ContentArea/ScrollContainer/VBox/ProgressLabel
@onready var feedback_label : Label            = $ContentArea/ScrollContainer/VBox/FeedbackLabel
@onready var submit_btn     : Button           = $ContentArea/SubmitBtn
@onready var result_panel   : Panel            = $ResultPanel
@onready var result_label   : RichTextLabel    = $ResultPanel/ResultLabel
@onready var alphys_panel   : Panel            = $AlphysMessagePanel
@onready var alphys_portrait: TextureRect      = $AlphysMessagePanel/AlphysPortrait
@onready var alphys_text    : RichTextLabel    = $AlphysMessagePanel/AlphysText
@onready var alphys_ok_btn  : Button           = $AlphysMessagePanel/OkBtn

const QUESTIONS : Array = [
	{
		"category": "ENGLISH",
		"question": "Complete the sentence:\n\"She neither confirmed ___ denied.\"",
		"note":     "(Recovered from a human novel. The cover had a sad dog on it.)",
		"answers":  ["nor", "or", "and", "but"],
		"correct":  0,
	},
	{
		"category": "ENGLISH",
		"question": "What does the word 'ephemeral' mean?",
		"note":     "(Found in the same novel. The human was crying on the cover. Very dramatic.)",
		"answers":  [
			"Lasting only a short time",
			"Extremely large in size",
			"Impossible to see through",
			"Relating to cold weather",
		],
		"correct":  0,
	},
	{
		"category": "MATH",
		"question": "What is 15% of 240?",
		"note":     "(Found on a piece of paper titled 'TAX WORKSHEET'. Humans tax everything.)",
		"answers":  ["36", "24", "38", "30"],
		"correct":  0,
	},
	{
		"category": "MATH",
		"question": "Solve for x:\n3x + 7 = 22",
		"note":     "(Found on a child's homework. The child got it wrong. I fixed it for them. In my notes.)",
		"answers":  ["x = 5", "x = 4", "x = 7", "x = 3"],
		"correct":  0,
	},
	{
		"category": "MATH",
		"question": "What is the next number in the sequence?\n2 , 6 , 18 , 54 , ___",
		"note":     "(Found on a refrigerator. Humans put math on refrigerators. I think for decoration.)",
		"answers":  ["162", "108", "144", "72"],
		"correct":  0,
	},
	{
		"category": "ANIME",
		"question": "What transformation does the main character achieve\nat the climax of Dragon Ball Z?",
		"note":     "(Recovered from a plastic disc. The screaming was described extensively on the back cover.)",
		"answers":  ["Super Saiyan", "Ultra Instinct", "Kaioken x20", "Great Ape"],
		"correct":  0,
	},
	{
		"category": "ANIME",
		"question": "In Fullmetal Alchemist, what is the\nfundamental law that governs all alchemy called?",
		"note":     "(Two discs found together in a bag. Both were scratched. I watched them anyway. For research.)",
		"answers":  ["Equivalent Exchange", "The Law of Circles", "Truth's Bargain", "The Homunculus Rule"],
		"correct":  0,
	},
	{
		"category": "ANIME",
		"question": "How many episodes does the\noriginal Sailor Moon anime have?",
		"note":     "(I found a DVD in the dump. I have watched all of it. This is purely research.\nDo not ask follow-up questions.)",
		"answers":  ["200", "46", "124", "176"],
		"correct":  0,
	},
]

var _current_q       : int   = 0
var _selected_answer : int   = -1
var _score           : int   = 0
var _answer_btns     : Array = []
var _already_done    : bool  = false

func _mark_quiz_memory(completed: bool) -> void:
	var sav = get_node_or_null("/root/SavM")
	if sav == null:
		return
	if not sav.data.has("bonedows_memory") or typeof(sav.data["bonedows_memory"]) != TYPE_DICTIONARY:
		sav.data["bonedows_memory"] = {}
	var mem : Dictionary = sav.data["bonedows_memory"]
	mem["quiz_completed"] = completed
	sav.data["bonedows_memory"] = mem



func _ready() -> void:
	# Load Alphys portrait for message panel
	var tex = load(ALPHYS_ICON)
	if tex and is_instance_valid(alphys_portrait):
		alphys_portrait.texture = tex

	close_btn.pressed.connect(_close_no_result)
	submit_btn.pressed.connect(_on_submit_pressed)
	alphys_ok_btn.pressed.connect(_on_alphys_ok)

	result_panel.hide()
	alphys_panel.hide()
	feedback_label.text = ""

	if _already_done:
		_show_already_completed()
	else:
		_load_question(_current_q)


func set_already_completed(val: bool) -> void:
	_already_done = val


func _load_question(index: int) -> void:
	var q : Dictionary = QUESTIONS[index]
	for btn in _answer_btns:
		btn.queue_free()
	_answer_btns.clear()
	_selected_answer = -1
	feedback_label.text = ""
	submit_btn.disabled = true

	var cat_colors := { "ENGLISH": "#88ccff", "MATH": "#ffdd55", "ANIME": "#ff88cc" }
	var cat_col : String = cat_colors.get(q["category"], "#ffffff")
	question_label.text = "[color=%s][b][ %s ][/b][/color]\n\n%s" % [cat_col, q["category"], q["question"]]
	question_note.text  = q["note"]
	progress_label.text = "Question %d of %d" % [index + 1, QUESTIONS.size()]

	for i in range(q["answers"].size()):
		var btn := Button.new()
		btn.text                = "  " + q["answers"][i]
		btn.toggle_mode         = true
		btn.alignment           = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 18)
		btn.add_theme_font_override("font", load(FONT))

		var sn := StyleBoxFlat.new()
		sn.bg_color     = Color(0.10, 0.10, 0.18, 1.0)
		sn.border_color = Color(0.28, 0.28, 0.50, 1.0)
		sn.set_border_width_all(2)
		sn.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", sn)
		var sp := sn.duplicate()
		sp.bg_color     = Color(0.20, 0.20, 0.42, 1.0)
		sp.border_color = Color(0.60, 0.60, 1.0, 1.0)
		btn.add_theme_stylebox_override("pressed", sp)

		var ci := i
		btn.toggled.connect(func(on): _on_answer_toggled(ci, on))
		answers_vbox.add_child(btn)
		_answer_btns.append(btn)


func _on_answer_toggled(index: int, on: bool) -> void:
	for i in range(_answer_btns.size()):
		if i != index:
			_answer_btns[i].button_pressed = false
	if on:
		_selected_answer = index
		submit_btn.disabled = false
	else:
		_selected_answer = -1
		submit_btn.disabled = true


func _on_submit_pressed() -> void:
	if _selected_answer < 0:
		return
	var q       : Dictionary = QUESTIONS[_current_q]
	var correct : bool       = (_selected_answer == q["correct"])

	for i in range(_answer_btns.size()):
		var btn : Button = _answer_btns[i]
		btn.disabled = true
		if i == q["correct"]:
			var s := StyleBoxFlat.new()
			s.bg_color = Color(0.08, 0.38, 0.12, 1.0)
			s.border_color = Color(0.3, 0.9, 0.4, 1.0)
			s.set_border_width_all(2); s.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("disabled", s)
		elif i == _selected_answer and not correct:
			var s := StyleBoxFlat.new()
			s.bg_color = Color(0.40, 0.08, 0.08, 1.0)
			s.border_color = Color(0.9, 0.3, 0.3, 1.0)
			s.set_border_width_all(2); s.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("disabled", s)

	if correct:
		_score += 1
		feedback_label.text = "✓  Correct."
		feedback_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	else:
		feedback_label.text = "✗  Incorrect. Correct answer: " + q["answers"][q["correct"]]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

	submit_btn.disabled = true
	await get_tree().create_timer(1.5).timeout
	_current_q += 1
	if _current_q >= QUESTIONS.size():
		_show_results()
	else:
		_load_question(_current_q)


func _show_results() -> void:
	$ContentArea.hide()
	result_panel.show()
	var passed : bool = (_score >= 6)
	var txt := "[center][b][color=#ffdd55]ALPHYS RESEARCH PORTAL — RESULTS[/color][/b][/center]\n\n"
	txt += "[center]Score:  [b]%d / %d[/b][/center]\n\n" % [_score, QUESTIONS.size()]
	if passed:
		txt += "[center][color=#44ff66]Grant threshold met.[/color][/center]\n"
		txt += "[center]Processing Royal Research Grant...[/center]\n\n"
		txt += "[center][color=#ffdd55]150G deposited to:[/color][/center]\n"
		txt += "[center][b]PAPYRUS T. SKELETON[/b][/center]\n"
	else:
		txt += "[center][color=#ff6644]Grant threshold not met. (Requires 6/8)[/color][/center]\n\n"
		txt += "[center]Dr. Alphys thanks you for participating.[/center]\n"
		txt += "[center][color=#888888](She is a little disappointed.)[/color][/center]\n"
	result_label.text = txt

	if passed:
		await get_tree().create_timer(2.0).timeout
		_show_alphys_message()
	else:
		await get_tree().create_timer(2.5).timeout
		app_closed.emit({ "g_earned": false, "quiz_passed": false })


func _show_alphys_message() -> void:
	alphys_panel.show()
	# The lore bomb — "nevermind" does all the work
	var msg := "[color=#aaddff][b]📨  New Message from Dr. Alphys[/b][/color]\n\n"
	msg += "oh! papyrus!!\n\n"
	msg += "you completed the royal research query...\n"
	msg += "i'm really impressed...\n\n"
	msg += "i thought maybe...\n"
	msg += "[color=#aaaaaa]...nevermind.[/color]\n\n"
	msg += "sans wouldn't bother with something like this anyway...\n\n"
	msg += "please accept this grant on behalf of royal scientific research.\n"
	msg += "you're really something, papyrus.\n\n"
	msg += "[color=#666666]— Dr. Alphys, Royal Scientist[/color]"
	alphys_text.text = msg


func _on_alphys_ok() -> void:
	_mark_quiz_memory(true)
	app_closed.emit({ "g_earned": true, "quiz_passed": true })


func _show_already_completed() -> void:
	question_label.text = "[color=#888888]This query has already been completed.[/color]"
	question_note.text  = "The grant was deposited. Dr. Alphys was impressed.\n(She assumed it was Papyrus. She didn't say Sans's name. Almost.)"
	answers_vbox.hide()
	submit_btn.hide()
	progress_label.text = ""


func _close_no_result() -> void:
	_mark_quiz_memory(false)
	app_closed.emit({ "g_earned": false, "quiz_passed": false })
