extends Control

# ─────────────────────────────────────────────────────────────
#  NameInput.gd — Undertale-style name input
#  Mobile first, portrait 1080×1920, touchscreen only
#  Godot 4.6.2
#
#  Flow:
#    1. Player types name (6 char max)
#    2. Taps Done
#    3. Confirmation — name floats in from tiny → full size + shake
#    4. Normal name   → Narrator: "* Is this the name you'll give?"
#       Easter egg    → Character reacts with their voice
#       Anos/Voldigoad → Voldigoad Route flag set
#    5. Yes → save + white flash → chapter1
#    6. No  → back to keyboard
# ─────────────────────────────────────────────────────────────

@onready var title_label   : Label          = $NameInputSystem/TitleLabel
@onready var name_label    : Label          = $NameInputSystem/NameRow/NameLabel
@onready var cursor_label  : Label          = $NameInputSystem/NameRow/CursorLabel
@onready var letter_grid   : GridContainer  = $NameInputSystem/LetterGrid
@onready var btn_quit      : Button         = $NameInputSystem/ActionRow/QuitButton
@onready var btn_backspace : Button         = $NameInputSystem/ActionRow/BackspaceButton
@onready var btn_done      : Button         = $NameInputSystem/ActionRow/DoneButton
@onready var black_screen  : ColorRect      = $BlackScreenTransition
@onready var fade_anim     : AnimationPlayer= $BlackScreenTransition/AnimationPlayer
@onready var white_screen  : ColorRect      = $WhiteScreenTransition
@onready var confirm_screen : Control = $ConfirmScreen
@onready var confirm_name   : Label   = $ConfirmScreen/ConfirmName
@onready var confirm_msg    : Label   = $ConfirmScreen/ConfirmMsg
@onready var btn_yes        : Button  = $ConfirmScreen/ChoiceRow/YesButton
@onready var btn_no         : Button  = $ConfirmScreen/ChoiceRow/NoButton

var _voice_player : AudioStreamPlayer = null

const MAX_NAME_CHARS : int    = 6
const FONT_PATH      : String = "res://assets/fonts/DTM-Sans.otf"

# ── Voice map ─────────────────────────────────────────────────
# ✅ = exists   ❌ = missing, falls back to blip_default
const VOICE_MAP : Dictionary = {
	"Sans"        : "res://assets/audio/voice/sans.wav",      # ✅
	"Papyrus"     : "res://assets/audio/voice/papyrus.wav",   # ✅
	"Toriel"      : "res://assets/audio/voice/toriel1.wav",   # ✅
	"Undyne"      : "res://assets/audio/voice/undyne1.wav",   # ✅
	"Mettaton"    : "res://assets/audio/voice/mettaton.mp3",  # ✅
	"???"         : "res://assets/audio/sfx/voice_wdg.mp3",   # ✅ Gaster
	# ❌ Missing (falls back to blip_default.ogg):
	# Alphys, Asgore, Flowey, Asriel, Chara, Frisk, Anos,
	# Grillby, Muffet, Temmie, Napstablook, Burgerpants, etc.
}
const VOICE_DEFAULT : String = "res://assets/audio/voice/blip_default.ogg"

const CHARACTERS : Array[String] = [
	"A","B","C","D","E","F","G",
	"H","I","J","K","L","M","N",
	"O","P","Q","R","S","T","U",
	"V","W","X","Y","Z","","",
	"a","b","c","d","e","f","g",
	"h","i","j","k","l","m","n",
	"o","p","q","r","s","t","u",
	"v","w","x","y","z","","",
]

# ── Anos trigger keys ─────────────────────────────────────────
const ANOS_KEYS : Array[String] = ["anos","voldigoad","demonking"]

