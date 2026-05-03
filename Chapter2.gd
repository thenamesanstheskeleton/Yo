extends Node

# =====================================================
#  scripts/data/Chapter2.gd
#  DIALOGUE DATA — "A Morning in Snowdin"
#
#  Used by: Chapter2.gd (scene script)
#  Loaded via: const CHAPTER_DATA = preload("res://scripts/data/Chapter2.gd")
#
#  PATCH LOG:
#    - yesterday_seq: BGM now stops before title. Narration removed (was playing
#      during black screen). Chapter2.gd resumes after the animation.
#    - waterfall_scene: Double Undyne interaction removed. After she leaves, all
#      scenes following Undyne's exit are replaced with waterfall environment
#      narration + Sans alone (blank.png) + mysterious hint + shortcut exit.
#    - back_home: Split into two routes gated by event "route_back_home".
#      Chapter2.gd handles this: if SavM.data["bonedows_opened"] == true,
#      goto "back_home_with_computer"; else goto "back_home_no_computer".
#    - chapter3_wait_end: Fires "chapter2_done" event so Chapter2.gd can
#      write SavM.data["chapter2_done"] = true and SavM.data["chapter"] = 3.
# =====================================================

const BG     = "res://assets/images/backgrounds/new/"
const PAP    = "res://assets/images/characters/papyrus_merged/"
const SANS   = "res://assets/images/characters/sans_merged/"
const UNDYNE = "res://assets/images/characters/undyne_armor/"
const BGM    = "res://assets/audio/bgm/"
const SFX    = "res://assets/audio/sfx/"
const EXTRA  = "res://assets/audio/extra/audio/"


