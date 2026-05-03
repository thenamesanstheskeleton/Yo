extends Control

# =====================================================
#  very_secret_app.gd — PROJECT NYEHH HEH HEH
#  Papyrus's secret project notes.
#  Architecture matches quiz/mail/files apps exactly.
#
#  Signals:
#    app_closed(result: Dictionary)
# =====================================================

signal app_closed(result: Dictionary)

@onready var close_btn    : Button          = $TitleBar/CloseBtn
@onready var file_scroll  : ScrollContainer = $MainArea/FilePanel/FileScroll
@onready var file_vbox    : VBoxContainer   = $MainArea/FilePanel/FileScroll/FileVBox
@onready var read_panel   : Panel           = $MainArea/ReadPanel
@onready var read_scroll  : ScrollContainer = $MainArea/ReadPanel/ReadScroll
@onready var read_text    : RichTextLabel   = $MainArea/ReadPanel/ReadScroll/ReadText
@onready var back_btn     : Button          = $MainArea/ReadPanel/BackBtn

const FILES : Array = [
	{
		"name":    "📄  README.txt",
		"content": """[b]PROJECT NYEHH HEH HEH[/b]
[color=#888888][i]By The Great Papyrus. Classification: VERY SECRET.[/i][/color]

Welcome to the secret project folder.

This folder contains all of Papyrus's grand plans
for the future. Organized. Labeled. Extensively
annotated in the margins.

Select a file to read the details.

[color=#ffdd55]NYEH HEH HEH!!![/color]""",
	},
	{
		"name":    "📄  CHAPTER_3_PLANS.txt",
		"content": """[b]CHAPTER 3: STATUS[/b]

Chapter 3 is coming.

The human cannot go outside forever.
The blizzard will end.
Snowdin is small.
Eventually everything happens.

Details are classified.
Even from Papyrus.
[color=#888888](Especially from Papyrus.)[/color]

[color=#666666]Status: IN DEVELOPMENT[/color]""",
	},
	{
		"name":    "📄  FUTURE_APPS.txt",
		"content": """[b]BONEDOWS APPS — FUTURE PLANS[/b]

[color=#44ff66]Current Apps:[/color]
  ✓ ALPHYS RESEARCH PORTAL
  ✓ BONE MAIL
  ✓ GREAT PAPYRUS FILES
  ✓ PROJECT NYEHH HEH HEH (this!)

[color=#ffdd55]Planned Apps:[/color]
  ⧖ SPAGHETTI RECIPE DATABASE
  ⧖ PUZZLE WORKSHOP v2
  ⧖ UNDERGROUND NETWORK CHAT
  ⧖ SANS\'S KETCHUP STASH (hidden)

Each app will have unique features.
Papyrus has written this down
so he does not forget.
He will not forget.
He is THE GREAT PAPYRUS.""",
	},
	{
		"name":    "📄  IMPORTANT_REMINDERS.txt",
		"content": """[b]REMINDERS — T.G.P.[/b]

1. Do not leave puzzles unattended.
   The Annoying Dog has been in the area.
   You know what happened to v31 through v36.

2. Sans's socks: check under the couch.
   Also behind the couch.
   Also possibly inside the couch.
   Do not ask about the couch.

3. Undyne's training is Thursday now.
   She did not say why.
   Do not ask why.

4. The human is fine.
   The human is here.
   This is fine.

5. You are doing great. — T.G.P.""",
	},
]


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
	btn.text                = f["name"]
	btn.custom_minimum_size = Vector2(0, 48)
	btn.alignment           = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 18)
	btn.clip_text           = true

	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
	style.border_color = Color(0.22, 0.22, 0.38, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	btn.add_theme_stylebox_override("normal", style)
	var style_h := style.duplicate()
	style_h.bg_color = Color(0.14, 0.14, 0.24, 1.0)
	btn.add_theme_stylebox_override("hover", style_h)

	btn.pressed.connect(func(): _open_file(f))
	return btn


func _show_files() -> void:
	read_panel.hide()
	$MainArea/FilePanel.show()


func _open_file(f: Dictionary) -> void:
	$MainArea/FilePanel.hide()
	read_panel.show()
	read_text.text = "[color=#dddddd]%s[/color]" % f["content"]
	await get_tree().process_frame
	read_scroll.scroll_vertical = 0


func _on_close() -> void:
	app_closed.emit({})