# ── Special name reactions ─────────────────────────────────────
const SPECIAL_NAMES : Dictionary = {
	# MAIN CAST
	"sans":          ["Sans",          "nope."],
	"papyrus":       ["Papyrus",       "THAT IS THE GREAT PAPYRUS'S NAME!!! ...wait."],
	"toriel":        ["Toriel",        "My child... please choose your own name."],
	"asgore":        ["Asgore",        "..."],
	"undyne":        ["Undyne",        "HEY! THAT NAME IS TAKEN! PICK SOMETHING COOLER!"],
	"alphys":        ["Alphys",        "U-uhhh...? No please? That's... that's mine..."],
	"flowey":        ["Flowey",        "Heh. Bold choice, idiot."],
	"mettaton":      ["Mettaton",      "Oh DARLING, no. There is only ONE Mettaton."],
	"asriel":        ["Asriel",        "...please don't."],
	"chara":         ["Chara",         "...so you remember."],
	"gaster":        ["???",           "̴̨̛͈̤͘ ̸̡̡̱͖͈̎̌̄ ̷̧̢̧̛͓͕̠̻̀̓ ̶̰̈́̈͛͗"],
	"frisk":         ["Frisk",         "... (that name carries consequences.)"],
	# ANOS VOLDIGOAD — SPECIAL ROUTE
	"anos":          ["Anos",          "heh. so you know my name. interesting. ...i'll allow it."],
	"voldigoad":     ["Anos",          "...you remembered the full name. rare. i respect it."],
	"demonking":     ["Anos",          "accurate title. perhaps too on the nose. ...but fine."],
	"demon":         ["Anos",          "close enough. i'll take it."],
	# SIDE CHARACTERS
	"grillby":       ["Grillby",       "..."],
	"muffet":        ["Muffet",        "Ahuhuhu~ That name belongs to ME, dearie~"],
	"temmie":        ["Temmie",        "OMG!! dat name!! hOI!! u cant hav it!!"],
	"napstablook":   ["Napstablook",   "oh... that's... my name... sorry for existing..."],
	"blooky":        ["Napstablook",   "oh... nobody calls me that anymore... it's okay..."],
	"burgerpants":   ["Burgerpants",   "Oh GREAT. Another one. My life is a nightmare."],
	"gerson":        ["Gerson",        "WAHAHA! Bold choice, young one! But no!"],
	"bratty":        ["Bratty",        "Oh my god that's like literally OUR name"],
	"catty":         ["Catty",         "Oh my god literally same what she said"],
	"onionsan":      ["Onionsan",      "OH YEAH THATS MY NAME YEAH! OH YEAH!"],
	"riverperson":   ["Riverperson",   "Tra la la... that name belongs to the river..."],
	"dog":           ["Annoying Dog",  "*the dog wags its tail and absorbs the name*"],
	"annoying":      ["Annoying Dog",  "*snoring sounds*"],
	"woshua":        ["Woshua",        "That name is DIRTY. Let me clean it."],
	"aaron":         ["Aaron",         "...FLEX"],
	"shyren":        ["Shyren",        "♪...♪ (please choose something else) ♪...♪"],
	"maddummy":      ["Mad Dummy",     "ARE YOU SERIOUS?! THAT'S MY NAME!"],
	"dummy":         ["Mad Dummy",     "EXCUSE ME?!"],
	"vulkin":        ["Vulkin",        "dat name hot. too hot. like me. no."],
	"snowdrake":     ["Snowdrake",     "What do you call a name you can't use? A COLD one!"],
	"loox":          ["Loox",          "Pick on someone ELSE's name!"],
	"vegetoid":      ["Vegetoid",      "Consume... name... must not... consume name..."],
	"froggit":       ["Froggit",       "Ribbit... (Translation: please no.)"],
	"whimsun":       ["Whimsun",       "eek..."],
	"glyde":         ["Glyde",         "Oh? Taking MY name? How... elegant. Still no."],
	"sosorry":       ["So Sorry",      "Oh! Oh no... that's mine... I'm so sorry for saying no..."],
	"knightknight":  ["Knight Knight", "zzzZZZ... (even asleep she says no)"],
	"monsterboy":    ["Monster Kid",   "Yo that's like... my name dude. Not cool. Well kinda cool."],
	"midas":         ["Midas",         "Everything you touch turns to... a bad decision."],
	# DELTARUNE — WRONG GAME
	"noelle":        ["???",           "wrong game lol"],
	"kris":          ["???",           "wrong game lol"],
	"susie":         ["???",           "wrong game lol"],
	"ralsei":        ["???",           "wrong game lol"],
	"lancer":        ["???",           "wrong game (but respect for the chad)"],
	"jevil":         ["???",           "I CAN DO ANYTHING! ...in a different game."],
	"spamton":       ["???",           "BIG SHOT! Wrong game! [[CALL NOW]]"],
	# SOUL TRAITS
	"determination": ["Sans",          "heh. yeah. you got that."],
	"patience":      ["Toriel",        "A good virtue. But not quite a name, dear."],
	"bravery":       ["Undyne",        "BRAVERY! I RESPECT IT! But no!"],
	"justice":       ["Undyne",        "NOW THAT'S WHAT I'M TALKING ABOUT!! Still no."],
	"kindness":      ["Toriel",        "How wonderful. It's a value dear, not a name."],
	"perseverance":  ["Alphys",        "o-oh! that's actually really nice? but still no..."],
	"integrity":     ["Undyne",        "INTEGRITY! I LIKE YOU ALREADY! Name's still taken tho."],
	# CONCEPTS
	"love":          ["Sans",          "you sure you know what that word means here?"],
	"lv":            ["Sans",          "...yeah. thought so."],
	"exp":           ["Sans",          "execution points. not a great name, kid."],
	"kill":          ["Flowey",        "ooh, going for THAT ending already?"],
	"die":           ["Toriel",        "...let us not speak of such things."],
	"murder":        ["Undyne",        "HEY. NOT COOL. AT ALL."],
	"genocide":      ["Chara",         "..."],
	"mercy":         ["Toriel",        "Always, my child. Always."],
	"spare":         ["Toriel",        "That's always the answer, isn't it?"],
	"help":          ["Sans",          "heh. wouldn't that be nice."],
	"nothing":       ["Sans",          "yeah. feels like that sometimes."],
	"empty":         ["Flowey",        "how fitting."],
	"end":           ["Flowey",        "Oh? Going for THAT ending already?"],
	"hope":          ["Toriel",        "What a beautiful thought. But not a name, dear."],
	"dream":         ["Asriel",        "...I used to dream too."],
	"broken":        ["Chara",         "..."],
	"lost":          ["Toriel",        "You'll never be lost with me here."],
	"found":         ["Toriel",        "How wonderful."],
	"time":          ["???",           "t̸i̸m̷e̷ ̷i̷s̸ ̸r̴e̸l̵a̷t̴i̷v̷e̷"],
	"space":         ["???",           "s̷p̷a̷c̷e̷ ̷i̷s̷ ̷b̷e̷t̷w̷e̷e̷n̷ ̷u̷s̷"],
	"memory":        ["Asriel",        "...I remember everything."],
	"forget":        ["Sans",          "some things you can't forget. trust me."],
	"begin":         ["Toriel",        "Every journey begins somewhere, my child."],
	# FOOD
	"spaghetti":     ["Papyrus",       "THE GREAT PAPYRUS APPROVES THE TASTE BUT NOT THE NAME!"],
	"pasta":         ["Papyrus",       "NOW THAT IS A MAGNIFICENT NAME!!! ...no wait."],
	"pie":           ["Toriel",        "How about some butterscotch-cinnamon pie while you think?"],
	"cake":          ["Toriel",        "Sweet. But no, dear."],
	"ketchup":       ["Sans",          "now THAT'S my kind of name."],
	"pizza":         ["Papyrus",       "DOES IT COME WITH EXTRA CHEESE?!"],
	"cookie":        ["Toriel",        "Sweet. But no."],
	"coffee":        ["Sans",          "don't mind if i do. still can't use it though."],
	"tea":           ["Toriel",        "Would you like some while you think of another?"],
	"donut":         ["Papyrus",       "DONUT EVEN THINK ABOUT USING THAT NAME!!! ...get it?"],
	"burger":        ["Burgerpants",   "I make those. My life is a nightmare. Pick another name."],
	# ELEMENTS
	"fire":          ["Grillby",       "..."],
	"water":         ["Undyne",        "THAT'S BASICALLY MY ELEMENT! No."],
	"ice":           ["Sans",          "cool."],
	"earth":         ["Flowey",        "Original. Really."],
	"wind":          ["Napstablook",   "oh... that's kind of nice... but it's not a name for you..."],
	"storm":         ["Undyne",        "THAT'S MY WHOLE PERSONALITY! No!"],
	"snow":          ["Papyrus",       "I LIVE IN SNOWDIN! VERY RELEVANT! Still no."],
	"star":          ["Mettaton",      "That's practically MY name, darling."],
	"moon":          ["Toriel",        "How poetic, dear."],
	"sun":           ["Asgore",        "...warmth. Yes. But no."],
	"rock":          ["Papyrus",       "LIKE ROCK AND ROLL?! NYEH HEH HEH! No."],
	# INTERNET CULTURE
	"bruh":          ["Sans",          "heh. valid response to everything."],
	"based":         ["Sans",          "heh. thanks. still no."],
	"sigma":         ["Flowey",        "Oh PLEASE."],
	"alpha":         ["Undyne",        "THAT'S MORE LIKE IT! ...still no though."],
	"rizz":          ["Mettaton",      "Darling, I INVENTED that concept."],
	"yeet":          ["Undyne",        "THAT'S WHAT I DO TO MY SPEARS! No name tho."],
	"uwu":           ["Alphys",        "o-oh my..."],
	"owo":           ["Alphys",        "w-what's this?!"],
	"sus":           ["Sans",          "yeah that name's suspicious alright."],
	"vibes":         ["Sans",          "good ones. bad name tho."],
	"lmao":          ["Sans",          "heh heh heh. no."],
	"omg":           ["Papyrus",       "SAME!!!! but no."],
	"gg":            ["Sans",          "game's not over yet, kid."],
	"rip":           ["Sans",          "heh. rest in pieces. still no."],
	"oof":           ["Sans",          "big oof. no name for you."],
	"npc":           ["Flowey",        "Is that what you think we are? ...rude."],
	"404":           ["Alphys",        "E-ERROR! That's not— that doesn't even— HOW?!"],
	"skill":         ["Undyne",        "YOU NEED MORE OF IT TO PICK A BETTER NAME!"],
	"noob":          ["Papyrus",       "NYEH! The Great Papyrus will teach better name-picking!"],
	# EXISTENTIAL
	"undertale":     ["Flowey",        "oh you sweet little meta child."],
	"toby":          ["Sans",          "heh. good taste."],
	"game":          ["Flowey",        "You think this is a game? ...well. yes. but still."],
	"player":        ["Flowey",        "oh. you KNOW. interesting."],
	"human":         ["Toriel",        "You are already a human, my dear."],
	"monster":       ["Asgore",        "...perhaps another time."],
	"god":           ["Flowey",        "Heh. Sure you are."],
	"nobody":        ["Sans",          "heh. relatable."],
	"someone":       ["Toriel",        "You are always someone to me, my child."],
	# ROLE/CLASS
	"king":          ["Asgore",        "...I suppose that's fitting. But it's taken."],
	"queen":         ["Toriel",        "...that is not my title anymore."],
	"knight":        ["Undyne",        "NOW WE'RE TALKING! But no."],
	"warrior":       ["Undyne",        "I RESPECT IT! No."],
	"hero":          ["Undyne",        "THAT'S YOU! ...eventually. Name's still no."],
	"villain":       ["Flowey",        "Finally, some honesty."],
	"ghost":         ["Napstablook",   "oh... that's kind of how i feel too..."],
	"angel":         ["Asriel",        "..."],
	# MISC FUNNY
	"hello":         ["Sans",          "hey."],
	"hi":            ["Sans",          "sup."],
	"bye":           ["Sans",          "see ya. ...wait come back."],
	"ok":            ["Sans",          "ok. ...no."],
	"yes":           ["Papyrus",       "YES!!! WAIT— THAT'S NOT A NAME!!!"],
	"no":            ["Sans",          "heh. at least you're honest."],
	"idk":           ["Alphys",        "y-you don't know your OWN name?? are you okay??"],
	"mom":           ["Toriel",        "...yes?"],
	"dad":           ["Asgore",        "...oh."],
	"bro":           ["Sans",          "hey. ...but no."],
	"sis":           ["Sans",          "nope."],
	"me":            ["Flowey",        "Narcissistic. I respect it. Still no."],
	"lol":           ["Sans",          "heh."],
	"cool":          ["Sans",          "thanks i think."],
	"lazy":          ["Sans",          "hey, i prefer 'efficiency expert'."],
	"sleep":         ["Sans",          "my favorite activity. great name. still no."],
	"nap":           ["Napstablook",   "oh... that's literally what i do..."],
	"magic":         ["Toriel",        "You have always had a touch of it, my child."],
	"science":       ["Alphys",        "FINALLY someone with taste! ...but no."],
	"math":          ["Alphys",        "o-oh! like... n-numbers? unique? but no."],
	"anime":         ["Alphys",        "o-oh... w-well... it's not NOT a good name..."],
	"cursed":        ["???",           "y̷e̸s̷."],
	"skull":         ["Sans",          "my aesthetic. still no."],
	"bones":         ["Papyrus",       "THAT IS PRACTICALLY MY MIDDLE NAME!!!"],
	"dance":         ["Mettaton",      "Now THAT'S a name I can work with! ...but no."],
	"sing":          ["Mettaton",      "♪ Oh darling ♪ No. ♪"],
	"fish":          ["Undyne",        "FISH?! I AM NOT A FISH! I AM A WARRIOR!!"],
	"saans":         ["Sans",          "close but no."],
	"snans":         ["Sans",          "okay now you're just doing it on purpose."],
	"saens":         ["Sans",          "heh. nice try."],
}

