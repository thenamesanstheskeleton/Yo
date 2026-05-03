extends Node

# =====================================================
#  chapter1.gd  —  SCRIPT DATA
#  All paths use res://assets/images/characters/
#  and res://assets/images/backgrounds/new/
#  and res://assets/audio/
# =====================================================

# ── SHORTHAND PATH HELPERS ────────────────────────────
const BG   = "res://assets/images/backgrounds/new/"
const SANS = "res://assets/images/characters/sans_merged/"
const SANSO= "res://assets/images/characters/sans_merged/" # all in sans_merged now
const PAP  = "res://assets/images/characters/papyrus_merged/"
const SFX  = "res://assets/audio/sfx/"
const BGM  = "res://assets/audio/bgm/"

# =====================================================
#  CHAPTER 1 SCRIPT DATA
# =====================================================
const DATA : Dictionary = {

  # ───────────────────────────────────────────────────
  #  OPENING — Sans asleep at post
  # ───────────────────────────────────────────────────
  "start": [
	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_sentry_station.png",
	  "bgm": BGM + "sans_theme.mp3",
	  "char": SANS+"sleepy.png" },

	{ "type":"dialogue", "name":"???", "char": SANS+"sleepy.png",
	  "text":"z z z ..." },
	{ "type":"dialogue", "name":"???", "char": SANS+"sleepy.png",
	  "text":"zzzzz ..." },

	{ "type":"narration",
	  "text":"You clear your throat. Loudly." },
	{ "type":"narration",
	  "text":"Nothing." },
	{ "type":"narration",
	  "text":"You try again. Louder." },

	{ "type":"dialogue", "name":"???", "char": SANS+"neutral.png",
	  "text":"huh...?" },
	{ "type":"dialogue", "name":"???", "char": SANS+"neutral.png",
	  "text":"oh. hey." },
	{ "type":"dialogue", "name":"???", "char": SANS+"confident.png",
	  "text":"caught me napping. don't tell my brother." },
	{ "type":"narration",
	  "text":"He says this with the energy of someone who has said it many times before and will say it many times again." },

	{ "type":"choice", "options":[
	  { "text":"Who are you?",              "goto":"ch1_name"  },
	  { "text":"You're a sentry? Really?",  "goto":"ch1_mock"  },
	  { "text":"...",                        "goto":"ch1_quiet" },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_name": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"name's sans. sans the skeleton." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"royal sentry. in theory." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"the staying-awake part is... optional, apparently." },
	{ "type":"narration",
	  "text":"He says 'apparently' like this is information he is still waiting to receive official confirmation on." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"heard a human was coming through eventually." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"didn't know it'd be today." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"or that you'd wake me up about it." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"wanna hear a joke?" },
	{ "type":"choice", "options":[
	  { "text":"Sure.",        "goto":"ch1_joke_yes" },
	  { "text":"Maybe later.", "goto":"ch1_joke_no"  },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_joke_yes": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"what do you call a skeleton who won't do any work?" },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"lazy bones." },
	{ "type":"narration",
	  "text":"He gestures at himself. You sigh. He looks absolutely delighted." },
	{ "type":"narration",
	  "text":"He did not make this joke for you. He made it because it was there and he had nothing better to do. You just happened to be in the blast radius." },
	{ "type":"goto", "goto":"ch1_papyrus_incoming" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_joke_no": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"fair enough." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"i'll save them for the walk." },
	{ "type":"narration",
	  "text":"This is either a threat or a promise. Possibly both." },
	{ "type":"goto", "goto":"ch1_papyrus_incoming" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_mock": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"technically, yes." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"sentrying involves a lot of standing around." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"i'm excellent at that part." },
	{ "type":"narration",
	  "text":"He lets that sit for a moment. No elaboration. No defense. Just a man at complete peace with his professional legacy." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"name's sans, by the way. since we're judging each other." },
	{ "type":"goto", "goto":"ch1_papyrus_incoming" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_quiet": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"okay." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"i'm sans. i respect the silence." },
	{ "type":"narration",
	  "text":"He means it. He goes back to doing absolutely nothing. Comfortably. Professionally." },
	{ "type":"goto", "goto":"ch1_papyrus_incoming" },
  ],

  # ───────────────────────────────────────────────────
  #  PAPYRUS ENTERS
  # ───────────────────────────────────────────────────
  "ch1_papyrus_incoming": [
	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_forest_sign_post.png",
	  "bgm": BGM + "bonetrousle.mp3",
	  "char": "" },

	{ "type":"narration",
	  "text":"Distant. Armored boots on compacted snow. Getting louder. Very fast." },
	{ "type":"narration",
	  "text":"Getting VERY fast." },

	{ "type":"dialogue", "name":"???",     "char": PAP+"angry.png",
	  "text":"SANS!!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"YOU WERE ASLEEP AT YOUR POST. AGAIN." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I COULD HEAR THE SNORING FROM THE TOWN SQUARE." },
	{ "type":"dialogue", "name":"Sans",
	  "char_left": SANS+"confident.png", "char_right": PAP+"suspicious.png",
	  "text":"i was just resting my eye sockets." },
	{ "type":"dialogue", "name":"Papyrus",
	  "char_left": SANS+"nothappy.png", "char_right": PAP+"confused.png",
	  "text":"YOU DON'T HAVE EYELIDS!!" },
	{ "type":"dialogue", "name":"Sans",
	  "char_left": SANS+"nothappy.png", "char_right": PAP+"suspicious.png",
	  "text":"exactly. extremely hard to close." },

	{ "type":"sfx", "src": SFX+"rimshot.mp3", "vol":0.7 },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"suspicious.png",
	  "text":"THAT IS NOT —" },

	{ "type":"narration",
	  "text":"Papyrus notices you. His entire posture changes instantly." },
	{ "type":"narration",
	  "text":"It is like watching a search light rotate." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"AH! A HUMAN!!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I, THE GREAT PAPYRUS, SHALL CAPTURE YOU. GENTLY." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"PREPARE YOURSELF, HUMAN!!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"NYEH HEH HEH!" },

	{ "type":"choice", "options":[
	  { "text":"Nice to meet you, Papyrus.",  "goto":"ch1_pap_nice"      },
	  { "text":"Please don't do that.",       "goto":"ch1_pap_plead"     },
	  { "text":"(Look to Sans for help)",     "goto":"ch1_pap_sans_help" },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_nice": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"embaras.png",
	  "text":"...OH." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pleased.png",
	  "text":"THAT IS SURPRISINGLY POLITE FOR A HUMAN." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"IT DOES NOT CHANGE YOUR CAPTURED STATUS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"happy.png",
	  "text":"BUT I ACKNOWLEDGE IT WARMLY." },
	{ "type":"goto", "goto":"ch1_pap_converge" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_plead": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"'PLEASE DON'T' IS NOT IN THE RULEBOOK OF CAPTURE!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"embaras.png",
	  "text":"THOUGH I APPRECIATE THE MANNERS." },
	{ "type":"goto", "goto":"ch1_pap_converge" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_sans_help": [
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"shrug.png",
	  "text":"don't look at me." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"sideeye.png",
	  "text":"he's been planning this for months." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"MONTHS OF RIGOROUS TRAINING AND PREPARATION, SANS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"DO NOT MINIMIZE THE PROCESS." },
	{ "type":"goto", "goto":"ch1_pap_converge" },
  ],

  # ───────────────────────────────────────────────────
  #  PAPYRUS LEAVES — Sans alone with player
  # ───────────────────────────────────────────────────
  "ch1_pap_converge": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pleased.png",
	  "text":"NOW. I MUST FINISH MY PATROL BEFORE ESCORTING YOU." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"THE GREAT PAPYRUS IS NOTHING IF NOT THOROUGH." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"SANS. DO. NOT. LET. THEM. ESCAPE." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"nothappy.png",
	  "text":"sure, bro." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"NYEH HEH HEH!!" },

	{ "type":"sfx", "src": SFX+"footsteps.mp3", "vol":0.8 },
	{ "type":"narration",
	  "text":"He disappears into the snowstorm at an alarming sprint, cape billowing behind him like a very loud flag." },
	{ "type":"narration",
	  "text":"The snow settles. The silence returns." },

	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_forest_path.png",
	  "bgm": BGM + "sans_theme.mp3",
	  "char": SANS+"confident.png" },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"so." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"that's papyrus." },
	{ "type":"narration",
	  "text":"He watches the direction his brother vanished with the expression of someone watching a house fire that is technically not their problem." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"he's been trying to join the royal guard for a while now." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"undyne keeps finding reasons to delay the evaluation." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"he thinks she's being thorough." },
	{ "type":"narration",
	  "text":"A pause." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"she is. just not about him." },
	{ "type":"narration",
	  "text":"He doesn't elaborate. He doesn't need to. Papyrus would try to befriend the enemy and then invite them to dinner. Undyne is aware of this." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"anyway." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"play along with him, yeah?" },

	{ "type":"choice", "options":[
	  { "text":"Sure.",           "goto":"ch1_agree_playalong"  },
	  { "text":"Why should I?",   "goto":"ch1_refuse_playalong" },
	]},
  ],

  # ── AGREE — neutral/kind response ───────────────────
  "ch1_agree_playalong": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"means a lot to him." },
	{ "type":"narration",
	  "text":"He says it like a footnote. Something filed away and not worth expanding on." },
	{ "type":"goto", "goto":"ch1_dog_incident" },
  ],

  # ── REFUSE — first harsh flag moment ────────────────
  # NOTE: This is the FIRST relationship check point!
  # Call SavM.change_relationship("sans", -8) here
  # Call SavM.strain_sans(10) here
  "ch1_refuse_playalong": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"no reason." },
	{ "type":"narration",
	  "text":"He says this like he's closing a door." },
	{ "type":"narration",
	  "text":"Not slamming it. Just... closing it. Quietly. With the latch." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"snowdin's up ahead. try not to get lost." },
	# ↓ VNEngine will check SavM here and flag sans_harsh_1
	{ "type":"relationship_hit", "char":"sans", "amount":-8, "strain":10, "flag":"sans_harsh_1" },
	{ "type":"goto", "goto":"ch1_dog_incident" },
  ],

  # ───────────────────────────────────────────────────
  #  THE ANNOYING DOG INCIDENT
  # ───────────────────────────────────────────────────
  "ch1_dog_incident": [
	{ "type":"narration",
	  "text":"He goes quiet. Not the comfortable kind. The kind where someone is replaying events and still cannot explain them." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"...so. papyrus built you a puzzle." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"three days. path between here and town." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"bones. pressure plates. pre-recorded dramatic monologue on a little speaker." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"fog machine." },

	{ "type":"narration", "text":"You blink." },
	{ "type":"narration", "text":"He had a fog machine." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"the annoying dog sat on it this morning." },

	{ "type":"narration", "text":"You wait for more context. Surely there is more context." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"just. walked up. sat down. right in the middle of it." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"absorbed it." },

	{ "type":"narration", "text":"...absorbed it." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"bones. plates. speaker. fog machine." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"gone." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"inside the dog." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"while papyrus was still setting it up." },

	{ "type":"narration",
	  "text":"You open your mouth. Close it. There are no words." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"papyrus tried to shoo it. forty minutes." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"clapping. stomping. stern talking-to." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"dog did not move." },

	{ "type":"narration", "text":"Of course it didn't." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"so papyrus made it a plate of spaghetti." },

	{ "type":"narration", "text":"You stare at him." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"to coax it out." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"full plate. his best batch." },

	{ "type":"narration", "text":"His BEST batch." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"dog ate the spaghetti." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"went back inside the puzzle." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"to sleep." },

	{ "type":"narration",
	  "text":"You are losing the battle against laughing. You can feel it happening in real time." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"yeah." },

	{ "type":"narration",
	  "text":"He watches you struggle. He has the energy of someone who already processed all five stages of grief about this and came out the other side completely flat." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"shook.png",
	  "text":"papyrus also made a laminated map of the full puzzle layout." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"shook.png",
	  "text":"colour coded. with a legend." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"shook.png",
	  "text":"in case you needed hints." },

	{ "type":"narration", "text":"You already know where this is going." },
	{ "type":"narration", "text":"You KNOW. And it still gets you." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"dog ate the laminated map." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"went back inside the puzzle." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy2.png",
	  "text":"to sleep more." },

	{ "type":"narration", "text":"SILENCE." },
	{ "type":"narration",
	  "text":"The kind that only exists after something very small has caused an unreasonable amount of damage." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"papyrus is fine." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"already designing puzzle two." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"more bones. bigger speaker. two fog machines." },

	{ "type":"narration", "text":"Two." },
	{ "type":"narration", "text":"He ordered TWO fog machines." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"he will not mention the dog." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"if you bring up the dog he will deny the dog." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"he will look you dead in the eyes and tell you the puzzle went perfectly." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"there was no dog." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"the fog machine worked great." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"nothappy.png",
	  "text":"you were very impressed." },

	{ "type":"narration",
	  "text":"He delivers all of this with complete seriousness. Not a single crack. Not even a twitch." },
	{ "type":"narration",
	  "text":"You respect it more than you have ever respected anything." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"anyway. ten minutes on foot. fingerpost points the way. don't fall in the river." },

	{ "type":"narration",
	  "text":"He straightens up. Adjusts his hoodie. Looks almost professional for approximately one second." },

	{ "type":"sfx", "src": SFX+"shortcut.wav", "vol":0.75 },

	{ "type":"narration", "text":"Gone." },
	{ "type":"narration",
	  "text":"No build-up. No warning. One moment he exists, the next he simply doesn't." },
	{ "type":"narration",
	  "text":"The sentry post is empty. The snow falls quietly. Somewhere nearby, a small white dog is asleep inside a pile of puzzle bones, completely unbothered." },
	{ "type":"narration",
	  "text":"You start walking." },

	{ "type":"goto", "goto":"ch1_pap_ambush" },
  ],

  # ───────────────────────────────────────────────────
  #  PAPYRUS AMBUSH TREE
  # ───────────────────────────────────────────────────
  "ch1_pap_ambush": [
	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_forest_fingerpost.png",
	  "bgm": BGM + "bonetrousle.mp3",
	  "char": "" },

	{ "type":"narration",
	  "text":"The path narrows. Trees crowd in on both sides." },
	{ "type":"narration",
	  "text":"The snow is undisturbed except for one very obvious set of boot prints leading directly behind a large pine." },
	{ "type":"narration",
	  "text":"You stop." },
	{ "type":"narration",
	  "text":"You look at the boot prints." },
	{ "type":"narration",
	  "text":"You look at the tree." },
	{ "type":"narration",
	  "text":"The tree has a small sign nailed to it that says 'PAPYRUS'S AMBUSH TREE — DO NOT LOOK HERE'." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"NYEH!!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"AH HA!! THE GREAT PAPYRUS HAS BEEN WAITING HERE FOR PRECISELY FORTY-THREE MINUTES!!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"AND YOU HAVE WALKED RIGHT INTO MY TRAP!!" },

	{ "type":"narration",
	  "text":"He leaps out in full battle armor. He has a small notebook. He immediately checks something off in it." },

	{ "type":"choice", "options":[
	  { "text":"I could see the sign from the path.", "goto":"ch1_pap_saw_sign" },
	  { "text":"...forty-three minutes?",             "goto":"ch1_pap_waiting"  },
	  { "text":"I thought you were on patrol.",       "goto":"ch1_pap_patrol"   },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_saw_sign": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"THE SIGN IS A DECOY." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"IT IS DESIGNED TO MAKE YOU THINK I AM BEHIND THE TREE." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"...WHICH I WAS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"BUT THAT IS NOT THE POINT!!" },
	{ "type":"goto", "goto":"ch1_pap_ambush_resume" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_waiting": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pleased.png",
	  "text":"FORTY-THREE MINUTES AND TWELVE SECONDS, ACTUALLY." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I BROUGHT A THERMOS." },
	{ "type":"narration",
	  "text":"He did. It is shaped like a bone. He does not mention this. He simply holds it with quiet dignity." },
	{ "type":"goto", "goto":"ch1_pap_ambush_resume" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_patrol": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"THIS IS MY PATROL." },
	{ "type":"narration",
	  "text":"He gestures at the ambush tree with great dignity." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"THE PATH IS THE PATROL ROUTE. I AM ON THE PATH. THEREFORE I AM PATROLLING." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"suspicious.png",
	  "text":"I DO NOT SEE THE ISSUE." },
	{ "type":"goto", "goto":"ch1_pap_ambush_resume" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_pap_ambush_resume": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"REGARDLESS. YOU ARE CAPTURED." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"THE GREAT PAPYRUS WILL NOW ESCORT YOU TO SNOWDIN TOWN." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pleased.png",
	  "text":"THIS IS THE FORMAL PART. I HAVE REHEARSED IT." },

	{ "type":"narration",
	  "text":"He straightens up. Clears his throat. Produces a small index card from somewhere inside his armor." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"AHEM." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I, PAPYRUS THE GREAT, HEREBY DECLARE THAT THIS HUMAN —" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"SANS DIDN'T GET YOUR NAME." },

	{ "type":"narration",
	  "text":"He lowers the index card. He looks personally offended at Sans specifically. Sans is not here. He is offended anyway." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"THIS HUMAN — WHOSE NAME I WILL LEARN PROPERLY LATER — IS HEREBY CAPTURED." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"BY THE GREAT PAPYRUS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"NYEH HEH HEH!!" },

	{ "type":"narration",
	  "text":"He puts the card away with great ceremony. You both know you could just walk away right now. You both choose not to address this." },

	{ "type":"goto", "goto":"ch1_town_walk" },
  ],

  # ───────────────────────────────────────────────────
  #  WALK TO SNOWDIN
  # ───────────────────────────────────────────────────
  "ch1_town_walk": [
	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_forest_path.png",
	  "bgm": BGM + "bonetrousle.mp3",
	  "char": PAP+"pose.png" },

	{ "type":"narration", "text":"You walk. Papyrus narrates." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"THE TOWN AHEAD IS SNOWDIN. POPULATION: FRIENDLY MONSTERS AND ONE BROTHER WHO NAPS TOO MUCH." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"happy.png",
	  "text":"I HAVE LIVED HERE MY WHOLE LIFE. I KNOW EVERYONE. EVERYONE KNOWS ME." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"I AM, AS THEY SAY, EXTREMELY BELOVED." },

	{ "type":"narration",
	  "text":"He says this with complete sincerity. You have no reason to doubt it." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"THERE IS A SHOP. THEY SELL THINGS. I OCCASIONALLY SUPERVISE THE QUALITY OF THEIR PRODUCTS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"THEY HAVE ASKED ME TO STOP. I HAVE NOT STOPPED." },

	{ "type":"narration",
	  "text":"Ahead, the trees begin to thin. Warm light bleeds through the branches. You can smell woodsmoke." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"AH! SNOWDIN! THERE IT IS!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I PRESENT IT TO YOU. AS YOUR CAPTOR. CONSIDER IT A GIFT." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"happy.png",
	  "text":"CAPTURING SOMEONE IS A GREAT RESPONSIBILITY. I WANT YOU TO HAVE A NICE TIME." },

	{ "type":"narration",
	  "text":"Something about this is deeply charming and you cannot explain why." },

	{ "type":"goto", "goto":"ch1_snowdin_arrive" },
  ],

  # ───────────────────────────────────────────────────
  #  SNOWDIN TOWN
  # ───────────────────────────────────────────────────
  "ch1_snowdin_arrive": [
	{ "type":"scene",
	  "bg":  BG  + "ex_snowdin_town_square.png",
	  "bgm": BGM + "snowdin_town_new.mp3",
	  "char": "" },

	{ "type":"narration", "text":"Snowdin." },
	{ "type":"narration",
	  "text":"It's smaller than you expected. Warmer. A Christmas tree stands in the town square — decorated, lights strung carefully, a slightly crooked star on top." },
	{ "type":"narration",
	  "text":"Nobody put it there for a holiday. It's just there. It's just always there. That's just how Snowdin is." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"THE SHOP IS CLOSED THIS TIME OF DAY. BUT GRILLBY'S IS OPEN." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"GRILLBY IS A FIRE MONSTER WHO MAKES FOOD. HE DOES NOT SPEAK OFTEN." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"SANS SAYS HE DOES SPEAK. I HAVE NEVER PERSONALLY WITNESSED THIS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"suspicious.png",
	  "text":"I BELIEVE SANS IS MAKING IT UP TO FEEL SPECIAL." },

	{ "type":"narration",
	  "text":"A bunny monster walks past with something on a leash. It has a basket. It nods at Papyrus. He nods back with complete dignity." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pleased.png",
	  "text":"THAT'S MRS. NUMBUH. SHE IS NICE." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"I DO NOT KNOW WHAT SHE IS WALKING. NOBODY KNOWS." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"WE DO NOT ASK ABOUT THE WALKING THING. IT IS SIMPLY PART OF SNOWDIN NOW." },

	{ "type":"narration", "text":"You decide this is reasonable." },

	{ "type":"goto", "goto":"ch1_house_approach" },
  ],

  # ───────────────────────────────────────────────────
  #  SKELETON HOUSE
  # ───────────────────────────────────────────────────
  "ch1_house_approach": [
	{ "type":"scene",
	  "bg":  BG  + "ex_skele_house_exterior.png",
	  "bgm": BGM + "snowdin_town_new.mp3",
	  "char": PAP+"enchanted.png" },

	{ "type":"narration",
	  "text":"The house is two stories. Warm stone. Icicles hanging from the gutters." },
	{ "type":"narration",
	  "text":"There is a flag at the top. It depicts a skeleton in a heroic pose with a thumb up." },
	{ "type":"narration",
	  "text":"The flag is extremely tasteful." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"WELCOME! TO THE SKELETON HOUSEHOLD!" },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"pose.png",
	  "text":"I WILL NOW PRESENT YOU TO MY BROTHER AND FORMALLY ANNOUNCE YOUR CAPTURE." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"HE WILL BE VERY IMPRESSED." },

	{ "type":"goto", "goto":"ch1_house_inside" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_house_inside": [
	{ "type":"scene",
	  "bg":  BG  + "skele_house_interior.png",
	  "bgm": BGM + "sans_theme.mp3",
	  "char": "" },

	{ "type":"narration",
	  "text":"The house is warm. Worn couch. Staircase. Kitchen visible through a doorway." },
	{ "type":"narration",
	  "text":"On the couch, wrapped in a blanket that says 'WORLD'S OKAYEST BROTHER', is Sans." },
	{ "type":"narration",
	  "text":"He is asleep." },
	{ "type":"narration",
	  "text":"He was watching TV. The TV is still on. A hot dog is half-eaten on the table. Still warm." },
	{ "type":"narration",
	  "text":"He has been here for at least twenty minutes. You watched him teleport away from the sentry post not thirty minutes ago." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Papyrus",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"confused.png",
	  "text":"SANS." },
	{ "type":"dialogue", "name":"Papyrus",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"angry.png",
	  "text":"SANS!! WE WERE WALKING FOR TWENTY MINUTES!!" },
	{ "type":"dialogue", "name":"Sans",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"angry.png",
	  "text":"mm." },
	{ "type":"dialogue", "name":"Papyrus",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"angry.png",
	  "text":"HOW ARE YOU ALREADY HOME??" },
	{ "type":"dialogue", "name":"Sans",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"angry.png",
	  "text":"walked." },
	{ "type":"dialogue", "name":"Papyrus",
	  "char_left": SANS+"sleepy.png", "char_right": PAP+"angry.png",
	  "text":"YOU WALKED FASTER THAN WE DID??" },
	{ "type":"dialogue", "name":"Sans",
	  "char_left": SANS+"neutral.png", "char_right": PAP+"suspicious.png",
	  "text":"shortcuts." },

	{ "type":"narration", "text":"He pulls the blanket up slightly." },

	{ "type":"dialogue", "name":"Sans",    "char": SANS+"neutral.png",
	  "text":"there's one by the second pine." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"suspicious.png",
	  "text":"I HAVE WALKED THAT PATH THOUSANDS OF TIMES. THERE ARE NO SHORTCUTS." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"confident.png",
	  "text":"it's a really good tree." },

	{ "type":"narration",
	  "text":"A long pause. Papyrus stares at his brother. Sans does not open his eye sockets." },

	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"angry.png",
	  "text":"I WILL INSPECT THAT TREE TOMORROW." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"neutral.png",
	  "text":"let me know what you find." },

	{ "type":"narration", "text":"He absolutely will not tell him." },

	{ "type":"goto", "goto":"ch1_spaghetti_offer" },
  ],

  # ───────────────────────────────────────────────────
  #  SPAGHETTI + EVENING
  # ───────────────────────────────────────────────────
  "ch1_spaghetti_offer": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"I WILL MAKE SPAGHETTI." },
	{ "type":"choice", "options":[
	  { "text":"Yes please.",          "goto":"ch1_yes_spaghetti" },
	  { "text":"I'm okay, thank you.", "goto":"ch1_no_spaghetti"  },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_yes_spaghetti": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"enchanted.png",
	  "text":"EXCELLENT TASTE!!" },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"pleased.png",
	  "text":"good call." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"confident.png",
	  "text":"he's been practicing." },
	{ "type":"narration",
	  "text":"Papyrus has already vanished into the kitchen. You can hear him narrating his own cooking process to no one." },
	{ "type":"goto", "goto":"ch1_evening" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_no_spaghetti": [
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"confused.png",
	  "text":"I SEE." },
	{ "type":"narration", "text":"He processes this for a full three seconds." },
	{ "type":"dialogue", "name":"Papyrus", "char": PAP+"happy.png",
	  "text":"I WILL MAKE SOME ANYWAY AND LEAVE IT ON THE TABLE IN CASE YOU CHANGE YOUR MIND." },
	{ "type":"narration",
	  "text":"He disappears into the kitchen. Sans looks at you." },
	{ "type":"dialogue", "name":"Sans",    "char": SANS+"sideeye.png",
	  "text":"he was going to do that regardless." },
	{ "type":"goto", "goto":"ch1_evening" },
  ],

  # ───────────────────────────────────────────────────
  #  EVENING WIND DOWN
  # ───────────────────────────────────────────────────
  "ch1_evening": [
	{ "type":"scene",
	  "bg":  BG  + "skele_house_interior.png",
	  "bgm": BGM + "chill.mp3",
	  "char": SANS+"neutral.png" },

	{ "type":"narration",
	  "text":"The kitchen fills with noise. Clattering pans. Papyrus's running commentary on water temperature. At some point something briefly catches fire and is immediately put out." },
	{ "type":"narration",
	  "text":"Sans hasn't moved." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"so." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"you made it." },

	{ "type":"narration",
	  "text":"He says it the way you'd confirm a delivery arrived. Neutral. Factual. No particular investment in the answer." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"snowdin's not a bad place." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"as far as places go." },

	{ "type":"choice", "options":[
	  { "text":"It's nice here.",             "goto":"ch1_eve_nice"    },
	  { "text":"What happens to me now?",     "goto":"ch1_eve_fate"    },
	  { "text":"Does Papyrus always do this?","goto":"ch1_eve_papyrus" },
	]},
  ],

  # ───────────────────────────────────────────────────
  "ch1_eve_nice": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"yeah." },
	{ "type":"narration",
	  "text":"He doesn't add anything. He just lets it sit there like that's a complete answer. Maybe it is." },
	{ "type":"goto", "goto":"ch1_sans_quiet" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_eve_fate": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"technically you're supposed to see undyne." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"captain of the royal guard. intense. very into spears." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"she's... not gonna be thrilled." },
	{ "type":"narration",
	  "text":"He doesn't elaborate. The silence does a lot of work." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"but that's tomorrow's problem." },
	{ "type":"goto", "goto":"ch1_sans_quiet" },
  ],

  # ───────────────────────────────────────────────────
  "ch1_eve_papyrus": [
	{ "type":"dialogue", "name":"Sans", "char": SANS+"confident.png",
	  "text":"the ambush tree? yeah." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"pleased.png",
	  "text":"he's had that planned since he heard a human crossed the ruins." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"made a whole notebook. logistics. contingencies." },
	{ "type":"narration", "text":"He pauses." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"he's been waiting for this." },
	{ "type":"narration",
	  "text":"He doesn't say 'for you'. He doesn't have to." },
	{ "type":"goto", "goto":"ch1_sans_quiet" },
  ],

  # ───────────────────────────────────────────────────
  #  SANS QUIET MOMENT — the promise, unspoken
  # ───────────────────────────────────────────────────
  "ch1_sans_quiet": [
	{ "type":"scene",
	  "bg":  BG  + "skele_house_interior.png",
	  "bgm": BGM + "memory_someone.mp3",
	  "char": SANS+"sideeye.png" },

	{ "type":"narration",
	  "text":"From the kitchen, the smell of spaghetti. Papyrus is singing. Quietly, by his standards." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"hey." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"snowdin's fine. pap's gonna take care of you. undyne will yell a lot but she won't do anything." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"you'll be okay." },

	{ "type":"narration",
	  "text":"He says it like he's checking a box. Like there's a list somewhere and this is the last item on it." },
	{ "type":"narration",
	  "text":"Not reassurance. More like... confirmation. For himself, maybe." },

	{ "type":"dialogue", "name":"Sans", "char": SANS+"sideeye.png",
	  "text":"..." },
	{ "type":"dialogue", "name":"Sans", "char": SANS+"neutral.png",
	  "text":"anyway." },

	{ "type":"narration",
	  "text":"He closes his eye sockets. The TV plays something nobody is watching." },
	{ "type":"narration",
	  "text":"Outside, snow falls quietly. Somewhere out there, a small white dog is still asleep inside the ruins of a fog machine, completely at peace with every decision it has ever made." },

	{ "type":"goto", "goto":"ch1_end" },
  ],

  # ───────────────────────────────────────────────────
  #  CHAPTER 1 END
  # ───────────────────────────────────────────────────
  "ch1_end": [
	{ "type":"scene",
	  "bg":  BG  + "skele_house_papyrus_room.png",
	  "bgm": BGM + "memory_someone.mp3",
	  "char": "" },

	{ "type":"narration", "text":"Later." },
	{ "type":"narration",
	  "text":"The spaghetti was, objectively, not great. It had an unusual texture. Papyrus watched you eat with the intensity of someone awaiting a verdict on the most important trial of their life." },
	{ "type":"narration",
	  "text":"You told him it was good. You meant it more than you expected to." },
	{ "type":"narration",
	  "text":"Sans ate three servings without comment and fell asleep on the couch before Papyrus finished his." },
	{ "type":"narration",
	  "text":"Papyrus covered him with the blanket. Then immediately pretended he hadn't." },
	{ "type":"narration", "text":"..." },
	{ "type":"narration",
	  "text":"Outside, Snowdin is quiet. The Christmas tree lights in the square glow through the window." },
	{ "type":"narration",
	  "text":"You are here. You are captured. You are, somehow, okay." },
	{ "type":"narration",
	  "text":"Tomorrow there will be Undyne." },
	{ "type":"narration",
	  "text":"Tonight there is warm light and questionable pasta and a skeleton who will not stop narrating and another one who absolutely knows a shortcut through a tree." },
	{ "type":"narration", "text":"It's enough." },

	{ "type":"ending",
	  "title":    "CHAPTER 1 COMPLETE",
	  "subtitle": "— end of chapter one —\nThe underground has a way of making itself home." },
  ],

}
