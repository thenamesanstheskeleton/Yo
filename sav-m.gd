extends Node

# =====================================================
#  SAV-M.gd  (SaveManager)
#  Autoload this in Project Settings!
#  Tracks: scene, LV/EXP, choices, relationships,
#          harsh flags, sans promise strain
# =====================================================

# ── SAVE FILE PATH ────────────────────────────────────
# Stored in Documents/undertale-vn/ — accessible via ZArchiver, no root
const SAVE_DIR  : String = "/storage/emulated/0/Documents/undertale-vn"
var   SAVE_PATH : String = "/storage/emulated/0/Documents/undertale-vn/save_slot_0.save"

# ── PLAYTIME TRACKING ─────────────────────────────────
var _session_start : float = 0.0

# ── DEFAULT STATE ─────────────────────────────────────
# This is what a brand new game looks like
var data : Dictionary = {

	# ── Progress ──────────────────────────────────────
	"current_scene"  : "start",
	"chapter"        : 1,

	# ── Undertale Stats ───────────────────────────────
	"lv"             : 1,
	"exp"            : 0,
	"player_name"    : "Frisk",

	# ── Relationships (0-100, starts at 50 = neutral) ─
	# Drop below 30 = cold/hostile dialogue kicks in
	# Above 70 = warmer dialogue unlocks
	"relationships"  : {
		"sans"   : 50,
		"undyne" : 50,
		"toriel" : 50,
	},

	# ── Harsh Flags (permanent, never reset) ──────────
	# Set to true the moment player is cruel once
	"harsh_flags" : {
		"sans_harsh_1"    : false,  # First time cold to Sans
		"sans_harsh_2"    : false,  # Second time — he notices
		"undyne_hostile"  : false,  # Undyne stops listening to Sans
		"toriel_distant"  : false,  # Toriel grows cold/sad
	},

	# ── Sans Promise Strain ───────────────────────────
	# Hidden counter 0-100
	# 0   = he's keeping it no problem
	# 50  = his dialogue gets quieter, more tired
	# 80  = he sounds like he's running out of reasons
	# 100 = breaking point — unique dialogue triggers
	"sans_promise_strain" : 0,

	# ── Choice Log ────────────────────────────────────
	# Every major choice stored as key:value
	# e.g. "ch1_spaghetti": "yes"
	"choices" : {},

	# ── Seen Scenes (for skip on reload) ──────────────
	"seen_scenes" : [],

	# ── Playtime (seconds) ────────────────────────────
	"playtime" : 0,

	# ── Inventory ─────────────────────────────────────
	# Items player has collected
	# key = item_id, value = quantity
	"inventory" : {},

	# ── Explored rooms (for hover memory) ────────────
	# Tracks what the player has already examined
	"examined" : [],

	# ── Chapter 2 flags ───────────────────────────────
	"c2_bonedows_password_found" : false,
	"c2_bookshelf_puzzle_solved" : false,
	"c2_fridge_opened"           : false,
	"c2_ingredients_taken"       : false,
	"c2_papyrus_repeated"        : 0,     # how many times papyrus repeated himself
	"c2_pancakes_received"       : false,
}

# =====================================================
#  _ready — start session timer
# =====================================================
func _ready() -> void:
	# Ensure save directory exists on first run
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_session_start = Time.get_ticks_msec() / 1000.0

# =====================================================
#  LOAD FROM SPECIFIC PATH (called by SavSlots)
# =====================================================
func load_from_path(path: String) -> bool:
	SAVE_PATH = path
	return load_save()

# =====================================================
#  SAVE
# =====================================================
func save() -> void:
	# Update playtime before saving
	var elapsed = (Time.get_ticks_msec() / 1000.0) - _session_start
	data["playtime"] = data.get("playtime", 0) + int(elapsed)
	_session_start = Time.get_ticks_msec() / 1000.0
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Game saved!")
	else:
		print("❌ Save failed!")

# =====================================================
#  LOAD
# =====================================================
func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found — starting fresh")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var raw = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(raw)
		if parsed:
			# Merge loaded data INTO defaults
			# (so new keys added later don't break old saves)
			for key in parsed:
				data[key] = parsed[key]
			print("✅ Save loaded!")
			return true

	print("❌ Load failed!")
	return false

# =====================================================
#  HELPERS — call these from anywhere
# =====================================================

# Record a choice the player made
# e.g. SaveManager.record_choice("ch1_spaghetti", "yes")
func record_choice(key: String, value: String) -> void:
	data["choices"][key] = value