var name_text         : String = ""
var _is_transitioning : bool   = false
var _cancel_cooldown  : float  = 0.0
var _confirmed_name   : String = ""
var _is_special       : bool   = false
var _is_anos          : bool   = false


# ─────────────────────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	confirm_screen.visible  = false
	white_screen.modulate.a = 0.0
	white_screen.visible    = true
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = "Master"
	add_child(_voice_player)
	_build_letter_grid()
	_connect_action_buttons()
	btn_yes.focus_mode = Control.FOCUS_NONE
	btn_no.focus_mode  = Control.FOCUS_NONE
	btn_yes.pressed.connect(_on_yes)
	btn_no.pressed.connect(_on_no)


# ─────────────────────────────────────────────────────────────
#  BUILD LETTER GRID
# ─────────────────────────────────────────────────────────────
func _build_letter_grid() -> void:
	var font : FontFile = load(FONT_PATH)

	for ch in CHARACTERS:
		if ch == "":
			var spacer := Control.new()
			spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spacer.custom_minimum_size   = Vector2(120, 120)
			spacer.mouse_filter          = Control.MOUSE_FILTER_IGNORE
			letter_grid.add_child(spacer)
			continue

		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size   = Vector2(120, 120)
		btn.flat                  = true
		btn.focus_mode            = Control.FOCUS_NONE
		btn.text                  = ch
		if font:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 72)
		btn.add_theme_color_override("font_color",         Color(1, 1, 1, 1))
		btn.add_theme_color_override("font_hover_color",   Color(1, 1, 0.2, 1))
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 0.2, 1))
		var empty_style := StyleBoxEmpty.new()
		for s in ["normal","hover","pressed","focus","hover_pressed"]:
			btn.add_theme_stylebox_override(s, empty_style)
		btn.pressed.connect(_on_letter_pressed.bind(ch))
		letter_grid.add_child(btn)


