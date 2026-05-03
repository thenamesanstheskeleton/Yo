extends Node

# =====================================================
#  sav-slots.gd  —  Save Slot Manager
#  Autoload as "SavSlots" in Project Settings!!
#
#  Lightweight — only stores WHAT exists per slot
#  Full game data lives in sav-m.gd (SavM)
#
#  3 save slots total
#  Each slot stores:
#    - exists (bool)
#    - chapter reached
#    - scene key
#    - LV
#    - playtime (seconds)
#    - timestamp (Unix time)
#    - harsh flags summary (for display)
# =====================================================

const SLOTS_PATH  : String = "/storage/emulated/0/Documents/undertale-vn/saveslots.save"
const SAVE_DIR    : String = "/storage/emulated/0/Documents/undertale-vn"
const SLOT_COUNT  : int    = 3       # ← change to add more slots

# ── SLOT DATA ─────────────────────────────────────────
var slots : Array = []

# ── CURRENT ACTIVE SLOT ───────────────────────────────
var active_slot : int = 0            # which slot is loaded right now

# =====================================================
#  _ready — load slots on startup
# =====================================================
func _ready() -> void:
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_init_slots()
	load_slots()

func _init_slots() -> void:
	slots.clear()
	for i in SLOT_COUNT:
		slots.append(_empty_slot())

func _empty_slot() -> Dictionary:
	return {
		"exists"    : false,
		"chapter"   : 1,
		"scene"     : "start",
		"lv"        : 1,
		"playtime"  : 0,       # seconds played
		"timestamp" : 0,       # Unix time of last save
		"harsh_any" : false,   # true if any harsh flag was set
	}

# =====================================================
#  SAVE — write active slot from SavM data
# =====================================================
func save_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		push_error("SavSlots: invalid slot index " + str(slot_index))
		return

	# Pull summary data from SavM
	slots[slot_index] = {
		"exists"    : true,
		"chapter"   : SavM.data.get("chapter", 1),
		"scene"     : SavM.data.get("current_scene", "start"),
		"lv"        : SavM.data.get("lv", 1),
		"playtime"  : SavM.data.get("playtime", 0),
		"timestamp" : Time.get_unix_time_from_system(),
		"harsh_any" : _any_harsh(),
	}

	active_slot = slot_index

	# Point SavM to correct slot path before saving
	SavM.SAVE_PATH = SAVE_DIR + "/save_slot_" + str(slot_index) + ".save"
	SavM.save()

	# Save slot summary separately
	_write_slots()
	print("💾 Slot " + str(slot_index + 1) + " saved!")

# =====================================================
#  LOAD — load a slot into SavM
# =====================================================
func load_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false
	if not slots[slot_index]["exists"]:
		print("SavSlots: slot " + str(slot_index + 1) + " is empty")
		return false

	active_slot = slot_index

	# Point SavM to this slot's save file and load it
	var slot_path = SAVE_DIR + "/save_slot_" + str(slot_index) + ".save"
	SavM.load_from_path(slot_path)

	print("📂 Slot " + str(slot_index + 1) + " loaded!")
	return true

# =====================================================
#  DELETE a slot
# =====================================================
func delete_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return
	slots[slot_index] = _empty_slot()
	var slot_path = SAVE_DIR + "/save_slot_" + str(slot_index) + ".save"
	if FileAccess.file_exists(slot_path):
		DirAccess.remove_absolute(slot_path)
	_write_slots()
	print("🗑️ Slot " + str(slot_index + 1) + " deleted!")

