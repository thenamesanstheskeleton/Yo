extends Control

# =====================================================
#  mail_app.gd
#  BONE MAIL — Papyrus's Email Client
#
#  Scrollable inbox. Clicking a message opens it
#  in a reading pane. All text contained inside
#  the window — no overflow outside the tab.
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
		sav.data[MEMORY_KEY] = {"read_mail": {}}
	var mem : Dictionary = sav.data[MEMORY_KEY]
	if not mem.has("read_mail"): mem["read_mail"] = {}
	sav.data[MEMORY_KEY] = mem
	return mem


func _mail_key(mail: Dictionary) -> String:
	return (str(mail.get("from", "")) + "|" + str(mail.get("subject", ""))).to_lower()


func _is_read(mail: Dictionary) -> bool:
	var mem := _get_memory()
	var read_mail : Dictionary = mem.get("read_mail", {})
	return read_mail.get(_mail_key(mail), false)


func _mark_read(mail: Dictionary) -> void:
	var mem := _get_memory()
	var read_mail : Dictionary = mem.get("read_mail", {})
	read_mail[_mail_key(mail)] = true
	mem["read_mail"] = read_mail
	mem["last_mail"] = _mail_key(mail)
	var sav = get_node_or_null("/root/SavM")
	if sav:
		sav.data[MEMORY_KEY] = mem



# ── Node refs ──────────────────────────────────────────
@onready var close_btn      : Button          = $TitleBar/CloseBtn
@onready var inbox_scroll   : ScrollContainer = $MainArea/InboxPanel/InboxScroll
@onready var inbox_vbox     : VBoxContainer   = $MainArea/InboxPanel/InboxScroll/InboxVBox
@onready var read_panel     : Panel           = $MainArea/ReadPanel
@onready var read_scroll    : ScrollContainer = $MainArea/ReadPanel/ReadScroll
@onready var read_text      : RichTextLabel   = $MainArea/ReadPanel/ReadScroll/ReadText
@onready var back_btn       : Button          = $MainArea/ReadPanel/BackBtn
@onready var empty_label    : Label           = $MainArea/ReadPanel/EmptyLabel

# ── Mail data ──────────────────────────────────────────
const MAILS : Array = [
	{
		"from":    "captain.undyne@royalguard.mtn",
		"subject": "RE: TRAINING SCHEDULE",
		"date":    "Yesterday, 7:14 AM",
		"preview": "Papyrus. About tomorrow's session...",
		"body":    "Papyrus.\n\nAbout tomorrow's session — I'm moving it to Thursday.\n\nDon't ask why. Just Thursday.\n\nAlso your last spaghetti was actually not terrible. This is not a compliment. This is a factual observation.\n\n— Undyne\n\nP.S. Tell Sans I said nothing.",
	},
	{
		"from":    "alphys@royallab.mtn",
		"subject": "Royal Research Initiative — Active Query",
		"date":    "Today, 6:02 AM",
		"preview": "Hello Papyrus! A new research query is available...",
		"body":    "Hello Papyrus!\n\nA new research query is available on the Alphys Research Portal.\n\nIf you complete it, you will receive a Royal Research Grant deposited directly to your account.\n\nThe questions are based on surface materials recovered from the dump site. I think you'll find them interesting!\n\n...I also posted it to Sans but he hasn't opened the email in four days so.\n\n— Dr. Alphys, Royal Scientist\n\n[Royal Scientific Research Division, Underground Lab]",
	},
	{
		"from":    "no-reply@bonedows.mtn",
		"subject": "Your password has been set",
		"date":    "3 days ago",
		"preview": "Your Bonedows password was successfully updated...",
		"body":    "Your Bonedows password was successfully updated.\n\nNew password hint: 'Something that describes me perfectly.'\n\nIf you did not make this change, please contact yourself.\n\n— Bonedows Security Team\n(This is an automated message. Bonedows Security Team is one person. It is Papyrus.)",
	},
	{
		"from":    "sans@definitely-working.mtn",
		"subject": "hey",
		"date":    "5 days ago",
		"preview": "bro did you eat my ketchup",
		"body":    "bro\n\ndid you eat my ketchup\n\nthe one in the back of the fridge\n\nnot the front one the BACK one\n\n— sans\n\np.s. nice puzzle designs by the way\n\np.p.s. seriously though the ketchup",
	},
]


# =====================================================
#  READY
# =====================================================
func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	back_btn.pressed.connect(_show_inbox)

	read_panel.hide()
	_build_inbox()
	_show_inbox()


func _build_inbox() -> void:
	for mail in MAILS:
		var row := _make_mail_row(mail)
		inbox_vbox.add_child(row)


func _make_mail_row(mail: Dictionary) -> Button:
	var btn := Button.new()
	var read := _is_read(mail)
	btn.custom_minimum_size = Vector2(0, 64)
	btn.alignment           = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat                = false
	btn.clip_text           = true

	var style := StyleBoxFlat.new()
	style.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
	style.border_color = Color(0.25, 0.25, 0.4, 1.0)
	style.set_border_width_all(1)
	btn.add_theme_stylebox_override("normal", style)

	var style_hover := style.duplicate()
	style_hover.bg_color = Color(0.15, 0.15, 0.25, 1.0)
	btn.add_theme_stylebox_override("hover", style_hover)

	# Inner layout: sender bold + subject + date
	var label := RichTextLabel.new()
	label.bbcode_enabled         = true
	label.fit_content            = true
	label.scroll_active          = false
	label.mouse_filter           = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", 17)
	label.text = "[b]%s%s[/b]   [color=#888888]%s[/color]\n[color=#cccccc]%s[/color]" % [
		("✓ " if read else ""), mail["from"], mail["date"], mail["subject"]
	]
	btn.add_child(label)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left   = 12
	label.offset_right  = -12
	label.offset_top    = 6
	label.offset_bottom = -6

	if read:
		btn.modulate = Color(0.76, 0.84, 1.0, 1.0)
	btn.pressed.connect(func(): _open_mail(mail))
	return btn


# =====================================================
#  VIEW SWITCHING
# =====================================================
func _show_inbox() -> void:
	read_panel.hide()
	$MainArea/InboxPanel.show()


func _open_mail(mail: Dictionary) -> void:
	_mark_read(mail)
	$MainArea/InboxPanel.hide()
	read_panel.show()

	var body : String = ""
	body += "[color=#ffdd55][b]From:[/b][/color]  %s\n" % mail["from"]
	body += "[color=#ffdd55][b]Subject:[/b][/color]  %s\n" % mail["subject"]
	body += "[color=#ffdd55][b]Date:[/b][/color]  %s\n" % mail["date"]
	body += "\n[color=#dddddd]%s[/color]" % mail["body"]

	read_text.text = body

	# Scroll to top
	await get_tree().process_frame
	read_scroll.scroll_vertical = 0


# =====================================================
#  CLOSE
# =====================================================
func _on_close() -> void:
	app_closed.emit({})
