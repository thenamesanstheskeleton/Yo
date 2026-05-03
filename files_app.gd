extends Control

# =====================================================
#  files_app.gd
#  GREAT PAPYRUS FILES  [VERY PRIVATE]
#
#  A file explorer containing Papyrus's documents.
#  Clicking a file opens it in a scrollable reader.
#  Some files are locked. Some probably shouldn't
#  be read. The player will read all of them.
#
#  Signals:
#    app_closed(result: Dictionary)
# =====================================================

signal app_closed(result: Dictionary)

const MEMORY_KEY := "bonedows_memory"


func _get_memory() -> Dictionary:
	var sav = get_node_or_null("/root/SavM")
	if sav == null:
		return {}
	if not sav.data.has(MEMORY_KEY) or typeof(sav.data[MEMORY_KEY]) != TYPE_DICTIONARY:
		sav.data[MEMORY_KEY] = {"read_files": {}}
	var mem : Dictionary = sav.data[MEMORY_KEY]
	if not mem.has("read_files"): mem["read_files"] = {}
	sav.data[MEMORY_KEY] = mem
	return mem


func _file_key(f: Dictionary) -> String:
	return str(f.get("name", "file")).to_lower()


func _is_read(f: Dictionary) -> bool:
	var mem := _get_memory()
	var read_files : Dictionary = mem.get("read_files", {})
	return read_files.get(_file_key(f), false)


func _mark_read(f: Dictionary) -> void:
	var mem := _get_memory()
	var read_files : Dictionary = mem.get("read_files", {})
	read_files[_file_key(f)] = true
	mem["read_files"] = read_files
	mem["last_file"] = _file_key(f)
	var sav = get_node_or_null("/root/SavM")
	if sav:
		sav.data[MEMORY_KEY] = mem



# ── Node refs ──────────────────────────────────────────
@onready var close_btn    : Button           = $TitleBar/CloseBtn
@onready var file_scroll  : ScrollContainer  = $MainArea/FilePanel/FileScroll
@onready var file_vbox    : VBoxContainer    = $MainArea/FilePanel/FileScroll/FileVBox
@onready var read_panel   : Panel            = $MainArea/ReadPanel
@onready var read_scroll  : ScrollContainer  = $MainArea/ReadPanel/ReadScroll
@onready var read_text    : RichTextLabel    = $MainArea/ReadPanel/ReadScroll/ReadText
@onready var back_btn     : Button           = $MainArea/ReadPanel/BackBtn