# Check a choice
# e.g. SaveManager.get_choice("ch1_spaghetti") -> "yes"
func get_choice(key: String) -> String:
	return data["choices"].get(key, "")

# Change a relationship score (+/- amount)
# e.g. SaveManager.change_relationship("sans", -15)
func change_relationship(character: String, amount: int) -> void:
	if data["relationships"].has(character):
		var current = data["relationships"][character]
		data["relationships"][character] = clamp(current + amount, 0, 100)

# Get relationship score
func get_relationship(character: String) -> int:
	return data["relationships"].get(character, 50)

# Set a harsh flag permanently
# e.g. SaveManager.set_harsh("undyne_hostile")
func set_harsh(flag: String) -> void:
	if data["harsh_flags"].has(flag):
		data["harsh_flags"][flag] = true
		print("⚠️ Harsh flag set: " + flag)

# Check a harsh flag
func is_harsh(flag: String) -> bool:
	return data["harsh_flags"].get(flag, false)

# Increase Sans promise strain
# e.g. SaveManager.strain_sans(20)
func strain_sans(amount: int) -> void:
	data["sans_promise_strain"] = clamp(
		data["sans_promise_strain"] + amount, 0, 100
	)
	print("💀 Sans strain: " + str(data["sans_promise_strain"]))

# Get Sans strain level as a label
func get_sans_strain_level() -> String:
	var s = data["sans_promise_strain"]
	if s >= 100: return "broken"
	if s >= 80:  return "barely"
	if s >= 50:  return "tired"
	return "keeping"

# Add EXP and auto-level up (Undertale style)
func add_exp(amount: int) -> void:
	data["exp"] += amount
	_check_levelup()

func _check_levelup() -> void:
	# Undertale LV thresholds (approximate)
	var thresholds = [0,10,30,70,120,200,300,500,800,1000,
					  1200,1500,1800,2100,2500,3000,3500,4000,5000,9999]
	var lv = 1
	for i in thresholds.size():
		if data["exp"] >= thresholds[i]:
			lv = i + 1
	if lv > data["lv"]:
		data["lv"] = lv
		print("⬆️ LOVE increased to " + str(lv))

# ── INVENTORY HELPERS ─────────────────────────────────────────
func add_item(item_id: String, qty: int = 1) -> void:
	var current = data["inventory"].get(item_id, 0)
	data["inventory"][item_id] = current + qty
	print("🎒 Got: " + item_id + " x" + str(qty))

func remove_item(item_id: String, qty: int = 1) -> bool:
	var current = data["inventory"].get(item_id, 0)
	if current < qty:
		return false
	data["inventory"][item_id] = current - qty
	if data["inventory"][item_id] <= 0:
		data["inventory"].erase(item_id)
	return true

func has_item(item_id: String, qty: int = 1) -> bool:
	return data["inventory"].get(item_id, 0) >= qty

func get_item_count(item_id: String) -> int:
	return data["inventory"].get(item_id, 0)

func mark_examined(thing_id: String) -> void:
	if thing_id not in data["examined"]:
		data["examined"].append(thing_id)

func has_examined(thing_id: String) -> bool:
	return thing_id in data["examined"]

func set_flag(flag_key: String, value) -> void:
	data[flag_key] = value

func get_flag(flag_key: String, default = false):
	return data.get(flag_key, default)

# ── Mark a scene as seen
func mark_seen(scene_key: String) -> void:
	if scene_key not in data["seen_scenes"]:
		data["seen_scenes"].append(scene_key)

func has_seen(scene_key: String) -> bool:
	return scene_key in data["seen_scenes"]

# Full reset (new game)
func reset() -> void:
	data["current_scene"]      = "start"
	data["chapter"]            = 1
	data["lv"]                 = 1
	data["exp"]                = 0
	data["player_name"]        = "Frisk"
	data["relationships"]      = {"sans": 50, "undyne": 50, "toriel": 50}
	data["harsh_flags"]        = {
		"sans_harsh_1"   : false,
		"sans_harsh_2"   : false,
		"undyne_hostile" : false,
		"toriel_distant" : false,
	}
	data["sans_promise_strain"] = 0
	data["choices"]             = {}
	data["seen_scenes"]         = []
	data["playtime"]            = 0
	_session_start              = Time.get_ticks_msec() / 1000.0
	print("🔄 Game reset!")
