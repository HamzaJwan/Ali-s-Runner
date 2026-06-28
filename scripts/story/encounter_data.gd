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
	"الطريق ما زال في بدايته يا علي… حاول مرة ثانية."

const ENCOUNTERS := {
	FATIMA: {
		"character_id": FATIMA,
		"checkpoint_id": FATIMA,
		"trigger_score": 15,
		"retry_score": 15,
		"post_speed": 240.0,
		"asset_path": "res://assets/characters/fatima/fatima_helper.png",
		"placeholder_text": "فاطمة ⭐",
		"speaker_name": "فاطمة",
		"visual_height": 100.0,
		"story_position_role": POSITION_CURB,
		"arrival_mode": ARRIVAL_REVEAL,
		"dialogue_steps": [
			{"role": ROLE_HELPER, "text": "آآ… علي! ⭐"},
			{
				"role": ROLE_ALI,
				"text": "فاطمة… لقيتك. كنت عارف إن نورك قريب يا فاطمة.",
			},
			{"role": ROLE_REWARD, "text": "حصلت على نجمة الفرح."},
		],
		"reward_text": "حصلت على نجمة الفرح.",
		"game_over_line": \
			"نجمة فاطمة ما زالت تنور لك الطريق… ارجع وحاول من جديد.",
	},
	ZAINAB: {
		"character_id": ZAINAB,
		"checkpoint_id": ZAINAB,
		"trigger_score": 35,
		"retry_score": 35,
		"post_speed": 255.0,
		"asset_path": "res://assets/characters/zainab/zainab_helper.png",
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
		"asset_path": "res://assets/characters/jomana/jomana_helper.png",
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
		"asset_path": "res://assets/characters/father/father_ending.png",
		"placeholder_text": "بابا",
		"speaker_name": "الأب",
		"visual_height": 200.0,
		"story_position_role": POSITION_ROAD,
		"arrival_mode": ARRIVAL_REVEAL,
		"dialogue_steps": [
			{
				"role": ROLE_HELPER,
				"text": "أحسنت يا علي… وصلت وجبت النور معاك.",
			},
			{"role": ROLE_ALI, "text": "النور طلع فينا نحنا."},
			{"role": ROLE_HELPER, "text": "بالضبط… البيت ينور بأهله."},
			{
				"role": ROLE_REWARD,
				"text": "اكتملت الرحلة — المنطرحة، زليتن.",
			},
		],
		"reward_text": "اكتملت الرحلة — المنطرحة، زليتن.",
		"game_over_line": "",
	},
}


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
