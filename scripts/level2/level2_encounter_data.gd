class_name Level2EncounterData
extends RefCounted

## Level 2: جمانة وأثر الكلمة — مرسى زليتن
## Story value: الكلمة الطيبة، الحكمة، الصبر، العائلة
## Playable character: جمانة
##
## Checkpoints use the SAME family characters as Level 1 (owner decision):
## Ali → Fatima → Zainab → Father
## Harbor fishermen/elders/children exist only as distant decorative
## silhouettes in the background, NOT as story characters.

const NONE    := 0
const ALI     := 1   # score 15 — encouragement, good words between siblings
const FATIMA  := 2   # score 35 — mercy, gentleness
const ZAINAB  := 3   # score 60 — patience, calm thinking
const FATHER  := 4   # score 90 — respect for parents, tawakkul, family goodness

const ROLE_HELPER  := 0
const ROLE_JOMANA  := 1
const ROLE_REWARD  := 2

const GAME_OVER_BEFORE_CHECKPOINT := \
	"الكلمة الطيبة ما تضيع… ارجع وحاول مرة ثانية."

const ENCOUNTERS := {
	ALI: {
		"character_id": ALI,
		"trigger_score": 15,
		"retry_score": 15,
		"post_speed": 240.0,
		"speaker_name": "علي",
		"asset_path": "res://assets/characters/ali/ali_idle.png",
		"placeholder_text": "علي 👟",
		"visual_height": 88.0,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "جمانة! والله ما توقعت تلحقيني هنا في المرسى.",
			},
			{
				"role": ROLE_JOMANA,
				"text": "الكلمة الطيبة تقوّي اللي معاك يا علي.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على كلمة علي الطيبة."},
		],
		"reward_text": "حصلت على كلمة علي الطيبة.",
		"game_over_line": "علي ما زال ينتظرك في المرسى… ارجع وحاول.",
	},
	FATIMA: {
		"character_id": FATIMA,
		"trigger_score": 35,
		"retry_score": 35,
		"post_speed": 255.0,
		"speaker_name": "فاطمة",
		"asset_path": "res://assets/characters/fatima/fatima_companion.png",
		"placeholder_text": "فاطمة ⭐",
		"visual_height": 60.0,
		"dialogue_steps": [
			{"role": ROLE_HELPER, "text": "آآ… جمانة! ⭐"},
			{
				"role": ROLE_JOMANA,
				"text": "فاطمة! ضحكتك تذكّرني إن الرفق يخلي الطريق أخف.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على فرحة فاطمة."},
		],
		"reward_text": "حصلت على فرحة فاطمة.",
		"game_over_line": "فرحة فاطمة مازالت معاك… ارجع وحاول.",
	},
	ZAINAB: {
		"character_id": ZAINAB,
		"trigger_score": 60,
		"retry_score": 60,
		"post_speed": 270.0,
		"speaker_name": "زينب",
		"asset_path": "res://assets/characters/zainab/zainab_companion.png",
		"placeholder_text": "زينب ❤️",
		"visual_height": 80.0,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "جمانة، اهدئي… خذي بالأسباب وامشي خطوة خطوة.",
			},
			{
				"role": ROLE_JOMANA,
				"text": "الصبر والتركيز — شجاعتك دايمًا تقوّيني يا زينب.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على قلب زينب الشجاع."},
		],
		"reward_text": "حصلت على قلب زينب الشجاع.",
		"game_over_line": "الشجاعة مش ضجيج… ارجع وامشِ بثبات.",
	},
	FATHER: {
		"character_id": FATHER,
		"trigger_score": 90,
		"retry_score": 90,
		"post_speed": 270.0,
		"speaker_name": "الأب",
		"asset_path": "res://assets/characters/father/father_left.png",
		"placeholder_text": "بابا 🏠",
		"visual_height": 215.0,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "أحسنت يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا.",
			},
			{
				"role": ROLE_JOMANA,
				"text": "الأثر ما يكون إلا بالمحاولة والصبر يا بابا.",
			},
			{
				"role": ROLE_HELPER,
				"text": "بالضبط… اللي يمشي بحكمة ويتكلم بخير يترك أثرًا طيبًا.",
			},
			{
				"role": ROLE_REWARD,
				"text": "اكتملت رحلة جمانة — مرسى زليتن.",
			},
		],
		"reward_text": "اكتملت رحلة جمانة — مرسى زليتن.",
		"game_over_line": "",
	},
}


static func rtl_safe(text: String) -> String:
	if text.is_empty():
		return text
	return "\u200f" + text + "\u200f"


static func get_encounter(character_id: int) -> Dictionary:
	return ENCOUNTERS.get(character_id, {}).duplicate(true)


static func get_encounter_for_score(score: int) -> int:
	for char_id: int in [ALI, FATIMA, ZAINAB, FATHER]:
		if ENCOUNTERS[char_id]["trigger_score"] == score:
			return char_id
	return NONE
