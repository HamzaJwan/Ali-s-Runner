class_name Level2EncounterData
extends RefCounted

## Level 2: جمانة وأثر الكلمة — مرسى زليتن
## Story value: الكلمة الطيبة، الحكمة، الصبر، العائلة
## Playable character: جمانة
##
## Owner-confirmed checkpoint order (updated 2026-07-01):
## 15  — علي   (encouragement, good words between siblings)
## 35  — زينب  (patience, calm thinking)
## 60  — فاطمة (mercy, gentleness)
## 90  — الأب  (tawakkul, family goodness)

const NONE    := 0
const ALI     := 1
const ZAINAB  := 2   # NOTE: Zainab is now checkpoint 2 (score 35)
const FATIMA  := 3   # NOTE: Fatima is now checkpoint 3 (score 60)
const FATHER  := 4

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
				"speaker": "علي",
				"text": "جمانة! ما توقعت تلحقيني هنا في المرسى!",
			},
			{
				"role": ROLE_HELPER,
				"speaker": "علي",
				"text": "الكلمة الطيبة تفتح القلوب يا جمانة — امشي بخير.",
			},
			{"role": ROLE_REWARD, "speaker": "علي", "text": "حصلتِ على كلمة علي الطيبة. ✦"},
		],
		"reward_text": "حصلتِ على كلمة علي الطيبة. ✦",
		"game_over_line": "علي ما زال ينتظرك في المرسى… ارجع وحاول.",
	},
	ZAINAB: {
		"character_id": ZAINAB,
		"trigger_score": 35,
		"retry_score": 35,
		"post_speed": 255.0,
		"speaker_name": "زينب",
		"asset_path": "res://assets/characters/zainab/zainab_companion.png",
		"placeholder_text": "زينب ❤️",
		"visual_height": 80.0,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"speaker": "زينب",
				"text": "اهدئي يا جمانة… خطوة خطوة، والصبر يبلّغ كل شيء.",
			},
			{
				"role": ROLE_JOMANA,
				"speaker": "جمانة",
				"text": "شكرًا يا زينب — ثباتك يقوّيني.",
			},
			{"role": ROLE_REWARD, "speaker": "زينب", "text": "حصلتِ على ثبات زينب. ✦"},
		],
		"reward_text": "حصلتِ على ثبات زينب. ✦",
		"game_over_line": "الشجاعة مش ضجيج… ارجع وامشِ بثبات.",
	},
	FATIMA: {
		"character_id": FATIMA,
		"trigger_score": 60,
		"retry_score": 60,
		"post_speed": 270.0,
		"speaker_name": "فاطمة",
		"asset_path": "res://assets/characters/fatima/fatima_companion.png",
		"placeholder_text": "فاطمة ⭐",
		"visual_height": 60.0,
		"dialogue_steps": [
			{"role": ROLE_HELPER, "speaker": "فاطمة", "text": "آآ جمانة!"},
			{
				"role": ROLE_JOMANA,
				"speaker": "جمانة",
				"text": "فاطمة! مجرد ابتسامتك تذكّرني إن الرفق يفتح كل باب.",
			},
			{"role": ROLE_REWARD, "speaker": "فاطمة", "text": "حصلتِ على فرحة فاطمة. ✦"},
		],
		"reward_text": "حصلتِ على فرحة فاطمة. ✦",
		"game_over_line": "فرحة فاطمة مازالت معاك… ارجع وحاول.",
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
				"speaker": "الأب",
				"text": "أحسنتِ يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا.",
			},
			{
				"role": ROLE_JOMANA,
				"speaker": "جمانة",
				"text": "والأثر ما يكون إلا بالمحاولة والصبر يا بابا.",
			},
			{
				"role": ROLE_HELPER,
				"speaker": "الأب",
				"text": "من مشى بحكمة وتكلّم بخير بقي ذكره طيبًا — أحسنتِ.",
			},
			{
				"role": ROLE_REWARD,
				"speaker": "الأب",
				"text": "اكتملت رحلة جمانة في مرسى زليتن. ✦",
			},
		],
		"reward_text": "اكتملت رحلة جمانة في مرسى زليتن. ✦",
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
	for char_id: int in [ALI, ZAINAB, FATIMA, FATHER]:
		if ENCOUNTERS[char_id]["trigger_score"] == score:
			return char_id
	return NONE