const DATA : Dictionary = {

	# ═══════════════════════════════════════════════════
	# START — Wake up in Papyrus's room
	# ═══════════════════════════════════════════════════
	"start": [
		{ "type":"scene",
		  "bg": BG + "skele_house_papyrus_room.png",
		  "bgm": BGM + "snowdin_town.mp3" },

		{ "type":"narration",
		  "text":"You open your eyes." },
		{ "type":"narration",
		  "text":"The ceiling is white. The room smells like laundry detergent and something vaguely floral. There is a poster directly above you that says NEVER GIVE UP in letters large enough to be legally considered signage." },
		{ "type":"narration",
		  "text":"You are in a race car bed." },
		{ "type":"narration",
		  "text":"You are, technically, a prisoner." },
		{ "type":"narration",
		  "text":"The bed has flames on it." },
		{ "type":"narration",
		  "text":"You are okay." },

		{ "type":"choice", "options":[
			{ "text":"Look around the room.", "goto":"room_explore" },
			{ "text":"Try to go back to sleep.", "goto":"sleep_attempt" },
		]},
	],

	"sleep_attempt": [
		{ "type":"narration",
		  "text":"You close your eyes." },
		{ "type":"narration",
		  "text":"The poster radiates at you through your eyelids." },
		{ "type":"narration",
		  "text":"NEVER GIVE UP." },
		{ "type":"narration",
		  "text":"You get up." },
		{ "type":"goto", "goto":"room_explore" },
	],

	# ═══════════════════════════════════════════════════
	# ROOM EXPLORATION HUB
	# ═══════════════════════════════════════════════════
	"room_explore": [
		{ "type":"narration",
		  "text":"The room is aggressively clean. The kind of clean that has a schedule." },
		{ "type":"narration",
		  "text":"A folded cape hangs on the chair. A box of paper rockets sits by the desk. Everything in here looks like it was arranged, reconsidered, and arranged again." },
		{ "type":"narration",
		  "text":"Even the dust seems afraid to settle in the wrong place." },

		{ "type":"choice", "options":[
			{ "text":"Check the bookshelf.", "goto":"bookshelf" },
			{ "text":"Look at the action figures.", "goto":"action_figures" },
			{ "text":"Look out the window.", "goto":"window_look" },
			{ "text":"Check the closet.", "goto":"closet_check" },
			{ "text":"Study the desk calendar.", "goto":"calendar_check" },
			{ "type":"separator" },
			{ "text":"Use the computer.", "goto":"bonedows_check" },
			{ "text":"Go downstairs.", "goto":"go_downstairs" },
		]},
	],

	"bookshelf": [
		{ "type":"narration",
		  "text":"Puzzle Theory. Cooking for Champions. One suspiciously battered copy of 'How to Make Friends: A Guide for Skeletons.'" },
		{ "type":"narration",
		  "text":"Someone has read that last one many times. You can tell by the spine." },
		{ "type":"narration",
		  "text":"Behind a row of books — small. Easy to miss. A sticky note, folded twice." },
		{ "type":"sfx", "src": EXTRA + "item.wav" },
		{ "type":"narration",
		  "text":"'IN CASE I FORGET: PASSWORD = IAMTHEGREATPAPYRUS1'" },
		{ "type":"narration",
		  "text":"'(BACKUP NOTE. VERY SECRET. DO NOT READ — T.G.P.)'" },
		{ "type":"narration",
		  "text":"You have the password. You did not need to try very hard." },
		{ "type":"event", "id":"flag_password_found" },
		{ "type":"goto", "goto":"room_explore" },
	],

	"action_figures": [
		{ "type":"narration",
		  "text":"A row of action figures stands in perfect formation on the shelf. Each one is facing forward. Each one has been dusted recently." },
		{ "type":"narration",
		  "text":"One of them is holding a tiny handmade flag that says THE GREAT PAPYRUS on it in very small letters." },
		{ "type":"narration",
		  "text":"You tilt one of the figures forward. There is a note taped to the back." },
		{ "type":"sfx", "src": EXTRA + "item.wav" },
		{ "type":"narration",
		  "text":"'Backup password note — in case the bookshelf note is lost. Password: IAMTHEGREATPAPYRUS1. Do not tell Sans.'" },
		{ "type":"narration",
		  "text":"You feel like you are witnessing a very elaborate system of self-trust." },
		{ "type":"event", "id":"flag_password_found" },
		{ "type":"goto", "goto":"room_explore" },
	],

	"window_look": [
		{ "type":"narration",
		  "text":"Outside, Snowdin is still. The kind of still that means the weather is thinking about doing something." },
		{ "type":"narration",
		  "text":"The sky is the wrong shade of grey. Not ordinary grey. Anticipatory grey." },
		{ "type":"narration",
		  "text":"Somewhere under all that cloud, there is a lot of snow waiting to happen." },
		{ "type":"narration",
		  "text":"Far away, the white line of a waterfall cuts through the dark like a seam." },
		{ "type":"narration",
		  "text":"You cannot see the bridge from here, but you can already imagine the cold wet sound of it." },
		{ "type":"goto", "goto":"room_explore" },
	],

	"closet_check": [
		{ "type":"narration",
		  "text":"The closet is not large, but it is extremely organized. Coats hang by color. Scarves are folded. There is a tiny basket for gloves." },
		{ "type":"narration",
		  "text":"Papyrus has even labeled a shelf: HUMAN WINTER OPTIONS." },
		{ "type":"narration",
		  "text":"Inside are a blanket, a spare scarf, and a paper tag that reads 'in case the human gets cold or dramatic'." },
		{ "type":"event", "id":"flag_closet_warmth" },
		{ "type":"narration",
		  "text":"You decide not to tell him that the tag made you laugh." },
		{ "type":"goto", "goto":"room_explore" },
	],

	"calendar_check": [
		{ "type":"narration",
		  "text":"The desk calendar is full of notes written in extremely enthusiastic handwriting." },
		{ "type":"narration",
		  "text":"TODAY: MAKE BREAKFAST. CHECK ON HUMAN. WIN AT BEING RESPONSIBLE." },
		{ "type":"narration",
		  "text":"TOMORROW: PUZZLE PRACTICE. CALL UNDYNE. REMEMBER TO ASK SANS WHERE HE LEFT THE KEYS." },
		{ "type":"narration",
		  "text":"A date later in the week is circled twice: WATERFALL PATROL. PREPARE FOR EVERYTHING." },
		{ "type":"event", "id":"flag_calendar_seen" },
		{ "type":"narration",
		  "text":"The last line is written smaller than the rest: 'do not worry the human.' It has been crossed out and rewritten twice." },
		{ "type":"goto", "goto":"room_explore" },
	],

	# ═══════════════════════════════════════════════════
	# BONEDOWS PC INTERACTION
	# ═══════════════════════════════════════════════════
	"bonedows_check": [
		{ "type":"narration",
		  "text":"The computer hums. The wallpaper is a skull. Everything is labeled in caps." },
		{ "type":"event", "id":"bonedows_open" },
		# Chapter2.gd pauses VNEngine here. Bonedows opens as overlay.
		# On close, Chapter2.gd sets SavM.data["bonedows_opened"] = true then resumes.
		{ "type":"narration",
		  "text":"You close the computer." },
		{ "type":"goto", "goto":"room_explore" },
	],

	# ═══════════════════════════════════════════════════
	# GO DOWNSTAIRS
	# ═══════════════════════════════════════════════════
	"go_downstairs": [
		{ "type":"sfx", "src": EXTRA + "footsteps.mp3" },
		{ "type":"narration",
		  "text":"The stairs creak once, then settle. The house has memorized your footsteps already." },
		{ "type":"scene",
		  "bg": BG + "skele_house_interior.png",
		  "bgm": BGM + "bonetrousle.mp3" },
		{ "type":"narration",
		  "text":"The hallway opens into warmth, light, and the smell of breakfast planning." },
		{ "type":"goto", "goto":"living_room" },
	],

	# ═══════════════════════════════════════════════════
	# LIVING ROOM — Papyrus watching TV
	# ═══════════════════════════════════════════════════
	"living_room": [
		{ "type":"narration",
		  "text":"Papyrus is on the couch. He is watching a cooking show with the focused intensity of someone studying for a final exam. The chef on screen is explaining béchamel. Papyrus has a notepad." },
		{ "type":"narration",
		  "text":"Then the screen glitches." },
		{ "type":"sfx", "src": EXTRA + "static.wav" },
		{ "type":"narration",
		  "text":"Then static." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"...THE SIGNAL IS DOING SOMETHING STRANGE." },
		{ "type":"narration",
		  "text":"He closes the notepad with the energy of someone deciding to table a very important discussion." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HUMAN." },
		{ "type":"narration",
		  "text":"He turns. He looks at you the way a general addresses a new recruit who has shown up at the wrong time but at least showed up." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"YOU ARE MY PRISONER. WHICH MEANS IT IS MY RESPONSIBILITY TO ENSURE YOU ARE FED, WARM, AND NOT ATTEMPTING TO ESCAPE." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"I TAKE MY RESPONSIBILITIES VERY SERIOUSLY." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"DO YOU LIKE PANCAKES?" },

		{ "type":"choice", "options":[
			{ "text":"Yes!", "goto":"pancake_yes" },
			{ "text":"Not really.", "goto":"pancake_no" },
			{ "text":"I prefer spaghetti.", "goto":"pancake_spaghetti" },
		]},
	],

	"pancake_yes": [
		{ "type":"narration",
		  "text":"A microsecond of something crosses his face. Not disappointment. More like the specific expression of a man who thought everyone preferred spaghetti and is now confronting contradictory data." },
		{ "type":"narration",
		  "text":"He recovers immediately." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THEN PANCAKES IT SHALL BE!" },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"THE GREAT PAPYRUS CANNOT BE STOPPED BY A BREAKFAST REQUEST!!" },
		{ "type":"goto", "goto":"kitchen_arrive" },
	],

	"pancake_no": [
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"...YOU DON'T LIKE PANCAKES." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"NOTED." },
		{ "type":"narration",
		  "text":"He writes something on the notepad. You cannot see what." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THE GREAT PAPYRUS WILL MAKE PANCAKES ANYWAY. PERHAPS YOUR OPINION WILL CHANGE UPON WITNESSING THEIR QUALITY." },
		{ "type":"goto", "goto":"kitchen_arrive" },
	],

	"pancake_spaghetti": [
		{ "type":"narration",
		  "text":"Papyrus freezes." },
		{ "type":"narration",
		  "text":"Something in his expression short-circuits. He stares. He stares for a full three seconds." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "enchanted.png",
		  "text":"..." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "enchanted.png",
		  "text":"YOU HAVE EXCELLENT TASTE." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"WE ARE STILL MAKING PANCAKES. I HAVE ALREADY DECIDED." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"BUT I WILL NOTE THAT YOU HAVE EXCELLENT TASTE. FOLLOW ME!" },
		{ "type":"goto", "goto":"kitchen_arrive" },
	],

	# ═══════════════════════════════════════════════════
	# KITCHEN — Cooking begins
	# ═══════════════════════════════════════════════════
	"kitchen_arrive": [
		{ "type":"scene",
		  "bg": BG + "Skele_house_kitchen.png",
		  "bgm": BGM + "bonetrousle.mp3" },

		{ "type":"narration",
		  "text":"The kitchen is a monument to noodles." },
		{ "type":"narration",
		  "text":"Noodle boxes stacked like a carbohydrate cathedral. The Great Spaghetti Pot gleaming on the stove like a throne. A Royal Guard Sauce jar on the shelf that has been opened so many times the label is mostly just texture now." },
		{ "type":"narration",
		  "text":"Papyrus ties his apron. He does this with the ceremony of someone putting on armor." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "smirk.png",
		  "text":"NYEH HEH HEH." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "apron.png",
		  "text":"HUMAN! THE INGREDIENTS ARE IN THE FRIDGE! RETRIEVE THEM!" },
		{ "type":"narration",
		  "text":"He points at the fridge with absolute authority." },
		{ "type":"narration",
		  "text":"The fridge is right there. You could open it. You could also just... stand here." },
		{ "type":"narration",
		  "text":"On the counter: a spice rack, recipe cards, a stack of paper stars, and a soup spoon that looks like it has survived at least one argument." },

		{ "type":"choice", "options":[
			{ "text":"Inspect the spice rack.", "goto":"spice_rack" },
			{ "text":"Read the recipe cards.", "goto":"recipe_cards" },
			{ "text":"Open the fridge.", "goto":"fridge_open" },
			{ "text":"Stare at it.", "goto":"fridge_stare_1" },
			{ "text":"Attempt escape. 👀", "goto":"fridge_escape" },
		]},
	],

	"spice_rack": [
		{ "type":"narration",
		  "text":"Papyrus labels his spices in three different ways: by name, by taste, and by what effect they will have on Sans." },
		{ "type":"narration",
		  "text":"One jar simply says 'DANGER.' Another says 'ONLY FOR HEROIC PANCAKES.' The cinnamon has glitter in it for some reason." },
		{ "type":"narration",
		  "text":"A tiny note is taped to the shelf: 'If the human seems nervous, add extra sugar. If the human seems hungry, add extra sugar. If the human seems sad, add extra sugar.' The next line says: 'THE GREAT PAPYRUS IS A SCIENTIFIC GENIUS.'" },
		{ "type":"goto", "goto":"kitchen_arrive" },
	],

	"recipe_cards": [
		{ "type":"narration",
		  "text":"The recipe cards are all written in very precise handwriting. The top card reads PANCAKES FOR BEGINNERS. Under it: PANCAKES FOR SOMEONE YOU CARE ABOUT. Under that: PANCAKES FOR SOMEONE WHO WILL SAY 'IT'S FINE' BUT WON'T MEAN IT." },
		{ "type":"narration",
		  "text":"The back of one card has a doodle of a skeleton in an apron and a little speech bubble that says 'TRY YOUR BEST.' Another says 'NO, HARDER THAN THAT.'" },
		{ "type":"event", "id":"flag_recipe_cards_seen" },
		{ "type":"goto", "goto":"kitchen_arrive" },
	],

	"fridge_open": [
		{ "type":"event", "id":"fridge_dim" },
		{ "type":"narration",
		  "text":"The fridge opens. Cold air. The interior is organized with concerning precision." },
		{ "type":"narration",
		  "text":"There is a skull drawn on one of the eggs in marker. You decide not to ask." },
		{ "type":"narration",
		  "text":"The milk carton has Papyrus's face on it. He printed it himself." },
		{ "type":"narration",
		  "text":"A sticky note on the butter reads: 'SANS, THIS IS NOT FOR KETCHUP EXPERIMENTS.'" },
		{ "type":"event", "id":"ingredients_collected" },
		{ "type":"goto", "goto":"ingredients_to_papyrus" },
	],

	"fridge_stare_1": [
		{ "type":"narration",
		  "text":"The fridge just sits there. Deeply unbothered." },
		{ "type":"event", "id":"fridge_stare_tick_1" },
		{ "type":"narration",
		  "text":"Papyrus watches you." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"...HUMAN." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"THE FRIDGE WILL NOT RESPOND TO INTENSE STARE-BASED COMMUNICATION." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"PAPYRUS ALSO ONCE STARED AT A REFRIGERATOR FOR TWENTY MINUTES." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"AND THEN HE OPENED IT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"THIS IS A TALE OF TRIUMPH. PERHAPS IT WILL INSPIRE YOU." },

		{ "type":"choice", "options":[
			{ "text":"Okay, fine. Open it.", "goto":"fridge_open" },
			{ "text":"Continue staring.", "goto":"fridge_stare_2" },
		]},
	],

	"fridge_stare_2": [
		{ "type":"event", "id":"fridge_stare_tick_2" },
		{ "type":"narration",
		  "text":"The fridge continues to not open itself. You continue to help with this." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HUMAN." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"ARE YOU PERHAPS UNCERTAIN WHICH OBJECT IS THE FRIDGE." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"IT IS THE LARGE WHITE APPLIANCE. THE ONE EMITTING COLD." },
		{ "type":"narration",
		  "text":"He waits." },
		{ "type":"narration",
		  "text":"You do not move." },
		{ "type":"goto", "goto":"fridge_papyrus_does_it" },
	],

	"fridge_papyrus_does_it": [
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"...VERY WELL." },
		{ "type":"narration",
		  "text":"Papyrus walks over. He opens the fridge. He begins collecting ingredients with the calm efficiency of someone who has adapted to unexpected situations before and will adapt again." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THE GREAT PAPYRUS ADAPTS." },
		{ "type":"event", "id":"ingredients_collected" },
		{ "type":"goto", "goto":"ingredients_to_papyrus_late" },
	],

	"fridge_escape": [
		{ "type":"narration",
		  "text":"You take one step toward the kitchen door." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "suspicious.png",
		  "text":"NO." },
		{ "type":"narration",
		  "text":"He did not even look up from the counter. You have no idea how he knew." },
		{ "type":"narration",
		  "text":"You look at the fridge. The fridge looks back." },
		{ "type":"goto", "goto":"fridge_open" },
	],

	"ingredients_to_papyrus": [
		{ "type":"narration",
		  "text":"You bring everything to Papyrus. He looks at the ingredients. He looks at you." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THAT WAS EXPECTED. YOU ARE EFFICIENT. PAPYRUS APPROVES." },
		{ "type":"goto", "goto":"cooking_start" },
	],

	"ingredients_to_papyrus_late": [
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE GREAT PAPYRUS HAS DECIDED TO BE PATIENT TODAY." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THIS IS GROWTH." },
		{ "type":"goto", "goto":"cooking_start" },
	],

	"cooking_start": [
		{ "type":"narration",
		  "text":"He takes the ingredients. He sets the bowl down with the solemnity of a ceremony." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "apron.png",
		  "text":"STAND BACK. THE GREAT PAPYRUS REQUIRES CONCENTRATION." },
		{ "type":"sfx", "src": EXTRA + "item.wav" },
		{ "type":"narration",
		  "text":"Flour. Milk. Eggs. Butter. Papyrus measures each one like it might be audited by the Royal Guard." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THE FIRST RULE OF PANCAKES IS PRECISION." },
		{ "type":"sfx", "src": EXTRA + "fireplace.wav" },
		{ "type":"narration",
		  "text":"The stove catches. A warm orange glow fills the kitchen." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "smirk.png",
		  "text":"THE SECOND RULE IS FLUFF." },
		{ "type":"narration",
		  "text":"He whisks the batter until it gives up and becomes smooth." },
		{ "type":"narration",
		  "text":"For a moment the whole room smells like breakfast instead of a battle plan." },
		{ "type":"goto", "goto":"cooking_done" },
	],

	"cooking_done": [
		{ "type":"narration",
		  "text":"The pancakes form." },
		{ "type":"narration",
		  "text":"They are, improbably, perfect circles." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "cooking.png",
		  "text":"...THEY ARE ROUND." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "enchanted.png",
		  "text":"NYEH HEH HEH!!! THE GREAT PAPYRUS HAS CONQUERED A NEW FOOD!!!" },
		{ "type":"narration",
		  "text":"He plates them. He slides them across the counter to you. He hangs the apron on its hook with the same ceremony as the putting-on." },
		{ "type":"narration",
		  "text":"The smell is sweet and warm. The sort of smell that makes a room feel less like a house and more like somewhere people belong." },
		{ "type":"event", "id":"pancakes_in_inventory" },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"EAT THOSE WHEN YOU ARE READY. THE GREAT PAPYRUS WILL ALLOW A BRIEF DIGESTION WINDOW." },
		{ "type":"goto", "goto":"papyrus_socks" },
	],

	# ═══════════════════════════════════════════════════
	# PAPYRUS LIVING ROOM — Socks moment
	# ═══════════════════════════════════════════════════
	"papyrus_socks": [
		{ "type":"scene",
		  "bg": BG + "skele_house_interior.png",
		  "bgm": BGM + "bonetrousle.mp3" },

		{ "type":"narration",
		  "text":"He walks to the living room. He looks around. He looks at the floor." },
		{ "type":"narration",
		  "text":"There is one sock. Just one. Sitting beside the couch like it is waiting for something." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"SANS." },
		{ "type":"narration",
		  "text":"He says this to no one in the room. He picks up the sock and takes it to the laundry with the quiet dignity of someone who has done this ten thousand times." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"MY BROTHER IS A BUSINESS GENIUS." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HE HAS MORE HOT DOG STANDS THAN THE KING HAS ROYAL DECREES." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"AND SOMEHOW HE CANNOT LOCATE A LAUNDRY BASKET." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THESE THINGS HAPPEN." },
		{ "type":"narration",
		  "text":"He sits down. He looks at the static TV. He doesn't turn it off. He just looks at it." },
		{ "type":"narration",
		  "text":"The room has settled again. The pancakes are warm. The house is quiet enough that every little sound feels intentional." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HE WAS EARLY TODAY." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HE IS ALWAYS EARLY WHEN SOMETHING IS HAPPENING." },
		{ "type":"narration",
		  "text":"He doesn't say what that something is." },
		{ "type":"narration",
		  "text":"He doesn't need to." },

		{ "type":"choice", "options":[
			{ "text":"Ask about Sans.", "goto":"socks_sans" },
			{ "text":"Stay quiet.", "goto":"socks_quiet" },
		]},
	],

	"socks_sans": [
		{ "type":"narration",
		  "text":"You ask whether Sans ever gets serious." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "confused.png",
		  "text":"OF COURSE HE DOES." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"IT USUALLY INVOLVES SOMEONE ELSE BEING IN DANGER, THOUGH." },
		{ "type":"narration",
		  "text":"He says it like a complaint, but not a cruel one. More like a fact he has accepted and memorized." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"HE IS AWFULLY GOOD AT ACTING LIKE NOTHING MATTERS." },
		{ "type":"goto", "goto":"yesterday_seq" },
	],

	"socks_quiet": [
		{ "type":"narration",
		  "text":"You stay quiet." },
		{ "type":"narration",
		  "text":"Papyrus seems to appreciate that more than he says." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"A VERY GOOD QUALITY IN A HOUSEGUEST." },
		{ "type":"goto", "goto":"yesterday_seq" },
	],

	# ═══════════════════════════════════════════════════
	# YESTERDAY SEQUENCE
	# FIX: BGM stops before title. No narration during black screen.
	#      Chapter2.gd handles "yesterday_title" event:
	#        - stops BGM immediately
	#        - fades to black
	#        - shows "yesterday..." with dot animation (10 sec)
	#        - fades back in
	#        - resumes VNEngine
	# ═══════════════════════════════════════════════════
	"yesterday_seq": [
		{ "type":"event", "id":"stop_bgm" },
		# BGM cut to silence here. Room is quiet before the title.
		{ "type":"event", "id":"yesterday_title" },
		# VNEngine pauses. Chapter2.gd runs the full black screen sequence.
		# When done, it resumes here. Waterfall cutscene begins next.
		{ "type":"goto", "goto":"waterfall_cut" },
	],

	# ═══════════════════════════════════════════════════
	# WATERFALL CUTSCENE TRIGGER
	# ═══════════════════════════════════════════════════
	"waterfall_cut": [
		{ "type":"event", "id":"waterfall_cutscene" },
		# Chapter2.gd loads WaterfallCutscene.tscn into CutsceneLayer.
		# On finish, Chapter2.gd resumes VNEngine and routes to back_home.
		{ "type":"goto", "goto":"back_home" },
	],

	# ═══════════════════════════════════════════════════
	# BACK HOME — Chapter close
	# FIX: Gated by "route_back_home" event.
	#      Chapter2.gd checks SavM.data["bonedows_opened"]:
	#        true  → jumps to "back_home_with_computer"
	#        false → jumps to "back_home_no_computer"
	# ═══════════════════════════════════════════════════
	"back_home": [
		{ "type":"scene",
		  "bg": BG + "skele_house_interior.png",
		  "bgm": BGM + "snowdin_town.mp3" },
		{ "type":"narration",
		  "text":"The skeleton house. Living room. Papyrus is at the window now, watching the sky." },
		{ "type":"narration",
		  "text":"The snow has started." },
		{ "type":"narration",
		  "text":"Not a storm yet. Just the first soft insistence that the day is going somewhere colder." },
		{ "type":"event", "id":"route_back_home" },
		# Chapter2.gd handles this event and jumps to the correct variant.
		# VNEngine will NOT auto-advance past this event — Chapter2.gd
		# calls engine.jump_to("back_home_with_computer") or
		# engine.jump_to("back_home_no_computer") then engine.resume().
	],

	# ── Variant A: player opened Bonedows (G may or may not be earned) ──
	"back_home_with_computer": [
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "suspicious.png",
		  "text":"HUMAN." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "suspicious.png",
		  "text":"I NOTICED SOMETHING ON THE COMPUTER EARLIER." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "suspicious.png",
		  "text":"THERE WAS A MESSAGE THAT CAME AND WENT BEFORE I COULD READ IT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "suspicious.png",
		  "text":"I DO NOT LIKE MESSAGES THAT DISAPPEAR." },
		{ "type":"narration",
		  "text":"He stares at you for a long moment." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I WILL NOT INVESTIGATE THIS FURTHER." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"BECAUSE THE GREAT PAPYRUS IS VERY HUMBLE AND DOES NOT NEED RECOGNITION." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"ALSO BECAUSE IT WAS PROBABLY JUST PAPYRUS." },
		{ "type":"goto", "goto":"back_home_close" },
	],

	# ── Variant B: player never touched Bonedows ──────
	"back_home_no_computer": [
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"HUMAN." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE BLIZZARD IS COMING FASTER THAN I CALCULATED." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I HAVE DONE EXTENSIVE CALCULATIONS." },
		{ "type":"goto", "goto":"back_home_close" },
	],

	# ── Shared closing ─────────────────────────────────
	"back_home_close": [
		{ "type":"narration",
		  "text":"He turns back to the window. The snow is coming down heavier now." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE BLIZZARD WILL BE BAD TONIGHT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"YOU ARE NOT TO GO OUTSIDE." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"THIS IS NOT A SUGGESTION. THIS IS A PRISONER REGULATION." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"EAT YOUR PANCAKES. GET SOME REST." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"TOMORROW I HAVE PUZZLES TO CHECK." },
		{ "type":"narration",
		  "text":"He says this like it's ordinary. Like there isn't a waterfall conversation he hasn't mentioned, and a human in his house, and a whole world making weather decisions outside." },
		{ "type":"narration",
		  "text":"Like everything is fine." },
		{ "type":"narration",
		  "text":"You look at your pancakes." },
		{ "type":"narration",
		  "text":"The first bite is warm enough to feel like a promise." },
		{ "type":"narration",
		  "text":"Outside, the snow keeps falling." },
		{ "type":"narration",
		  "text":"Snowdin is quieter before a storm." },
		{ "type":"narration",
		  "text":"Everything is." },
		{ "type":"goto", "goto":"chapter2_epilogue" },
	],

	"chapter2_epilogue": [
		{ "type":"narration",
		  "text":"Papyrus busies himself with tiny things after that. A plate. A towel. The curtain tie. Anything that keeps his hands moving." },
		{ "type":"narration",
		  "text":"He keeps standing by the window like he expects someone to knock. Or arrive. Or both." },
		{ "type":"narration",
		  "text":"You get the feeling this is one of those days that will matter later, even if nobody says why right now." },
		{ "type":"narration",
		  "text":"The house grows darker by inches. The TV mutters to itself. The heater clicks. The pancakes disappear from the plate one piece at a time." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"IF YOU ARE THINKING ABOUT THE WORLD OUTSIDE, DO NOT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"AT LEAST, NOT YET." },
		{ "type":"narration",
		  "text":"He sounds serious in the way only Papyrus can: loud enough to hide concern, gentle enough to still count as concern." },
		{ "type":"narration",
		  "text":"Somewhere beyond the windows, Waterfall keeps falling." },
		{ "type":"narration",
		  "text":"Somewhere else, a message is still waiting to be read." },
		{ "type":"narration",
		  "text":"And somewhere in the middle of all of it, Sans is already pretending not to know more than he says." },
		{ "type":"narration",
		  "text":"For now, though, it is just a house, just a dinner, and just a quiet room where the next part of the story is taking its time." },
		{ "type":"narration",
		  "text":"Papyrus finally sits down again. The couch gives a tiny sigh under him." },
		{ "type":"narration",
		  "text":"He glances at you, then at the window, then at the plate, as if trying to decide which of those three things needs protecting most." },

		{ "type":"choice", "options":[
			{ "text":"Stay by the window.", "goto":"chapter2_window_watch" },
			{ "text":"Check the computer again.", "goto":"chapter2_computer_after" },
			{ "text":"Say nothing and eat.", "goto":"chapter2_pancake_after" },
		]},
	],

	"chapter2_window_watch": [
		{ "type":"narration",
		  "text":"You stand with Papyrus at the window." },
		{ "type":"narration",
		  "text":"The storm is still distant, but it is definitely coming. Snow gathers in thin lines across the roof and disappears." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I CAN WAIT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"WAITING IS A SKILL. I HAVE BEEN PRACTICING." },
		{ "type":"narration",
		  "text":"He says that with the same confidence he uses for everything else, which somehow makes it sadder." },
		{ "type":"goto", "goto":"chapter2_wait_end" },
	],

	"chapter2_computer_after": [
		{ "type":"narration",
		  "text":"The computer is still there, glowing in the dark like a polite little secret." },
		{ "type":"narration",
		  "text":"The overlay is gone, but the feeling of it lingers." },
		{ "type":"narration",
		  "text":"Recent files. A half-open memo. A folder titled MEMORY_BACKUP. Papyrus definitely saw the filename this time, and definitely pretends he did not." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"I AM CERTAIN THERE IS NOTHING IMPORTANT THERE." },
		{ "type":"narration",
		  "text":"He says it while staring at the screen." },
		{ "type":"goto", "goto":"chapter2_wait_end" },
	],

	"chapter2_pancake_after": [
		{ "type":"narration",
		  "text":"You eat in silence." },
		{ "type":"narration",
		  "text":"Papyrus watches exactly long enough to make sure you really did try them, then looks away as if that was the whole point." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"GOOD." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THAT IS THE SOUND OF A SUCCESSFUL DAY." },
		{ "type":"goto", "goto":"chapter2_wait_end" },
	],

	"chapter2_wait_end": [
		{ "type":"narration",
		  "text":"The room settles again." },
		{ "type":"narration",
		  "text":"The snow taps softly at the glass." },
		{ "type":"narration",
		  "text":"Papyrus sits very still for one rare second, as if listening to the whole house at once." },
		{ "type":"narration",
		  "text":"The heater clicks. The curtain shifts. Somewhere under the floorboards, the house answers back in tiny wooden noises." },
		{ "type":"narration",
		  "text":"Then he smiles, a little smaller than usual, and the story gives you just enough time to breathe." },
		{ "type":"choice", "options":[
			{ "text":"Listen to the heater.", "goto":"chapter2_heater_listen" },
			{ "text":"Open the curtain.", "goto":"chapter2_curtain_open" },
			{ "text":"Stack the plates.", "goto":"chapter2_plate_stack" },
			{ "text":"Sit with Papyrus.", "goto":"chapter2_sit_with_papyrus" },
			{ "text":"Read the note.", "goto":"chapter2_read_note" },
			{ "text":"Turn off the lamp.", "goto":"chapter2_lamp_off" },
		]},
	],

	"chapter2_heater_listen": [
		{ "type":"narration",
		  "text":"The heater is a low steady hum. It sounds a lot like a house trying its best to stay kind." },
		{ "type":"narration",
		  "text":"Papyrus glances over and catches you listening." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"A VERY RESPECTABLE USE OF TIME." },
		{ "type":"narration",
		  "text":"He says it like he means it." },
		{ "type":"narration",
		  "text":"The warmth in the room settles into your shoulders and refuses to leave." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_curtain_open": [
		{ "type":"narration",
		  "text":"You pull the curtain aside just enough to see the snow." },
		{ "type":"narration",
		  "text":"The flakes are tiny at first. Then they are not tiny at all. Then they are simply everywhere, as if the sky has decided to keep going until the world is white enough to hide secrets in." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"YOU SEE?" },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I WAS CORRECT TO WORRY." },
		{ "type":"narration",
		  "text":"He says 'worry' like it's an ingredient in a recipe he would rather not admit he uses." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_plate_stack": [
		{ "type":"narration",
		  "text":"You stack the plates neatly." },
		{ "type":"narration",
		  "text":"Papyrus watches, approvingly dramatic." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"EXCELLENT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"THE GREAT PAPYRUS RESPECTS A PERSON WHO CAN ORGANIZE A TABLE." },
		{ "type":"narration",
		  "text":"It is hard not to laugh. You fail a little, and he notices, but chooses not to make a scene of it." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_sit_with_papyrus": [
		{ "type":"narration",
		  "text":"You sit on the couch beside him." },
		{ "type":"narration",
		  "text":"The cushion dips. Papyrus shifts, just enough to make room without ever saying he made room." },
		{ "type":"narration",
		  "text":"For a while, neither of you speaks. The heater hums. The snow grows heavier. The TV keeps pretending to be awake." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"...THANK YOU." },
		{ "type":"narration",
		  "text":"He says it quietly, which is almost rarer than hearing him whisper." },
		{ "type":"narration",
		  "text":"You do not answer. He doesn't seem to need one." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_read_note": [
		{ "type":"narration",
		  "text":"There is a note on the side table, folded into a sharp little triangle so it can stand by itself." },
		{ "type":"narration",
		  "text":"It reads: 'If anything happens, keep the human inside.' Underneath, in a different hand, is another line: 'They are already inside. Good. Great. Wonderful. - P.'" },
		{ "type":"narration",
		  "text":"Papyrus notices what you're doing and looks away too quickly to be accidental." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I WASN'T WORRIED." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"...I WAS BEING PREPARED." },
		{ "type":"narration",
		  "text":"That is somehow worse and better at the same time." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_lamp_off": [
		{ "type":"narration",
		  "text":"You switch off the lamp." },
		{ "type":"narration",
		  "text":"The room doesn't become dark all at once. It eases into evening. The window, the TV, the heater light, and Papyrus's red scarf all keep a little bit of shape alive." },
		{ "type":"narration",
		  "text":"Papyrus glances over, then nods as if this was the correct way for the room to end the day." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"A VERY DECENT CHOICE." },
		{ "type":"narration",
		  "text":"The silence that follows is not empty. It is waiting." },
		{ "type":"narration",
		  "text":"You can hear Snowdin through the walls in the tiniest possible ways." },
		{ "type":"narration",
		  "text":"For one slow second, the whole house feels like it is holding its breath with you." },
		{ "type":"goto", "goto":"chapter2_wait_final" },
	],

	"chapter2_wait_final": [
		{ "type":"narration",
		  "text":"For a moment, the house feels balanced again." },
		{ "type":"narration",
		  "text":"Not safe, not exactly. Just balanced — like a spoon resting on the edge of a bowl, like a promise waiting to be spoken, like the next chapter taking a careful breath." },
		{ "type":"narration",
		  "text":"That is enough for now." },
		{ "type":"goto", "goto":"chapter2_final_echo" },
	],

	"chapter2_final_echo": [
		{ "type":"narration",
		  "text":"The room stays warm for a little while longer, even after the words run out." },
		{ "type":"narration",
		  "text":"The next chapter is not here yet." },
		{ "type":"goto", "goto":"chapter3_wait" },
	],

	# ═══════════════════════════════════════════════════
	# CHAPTER 3 WAITING SCREEN
	# Chapter2.gd handles "chapter2_done" event:
	#   SavM.data["chapter2_done"] = true
	#   SavM.data["chapter"] = 3
	#   SavSlots.save_slot(SavSlots.active_slot)
	#   → Show "coming soon" overlay instead of crashing
	# ═══════════════════════════════════════════════════
	"chapter3_wait": [
		{ "type":"scene",
		  "bg": BG + "skele_house_interior.png",
		  "bgm": BGM + "snowdin_town.mp3" },
		{ "type":"narration",
		  "text":"The house is quiet in the way a room gets quiet after a story has technically ended but nobody believes it." },
		{ "type":"event", "id":"wait_started" },
		{ "type":"narration",
		  "text":"Papyrus notices the silence, then pretends he has always been excellent at noticing silence." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE NEXT PART OF THE DAY MAY TAKE A MOMENT." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THIS IS CALLED PATIENCE. I HAVE INVENTED IT." },
		{ "type":"narration",
		  "text":"He has not invented it. He has merely weaponized it with style." },
		{ "type":"narration",
		  "text":"The computer blinks from the table. The clock keeps time. Snow presses its cold face against the windows." },
		{ "type":"choice", "options":[
			{ "text":"Wait quietly.", "goto":"chapter3_wait_quiet" },
			{ "text":"Open Bonedows.", "goto":"chapter3_wait_bonedows" },
			{ "text":"Check the window.", "goto":"chapter3_wait_window" },
			{ "text":"Listen to the hallway.", "goto":"chapter3_wait_hallway" },
		]},
	],

	"chapter3_wait_quiet": [
		{ "type":"narration",
		  "text":"You wait quietly." },
		{ "type":"narration",
		  "text":"The heater hums. The house settles. The silence becomes a thing with edges." },
		{ "type":"narration",
		  "text":"Papyrus does not rush to fill it. That is how you know he understands the moment is fragile." },
		{ "type":"narration",
		  "text":"Outside, Snowdin keeps turning white in the dark." },
		{ "type":"narration",
		  "text":"Inside, the pancakes cool down one exact degree at a time." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"YOU ARE DOING VERY WELL AT THIS." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"WAITING IS HARDER THAN IT LOOKS." },
		{ "type":"goto", "goto":"chapter3_wait_end" },
	],

	"chapter3_wait_bonedows": [
		{ "type":"narration",
		  "text":"You open Bonedows again." },
		{ "type":"narration",
		  "text":"The little OS wakes up like it had been holding its breath and only now remembered to be dramatic about it." },
		{ "type":"narration",
		  "text":"Files. Mail. Quiz. Hidden Folder. Very Secret. The icons all wait in a neat little row like they are trying to look innocent." },
		{ "type":"event", "id":"bonedows_open" },
		{ "type":"narration",
		  "text":"Papyrus leans just far enough to pretend he is not reading over your shoulder." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I SEE THAT YOUR COMPUTER IS... DOING COMPUTER THINGS." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THAT IS FINE. I ALSO DO THINGS." },
		{ "type":"goto", "goto":"chapter3_wait_end" },
	],

	"chapter3_wait_window": [
		{ "type":"narration",
		  "text":"You look out the window again." },
		{ "type":"narration",
		  "text":"The sky is darker now. The snow is denser. The world outside has gone from 'weather' to 'message.'" },
		{ "type":"narration",
		  "text":"Far away, Waterfall is only a thought now. The bridge. The water. The armored figure that left with purpose instead of answers." },
		{ "type":"narration",
		  "text":"Papyrus stands beside you without crowding the view." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE WEATHER LOOKS COMMITTED." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I RESPECT THAT. I DO NOT ENJOY IT, BUT I RESPECT IT." },
		{ "type":"narration",
		  "text":"That is the most Papyrus sentence possible and somehow exactly right." },
		{ "type":"goto", "goto":"chapter3_wait_end" },
	],

	"chapter3_wait_hallway": [
		{ "type":"narration",
		  "text":"You listen to the hallway." },
		{ "type":"narration",
		  "text":"The house answers in tiny sounds. A floorboard. A vent. A thread of heater noise. Something like a sock sliding against wood somewhere impossible." },
		{ "type":"narration",
		  "text":"Sans is somewhere in the house, probably acting as if 'somewhere' is not a useful answer." },
		{ "type":"narration",
		  "text":"Papyrus tilts his head as if he heard the same thing and decided it would be rude to identify it aloud." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THE HOUSE IS SETTLING." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THIS IS A NORMAL THING HOUSES DO. PROBABLY." },
		{ "type":"narration",
		  "text":"He says 'probably' like he is not fully convinced by the word but wants it on the record anyway." },
		{ "type":"goto", "goto":"chapter3_wait_end" },
	],

	"chapter3_wait_end": [
		{ "type":"narration",
		  "text":"The waiting finally has a shape." },
		{ "type":"narration",
		  "text":"Not an answer. Not a fight. Just a pause long enough to notice that the next chapter is already taking aim." },
		{ "type":"narration",
		  "text":"Papyrus folds his arms and watches the room like it might try something." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"I WILL HOLD THE LINE FOR NOW." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"THAT IS WHAT PEOPLE DO WHEN THEY CARE." },
		{ "type":"narration",
		  "text":"The house does not reply. It does not need to." },
		# FIX: chapter2_done event — Chapter2.gd handles this:
		#   SavM.data["chapter2_done"] = true
		#   SavM.data["chapter"] = 3
		#   SavSlots.save_slot(SavSlots.active_slot)
		#   engine.jump_to("chapter3_coming_soon")
		{ "type":"event", "id":"chapter2_done" },
	],

	# ── Chapter 3 coming soon screen ──────────────────
	# Chapter2.gd jumps here after chapter2_done event
	# so the player sees a message instead of a crash.
	"chapter3_coming_soon": [
		{ "type":"scene",
		  "bg": BG + "skele_house_interior.png",
		  "bgm": BGM + "snowdin_town.mp3" },
		{ "type":"narration",
		  "text":"The storm is still going." },
		{ "type":"narration",
		  "text":"It will be going for a while." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"..." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "pose.png",
		  "text":"CHAPTER THREE IS COMING." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "happy.png",
		  "text":"THE GREAT PAPYRUS HAS BEEN INFORMED." },
		{ "type":"dialogue", "name":"Papyrus", "char": PAP + "neutral.png",
		  "text":"UNTIL THEN — REST. THE PANCAKES ARE STILL WARM." },
		{ "type":"narration",
		  "text":"Your save has been recorded." },
		{ "type":"narration",
		  "text":"Chapter 3 — coming soon." },
		{ "type":"event", "id":"chapter_end" },
		# Chapter2.gd handles chapter_end: return to main menu or freeze on this screen.
	],


	# ═══════════════════════════════════════════════════
	# WATERFALL CUTSCENE DATA
	# Used by WaterfallCutscene.gd directly.
	#
	# FIX: After Undyne says "look after Papyrus" and leaves,
	#      ALL subsequent Undyne scenes and interactions are removed.
	#      Replaced with: waterfall environment narration → Sans alone
	#      (blank.png) → mysterious hint → shortcut SFX → he's gone.
	# ═══════════════════════════════════════════════════
	"waterfall_scene": [
		{ "type":"scene",
		  "bg": BG + "waterfall.png",
		  "bgm": BGM + "waterfall.mp3" },
		{ "type":"sfx", "src": EXTRA + "waterwalk.wav" },
		{ "type":"narration",
		  "text":"The first thing you notice is the cold." },
		{ "type":"narration",
		  "text":"The second thing is the water, everywhere, turning the whole place into a whisper that never stops moving." },
		{ "type":"narration",
		  "text":"The third thing is the bridge." },

		{ "type":"scene",
		  "bg": BG + "waterfall_cascade_bridge.png",
		  "bgm": BGM + "waterfall.mp3" },
		{ "type":"sfx", "src": EXTRA + "waterwalk.wav" },
		{ "type":"narration",
		  "text":"Footsteps. Heavy. Deliberate. Each one landing like a declaration." },

		{ "type":"scene",
		  "bg": BG + "waterfall_sentry_echo_flower.png",
		  "bgm": BGM + "waterfall.mp3" },

		{ "type":"narration",
		  "text":"Sans is at his station. Hot dog in hand. Expression: unchanged." },
		{ "type":"narration",
		  "text":"She stops." },
		{ "type":"narration",
		  "text":"Every inch of her says she has already decided what she's here to do and just needs to finish the conversation first." },

		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"SANS." },
		{ "type":"narration",
		  "text":"The echo flowers nearby quietly repeat it. Sans. Sans. Sans." },
		{ "type":"narration",
		  "text":"He takes a bite of the hot dog." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"hey." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"I GOT WORD FROM PAPYRUS." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"HE FOUND A NEW FRIEND." },
		{ "type":"narration",
		  "text":"The word 'friend' lands in the air between them like something much heavier than it sounds." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"CARE TO TELL ME WHAT KIND OF FRIEND?" },
		{ "type":"narration",
		  "text":"Sans chews. He swallows." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"the friendly kind." },
		{ "type":"narration",
		  "text":"Undyne's eye twitches." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"SANS." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"THE KING HAS BEEN WAITING." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"THE WHOLE UNDERGROUND HAS BEEN WAITING." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_serious.png",
		  "text":"AND YOU'RE STANDING HERE. EATING A HOT DOG." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"it's a pretty good hot dog." },
		{ "type":"narration",
		  "text":"She stares at him." },
		{ "type":"narration",
		  "text":"He is not joking. He is also not not joking." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_irritated.png",
		  "text":"IF YOU ARE HIDING SOMETHING —" },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_irritated.png",
		  "text":"IF WHATEVER YOU ARE DOING IS GOING TO BRING THIS ALL DOWN —" },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_irritated.png",
		  "text":"I WILL NOT CONSIDER OUR FRIENDSHIP BEFORE I ACT." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_irritated.png",
		  "text":"DO YOU UNDERSTAND ME?" },
		{ "type":"narration",
		  "text":"Sans looks at her. Not through her. At her. For just a moment something behind his eyes is paying very close attention." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"yeah." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"i hear you." },
		{ "type":"narration",
		  "text":"He finishes the hot dog." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "pleased.png",
		  "text":"you know, undyne — you've really got a... pointed argument." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "pleased.png",
		  "text":"must be all that armor." },
		{ "type":"narration",
		  "text":"Beat." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_neutral.png",
		  "text":"...what." },
		{ "type":"narration",
		  "text":"She replays it." },
		{ "type":"narration",
		  "text":"She gets it." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_irritated.png",
		  "text":"I SWEAR ON EVERY SPEAR I OWN —" },
		{ "type":"narration",
		  "text":"She turns. Cloak sweeping. Already walking." },
		{ "type":"narration",
		  "text":"Then she stops. Just for a second. Doesn't look back." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_leaving.png",
		  "text":"...look after Papyrus." },
		{ "type":"dialogue", "name":"Undyne", "char": UNDYNE + "undyne_armor_leaving.png",
		  "text":"I don't want him anywhere near this." },
		{ "type":"narration",
		  "text":"A pause that lasts exactly one beat longer than comfortable." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"he already picked up my sock this morning." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "neutral.png",
		  "text":"so he's ahead of you." },

		# ── UNDYNE IS GONE. Everything below is Sans alone. ──────────────

		{ "type":"narration",
		  "text":"She leaves." },
		{ "type":"narration",
		  "text":"The echo flowers whisper her footsteps back for a few seconds, then go quiet." },

		# Environment narration — the waterfall after she's gone.
		{ "type":"narration",
		  "text":"The water keeps falling." },
		{ "type":"narration",
		  "text":"It has been falling for longer than anyone in this conversation has been alive, and it will keep falling after all of them are gone." },
		{ "type":"narration",
		  "text":"It does not care about promises. It does not care about soul counts. It just goes down, and down, and down, and fills every silence with the sound of something that has nowhere else to be." },
		{ "type":"narration",
		  "text":"The echo flowers say nothing for a while. Even they seem to know this part is not for them." },

		# Sans alone — blank.png — hollow, not vacant.
		{ "type":"dialogue", "name":"Sans", "char": SANS + "blank.png",
		  "text":"..." },
		{ "type":"narration",
		  "text":"He stares at the water. His expression is not the usual nothing." },
		{ "type":"narration",
		  "text":"It is a different kind of nothing. The kind that has seen too many versions of the same conversation to find any of them surprising anymore." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "blank.png",
		  "text":"you know the funny thing about timelines?" },
		{ "type":"narration",
		  "text":"He isn't talking to Undyne. She's gone." },
		{ "type":"narration",
		  "text":"He isn't talking to the echo flowers." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "blank.png",
		  "text":"they all think they're the first one." },
		{ "type":"narration",
		  "text":"The water answers him with water." },
		{ "type":"dialogue", "name":"Sans", "char": SANS + "blank.png",
		  "text":"every single time." },
		{ "type":"narration",
		  "text":"He picks up the hot dog wrapper. Folds it once. Puts it in his pocket." },
		{ "type":"narration",
		  "text":"He does not look at anything in particular for exactly one second." },
		{ "type":"narration",
		  "text":"Then he is not there." },

		# Shortcut SFX — he's gone.
		{ "type":"sfx", "src": SFX + "shortcut.wav" },

		{ "type":"narration",
		  "text":"The echo flowers remember the shape of where he stood." },
		{ "type":"narration",
		  "text":"Then they forget that too." },
		{ "type":"narration",
		  "text":"The waterfall keeps going." },

		{ "type":"event", "id":"waterfall_done" },
		{ "type":"goto", "goto":"back_home" },
	],

}
