class_name EncounterData
extends RefCounted

const NONE := 0
const FATIMA := 1
const ZAINAB := 2
const JOMANA := 3
const FATHER := 4

const ROLE_HELPER := 0
const ROLE_ALI := 1
const ROLE_REWARD := 2

const POSITION_CURB := "curb"
const POSITION_ROAD := "road"
const ARRIVAL_REVEAL := "reveal"
const ARRIVAL_ENTER := "enter"

const GAME_OVER_BEFORE_CHECKPOINT := \
	"الخسارة مش نهاية الطريق. ركّز، وخذ بالأسباب، وحاول مرة ثانية."

const FATIMA_REWARD_BONUS := 5

const ENCOUNTERS := {
	FATIMA: {
		"character_id": FATIMA,
		"checkpoint_id": FATIMA,
		"trigger_score": 15,
		"retry_score": 15 + FATIMA_REWARD_BONUS,
		"post_speed": 240.0,
		"asset_path": "res://assets/characters/fatima/fatima_companion.png",
		"placeholder_text": "فاطمة ⭐",
		"speaker_name": "فاطمة",
		"visual_height": 72.0,
		"story_position_role": POSITION_CURB,
		"arrival_mode": ARRIVAL_REVEAL,
		"dialogue_steps": [
			{"role": ROLE_HELPER, "text": "آآ… علي! ⭐"},
			{
				"role": ROLE_ALI,
				"text": "فاطمة! ضحكتك تذكّرني إن الطريق أهون بالعيلة.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على نجمة الفرح."},
		],
		"reward_text": "حصلت على نجمة الفرح.",
		"game_over_line": \
			"فرحة فاطمة مازالت معاك… ارجع وحاول من جديد.",
	},
	ZAINAB: {
		"character_id": ZAINAB,
		"checkpoint_id": ZAINAB,
		"trigger_score": 35,
		"retry_score": 35,
		"post_speed": 255.0,
		"asset_path": "res://assets/characters/zainab/zainab_companion.png",
		"placeholder_text": "زينب ❤️",
		"speaker_name": "زينب",
		"visual_height": 84.0,
		"story_position_role": POSITION_ROAD,
		"arrival_mode": ARRIVAL_ENTER,
		"dialogue_steps": [
			{"role": ROLE_HELPER, "text": "علي، دير بالك… الطريق بدأ يصعب."},
			{"role": ROLE_ALI, "text": "ما نخافش يا زينب."},
			{"role": ROLE_HELPER, "text": "خذ قلب الشجاعة."},
			{"role": ROLE_REWARD, "text": "حصلت على قلب الشجاعة."},
		],
		"reward_text": "حصلت على قلب الشجاعة.",
		"game_over_line": \
			"الشجاعة لا تعني أنك لا تقع… بل أنك تقوم مرة أخرى.",
	},
	JOMANA: {
		"character_id": JOMANA,
		"checkpoint_id": JOMANA,
		"trigger_score": 60,
		"retry_score": 60,
		"post_speed": 270.0,
		"asset_path": "res://assets/characters/jomana/jomana_companion.png",
		"placeholder_text": "جمانة 🗝️",
		"speaker_name": "جمانة",
		"visual_height": 92.0,
		"story_position_role": POSITION_ROAD,
		"arrival_mode": ARRIVAL_ENTER,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "قريب وصلت يا علي… لكن لازم تختار الطريق الصح.",
			},
			{"role": ROLE_ALI, "text": "وريني الطريق يا جمانة."},
			{
				"role": ROLE_HELPER,
				"text": "خذ مفتاح الطريق… وكمل لبابا.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على مفتاح الطريق."},
		],
		"reward_text": "حصلت على مفتاح الطريق.",
		"game_over_line": "مفتاح الطريق معك… النهاية قريبة.",
	},
	FATHER: {
		"character_id": FATHER,
		"checkpoint_id": NONE,
		"trigger_score": 90,
		"retry_score": 90,
		"post_speed": 270.0,
		"asset_path": "res://assets/characters/father/father_left.png",
		"placeholder_text": "بابا",
		"speaker_name": "الأب",
		"visual_height": 215.0,
		"story_position_role": POSITION_ROAD,
		"arrival_mode": ARRIVAL_REVEAL,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "أحسنت يا علي… وصلت وخطواتك تركت أثرًا.",
			},
			{"role": ROLE_ALI, "text": "الأثر ما يكون إلا بالمحاولة يا بابا."},
			{"role": ROLE_HELPER, "text": "بالضبط… اللي يحاول ويقوم مرة ثانية يترك أثرًا طيبًا."},
			{
				"role": ROLE_REWARD,
				"text": "اكتملت الرحلة — المنطرحة، زليتن.",
			},
		],
		"reward_text": "اكتملت الرحلة — المنطرحة، زليتن.",
		"game_over_line": "",
	},
}


## Wraps a dialogue/story sentence with Unicode RLM (U+200F) marks so a
## trailing/leading neutral character (a period, an em dash, the Arabic
## ellipsis "…") is always anchored to a strong RTL context instead of being
## placed by an ambiguous bidi guess. Only call this on full sentences meant
## for direct display - never on score/number strings or short UI labels,
## which do not have this problem and must stay exactly as typed.
static func rtl_safe(text: String) -> String:
	if text.is_empty():
		return text
	return "\u200f" + text + "\u200f"


static func get_encounter(character_id: int) -> Dictionary:
	return ENCOUNTERS.get(character_id, {}).duplicate(true)


static func get_encounter_for_score(score: int) -> int:
	for character_id in [FATIMA, ZAINAB, JOMANA, FATHER]:
		if ENCOUNTERS[character_id]["trigger_score"] == score:
			return character_id
	return NONE


static func get_checkpoint(checkpoint_id: int) -> Dictionary:
	if checkpoint_id in [FATIMA, ZAINAB, JOMANA]:
		return ENCOUNTERS[checkpoint_id].duplicate(true)
	return {}