# ── File data ──────────────────────────────────────────
const FILES : Array = [
	{
		"name":   "📄  PUZZLE_DESIGNS_V47.txt",
		"locked": false,
		"content": "PUZZLE DESIGN NOTES — Version 47\nBy The Great Papyrus\n\n— Revision history —\nv1-v12: Basic bone arrangements. Promising.\nv13-v24: Intermediate difficulty. Sans said they were 'fine'. This was high praise.\nv25-v38: Advanced sequences. The Annoying Dog ate v31 through v36.\nv39-v46: Reconstructed from memory. Possibly better than originals.\nv47: CURRENT. Working title: 'The Puzzle That Cannot Be Eaten'.\n\nNote: Have consulted Undyne. She said 'just hit them.' This was not helpful.\nNote 2: Have consulted Sans. He said 'hm'. This was also not helpful.\nNote 3: Will consult myself. I am very helpful.",
	},
	{
		"name":   "📄  COOKING_RESEARCH_NOTES.txt",
		"locked": false,
		"content": "COOKING RESEARCH — Ongoing\nSubject: Non-Spaghetti Foods\n\nDay 1: Attempted toast. Went well. Too well. Suspicious.\nDay 4: Attempted soup. Sans said it tasted 'interesting'. Unclear if compliment.\nDay 9: Attempted a salad. It was fine. I feel nothing.\nDay 14: Undyne taught me to smash vegetables against the counter first.\n         She said this 'activates them'.\n         I have no evidence against this.\nDay 21: PANCAKES. Made successfully. Round. Very round.\n         Will add to permanent rotation.\n\nCurrent conclusion: Spaghetti remains superior. But pancakes are acceptable.\nFurther research required.",
	},
	{
		"name":   "📄  MY_TRAINING_JOURNAL.txt",
		"locked": false,
		"content": "TRAINING JOURNAL\nThe Great Papyrus — Royal Guard Candidate\n\nWeek 1: Undyne ran me up the waterfall stairs fourteen times.\n        I did not complain. I complained seventeen times.\n        She said this was acceptable.\n\nWeek 6: Undyne threw a spear near me to 'test my reflexes'.\n        I moved. She seemed surprised.\n        She wrote something in her clipboard.\n        I did not ask what.\n\nWeek 12: Training session was cancelled. We made soup instead.\n         It caught fire. She called it 'a success'.\n         I am beginning to understand her.\n\nCurrent rank: Not yet Royal Guard. Soon, though. NYEH HEH HEH.",
	},
	{
		"name":   "🔒  [LOCKED] SANS_FILE.txt",
		"locked": true,
		"content": "",
	},
	{
		"name":   "📄  IMPORTANT_NOTES_FOR_SELF.txt",
		"locked": false,
		"content": "IMPORTANT NOTES\nPapyrus T. Skeleton — Personal Reference Document\n\n1. Password reminder: 'Something that describes me perfectly.'\n   (It is IAMTHEGREATPAPYRUS1. Do not forget. This note is the backup.)\n\n2. Sans's socks: Check under the couch. Also behind the couch. Also inside the couch.\n   He has been inside the couch before. Do not ask.\n\n3. Reminder: Tell Sans about the G transaction in Alphys's last email.\n   He has not opened his email in four days.\n   He knows about the email. He is choosing not to open it.\n   This is a him problem.\n\n4. The Annoying Dog: If seen, do not engage. Do not make eye contact.\n   Do not leave puzzles unattended.\n   Do NOT leave spaghetti unattended.\n   Do NOT leave anything unattended.\n\n5. You are doing great. — T.G.P.",
	},
]


# =====================================================
#  READY
# =====================================================
func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	back_btn.pressed.connect(_show_files)
	read_panel.hide()
	_build_file_list()


func _build_file_list() -> void:
	for f in FILES:
		var btn := _make_file_row(f)
		file_vbox.add_child(btn)


func _make_file_row(f: Dictionary) -> Button:
	var btn := Button.new()
	var read := _is_read(f)
	btn.text                    = ("✓ " if read else "") + f["name"]
	btn.custom_minimum_size     = Vector2(0, 48)
	btn.alignment               = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 18)
	btn.clip_text               = true

	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
	style.border_color = Color(0.22, 0.22, 0.38, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	btn.add_theme_stylebox_override("normal", style)
	var style_h := style.duplicate()
	style_h.bg_color = Color(0.14, 0.14, 0.24, 1.0)
	btn.add_theme_stylebox_override("hover", style_h)

	if read and not f["locked"]:
		btn.modulate = Color(0.75, 0.85, 1.0, 1.0)
	if f["locked"]:
		btn.modulate = Color(0.5, 0.5, 0.5, 1.0)
		btn.disabled = true
		btn.tooltip_text = "ACCESS DENIED\n(Papyrus locked this one.)"
	else:
		btn.pressed.connect(func(): _open_file(f))

	return btn


# =====================================================
#  VIEW SWITCHING
# =====================================================
func _show_files() -> void:
	read_panel.hide()
	$MainArea/FilePanel.show()


func _open_file(f: Dictionary) -> void:
	_mark_read(f)
	$MainArea/FilePanel.hide()
	read_panel.show()
	read_text.text = "[color=#dddddd]%s[/color]" % f["content"]
	await get_tree().process_frame
	read_scroll.scroll_vertical = 0


# =====================================================
#  CLOSE
# =====================================================
func _on_close() -> void:
	app_closed.emit({})