# ─────────────────────────────────────────────────────────────
#  ACTION BUTTONS
# ─────────────────────────────────────────────────────────────
func _connect_action_buttons() -> void:
	for btn in [btn_quit, btn_backspace, btn_done]:
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_entered.connect(_on_action_focus.bind(btn))
		btn.mouse_exited.connect(_on_action_unfocus.bind(btn))
	btn_quit.pressed.connect(_on_quit)
	btn_backspace.pressed.connect(_on_backspace)
	btn_done.pressed.connect(_on_done)

func _on_action_focus(btn: Button)   -> void:
	btn.add_theme_color_override("font_color", Color(1, 1, 0.2, 1))
func _on_action_unfocus(btn: Button) -> void:
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))


# ─────────────────────────────────────────────────────────────
#  INPUT HANDLERS
# ─────────────────────────────────────────────────────────────
func _on_letter_pressed(ch: String) -> void:
	if name_text.length() >= MAX_NAME_CHARS:
		name_text = name_text.left(MAX_NAME_CHARS - 1) + ch
	else:
		name_text += ch
	name_label.text = name_text

func _on_backspace() -> void:
	if name_text.length() > 0:
		name_text = name_text.left(name_text.length() - 1)
		name_label.text = name_text

func _on_quit() -> void:
	if _is_transitioning: return
	_is_transitioning = true
	name_text = ""
	name_label.text = ""
	_fade_to_scene("res://scenes/main_menu.tscn")