# =====================================================
#  GET DISPLAY INFO — for UI
#  Returns a human-readable dict for each slot
# =====================================================
func get_display(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return {}
	var s = slots[slot_index]
	if not s["exists"]:
		return {
			"exists"   : false,
			"label"    : "— EMPTY —",
			"detail"   : "",
			"time_str" : "",
		}

	return {
		"exists"   : true,
		"label"    : "Chapter " + str(s["chapter"]) + "  ·  LV " + str(s["lv"]),
		"detail"   : _scene_display(s["scene"]),
		"time_str" : _format_time(s["timestamp"]),
		"harsh"    : s["harsh_any"],
		"playtime" : _format_playtime(s["playtime"]),
	}

# =====================================================
#  HAS ANY SAVE — used by MainMenu to show CONTINUE
# =====================================================
func has_any_save() -> bool:
	for s in slots:
		if s["exists"]:
			return true
	return false

func get_most_recent_slot() -> int:
	var latest_time = -1
	var latest_idx  = -1
	for i in SLOT_COUNT:
		if slots[i]["exists"] and slots[i]["timestamp"] > latest_time:
			latest_time = slots[i]["timestamp"]
			latest_idx  = i
	return latest_idx

# =====================================================
#  INTERNAL HELPERS
# =====================================================

func _any_harsh() -> bool:
	var flags = SavM.data.get("harsh_flags", {})
	for key in flags:
		if flags[key]:
			return true
	return false

func _scene_display(scene_key: String) -> String:
	# Human-readable scene names for save slot UI
	var names : Dictionary = {
		"start"               : "Snowdin — Sentry Post",
		"ch1_papyrus_incoming": "Snowdin — Forest Path",
		"ch1_pap_ambush"      : "Snowdin — Ambush Tree",
		"ch1_snowdin_arrive"  : "Snowdin — Town Square",
		"ch1_house_approach"  : "Snowdin — Skeleton House",
		"ch1_house_inside"    : "Snowdin — Living Room",
		"ch1_end"             : "Snowdin — Chapter 1 End",
	}
	return names.get(scene_key, scene_key)

func _format_time(unix_time: int) -> String:
	if unix_time == 0:
		return ""
	var dt = Time.get_datetime_dict_from_unix_time(unix_time)
	return "%02d/%02d/%04d" % [dt["day"], dt["month"], dt["year"]]

func _format_playtime(seconds: int) -> String:
	var h : int = seconds / 3600
	var m : int = (seconds % 3600) / 60
	if h > 0:
		return str(h) + "h " + str(m) + "m"
	return str(m) + "m"

# =====================================================
#  FILE I/O
# =====================================================

# =====================================================
#  VOLDIGOAD ROUTE — creates folder + route flag file
# =====================================================
func init_voldigoad_folder() -> void:
	var vdir : String = SAVE_DIR + "/voldigoad"
	if not DirAccess.dir_exists_absolute(vdir):
		DirAccess.make_dir_recursive_absolute(vdir)
	# Write route config file
	var route_data : Dictionary = {
		"active"         : true,
		"vessel"         : "Anos Voldigoad",
		"route_version"  : 1,
		"dialogue_style" : "anos",
		"unlocked_at"    : Time.get_unix_time_from_system(),
		"description"    : "The Demon King route. Dialogue shifts. Characters react differently. This is Anos Voldigoad's story now.",
	}
	var file = FileAccess.open(vdir + "/route.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(route_data, "\t"))
		file.close()
		print("👑 Voldigoad Route initialized at: " + vdir)

func is_voldigoad_route() -> bool:
	var vdir : String = SAVE_DIR + "/voldigoad/route.json"
	if not FileAccess.file_exists(vdir):
		return false
	var file = FileAccess.open(vdir, FileAccess.READ)
	if not file: return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed is Dictionary and parsed.get("active", false)

func _write_slots() -> void:
	var file = FileAccess.open(SLOTS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(slots))
		file.close()

func load_slots() -> void:
	if not FileAccess.file_exists(SLOTS_PATH):
		return
	var file = FileAccess.open(SLOTS_PATH, FileAccess.READ)
	if file:
		var raw    = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(raw)
		if parsed and parsed.size() == SLOT_COUNT:
			slots = parsed