func _on_done() -> void:
	if _is_transitioning: return
	if name_text.strip_edges().is_empty():
		_flash_cursor()
		return
	_confirmed_name = name_text.strip_edges()
	_show_confirmation(_confirmed_name)


# ─────────────────────────────────────────────────────────────
#  VOICE
# ─────────────────────────────────────────────────────────────
func _play_voice(speaker: String) -> void:
	var path : String = VOICE_MAP.get(speaker, VOICE_DEFAULT)
	var stream = load(path)
	if not stream:
		stream = load(VOICE_DEFAULT)
	if stream and _voice_player:
		_voice_player.stream = stream
		_voice_player.play()


# ─────────────────────────────────────────────────────────────
#  CONFIRMATION SCREEN
# ─────────────────────────────────────────────────────────────
func _show_confirmation(chosen_name: String) -> void:
	$NameInputSystem.visible = false
	confirm_screen.visible   = true

	var key     : String = chosen_name.to_lower().strip_edges()
	_is_anos    = key in ANOS_KEYS
	_is_special = SPECIAL_NAMES.has(key)

	var speaker : String
	var line    : String

	if _is_special:
		speaker = SPECIAL_NAMES[key][0]
		line    = SPECIAL_NAMES[key][1]
	else:
		speaker = "Narrator"
		line    = "* Is \"" + chosen_name + "\" the name you'll give?"

	confirm_msg.text       = speaker + ":\n" + line
	confirm_msg.modulate.a = 0.0
	confirm_name.text      = chosen_name

	confirm_name.pivot_offset = confirm_name.size / 2.0
	confirm_name.scale        = Vector2(0.08, 0.08)
	confirm_name.modulate.a   = 0.3
	confirm_name.position.y   = -320.0

	btn_yes.visible    = not _is_special
	btn_no.visible     = true
	btn_no.text        = "Back" if _is_special else "No"
	btn_yes.modulate.a = 0.0
	btn_no.modulate.a  = 0.0

	var tween := create_tween().set_parallel(false)
	tween.tween_property(confirm_name, "modulate:a",  1.0,               0.12)
	tween.tween_property(confirm_name, "scale",       Vector2(1.1, 1.1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(confirm_name, "position:y",  0.0,               0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_shake_name)
	tween.tween_interval(0.18)
	tween.tween_property(confirm_name, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_interval(0.1)
	tween.tween_property(confirm_msg, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func(): _play_voice(speaker))
	tween.tween_interval(0.25)
	if not _is_special:
		tween.tween_property(btn_yes, "modulate:a", 1.0, 0.18)
	tween.tween_property(btn_no, "modulate:a", 1.0, 0.18)


func _shake_name() -> void:
	var origin := confirm_name.position
	var s      : float = 18.0
	var t      := create_tween()
	t.tween_property(confirm_name, "position", origin + Vector2(s,      0), 0.05)
	t.tween_property(confirm_name, "position", origin + Vector2(-s,     0), 0.05)
	t.tween_property(confirm_name, "position", origin + Vector2(s*0.5,  0), 0.04)
	t.tween_property(confirm_name, "position", origin + Vector2(-s*0.5, 0), 0.04)
	t.tween_property(confirm_name, "position", origin,                      0.04)


# ─────────────────────────────────────────────────────────────
#  YES / NO
# ─────────────────────────────────────────────────────────────
func _on_yes() -> void:
	if _is_transitioning: return
	_is_transitioning = true

	if has_node("/root/SavM"):
		var sav = get_node("/root/SavM")
		sav.data["player_name"]     = "Anos" if _is_anos else _confirmed_name
		sav.data["chapter"]         = 1
		sav.data["current_scene"]   = "start"
		sav.data["voldigoad_route"] = _is_anos
		sav.save()

	if has_node("/root/SavSlots"):
		var slots = get_node("/root/SavSlots")
		slots.save_slot(0)
		if _is_anos:
			slots.init_voldigoad_folder()

	if has_node("/root/AudioM"):
		get_node("/root/AudioM").fade_out_bgm(0.5)

	var tween := create_tween()
	tween.tween_property(white_screen, "modulate:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/chapter1.tscn")


func _on_no() -> void:
	if _voice_player: _voice_player.stop()
	confirm_screen.visible   = false
	btn_yes.visible          = true
	btn_no.text              = "No"
	$NameInputSystem.visible = true


# ─────────────────────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────────────────────
func _flash_cursor() -> void:
	var tween := create_tween()
	tween.tween_property(cursor_label, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
	tween.tween_property(cursor_label, "modulate", Color(1, 1,   1,   1), 0.1)
	tween.tween_property(cursor_label, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
	tween.tween_property(cursor_label, "modulate", Color(1, 1,   1,   1), 0.1)

func _process(delta: float) -> void:
	if _cancel_cooldown > 0.0:
		_cancel_cooldown -= delta

func _input(event: InputEvent) -> void:
	if _is_transitioning: return
	if confirm_screen.visible: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE:
			_on_backspace(); _cancel_cooldown = 0.15; return
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			_on_done(); return
	if event.is_action_pressed("ui_cancel") and _cancel_cooldown <= 0.0:
		_on_backspace(); _cancel_cooldown = 0.15

func _fade_to_scene(scene_path: String) -> void:
	if has_node("/root/AudioM"):
		get_node("/root/AudioM").fade_out_bgm(0.4)
	fade_anim.play("FadeOut")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file(scene_path)
