# Level 2 — Family Story Plan
# جمانة وأثر الكلمة — مرسى زليتن

## Owner Decision (confirmed 2026-07-01)
Level 2 uses the **same family characters as Level 1**.
Jomana meets Ali, Fatima, Zainab, and Father along the harbor road.
Harbor fishermen/children/elders are **decorative background silhouettes only** —
they are NOT story checkpoint characters.

---

## Story Identity

| Field | Value |
|---|---|
| Level 2 title | جمانة وأثر الكلمة |
| Place | مرسى زليتن — Zliten Harbour |
| Playable hero | جمانة |
| Core value | الكلمة الطيبة، الحكمة، الصبر، العائلة |
| Lesson | الكلمة الطيبة تفتح الطريق المسكّر. |
| Core message | كل خطوة طيبة تترك أثرًا. |
| Collectible | أثر — pink/gold shard (same system as Level 1 light shards) |

---

## Checkpoint Structure (IMMUTABLE for implementation)

### Score 15 — علي
**Value:** تشجيع الأخوة — encouragement and good words between siblings

**Tone:** Warm, surprised, brotherly.
Jomana wasn't expected at the harbor — Ali's words encourage her to keep going.

**Draft dialogue:**
> علي: "جمانة! والله ما توقعت تلحقيني هنا في المرسى."
> جمانة: "الكلمة الطيبة تقوّي اللي معاك يا علي."

**Reward:** "حصلت على كلمة علي الطيبة."

**Game Over line (if hit before score 35):**
"علي ما زال ينتظرك في المرسى… ارجع وحاول."

---

### Score 35 — فاطمة
**Value:** الرفق والرحمة — mercy and gentleness

**Tone:** Sweet and simple. Fatima's smile reminds Jomana that gentleness
makes the road lighter. (Fatima remains seated/baby-safe, same as Level 1.)

**Draft dialogue:**
> فاطمة: "آآ… جمانة! ⭐"
> جمانة: "فاطمة! ضحكتك تذكّرني إن الرفق يخلي الطريق أخف."

**Reward:** "حصلت على فرحة فاطمة."

**Game Over line:**
"فرحة فاطمة مازالت معاك… ارجع وحاول."

---

### Score 60 — زينب
**Value:** الصبر والتفكير الهادئ — patience and calm thinking

**Tone:** Steady, grounding. Zainab reminds Jomana to slow down and
think before moving — wisdom in action.

**Draft dialogue:**
> زينب: "جمانة، اهدئي… خذي بالأسباب وامشي خطوة خطوة."
> جمانة: "الصبر والتركيز — شجاعتك دايمًا تقوّيني يا زينب."

**Reward:** "حصلت على قلب زينب الشجاع."

**Game Over line:**
"الشجاعة مش ضجيج… ارجع وامشِ بثبات."

---

### Score 90 — الأب (Ending)
**Value:** احترام الوالدين، التوكل مع العمل، الخير العائلي

**Tone:** Warm, complete, proud without being preachy.
Father sees Jomana arrive with her أثر — every kind word counted.

**Draft dialogue:**
> الأب: "أحسنت يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا."
> جمانة: "الأثر ما يكون إلا بالمحاولة والصبر يا بابا."
> الأب: "بالضبط… اللي يمشي بحكمة ويتكلم بخير يترك أثرًا طيبًا."

**Reward:** "اكتملت رحلة جمانة — مرسى زليتن."

---

## Difficulty Speeds (same as Level 1 progression)

| After checkpoint | Speed |
|---|---|
| Start | 225 px/s |
| After Ali (15) | 240 px/s |
| After Fatima (35) | 255 px/s |
| After Zainab (60) | 270 px/s |
| Father ending (90) | — |

---

## Story Rules

- No preaching tone.
- No scary religious framing.
- No long Quran/Hadith quotes in gameplay UI.
- No violence, no enemies, no combat.
- Every game-over message is an encouragement to try again.
- Fatima must always be seated — never standing, running, or walking.
- All text is Arabic, RTL-safe.
- Dialogue is short: 2-3 lines per character maximum.
- Values appear through warmth and story, not lectures.

---

## What This Document Does NOT Decide

- Final dialogue wording (owner must approve before production)
- Final asset paths for character sprites (see JOMANA_ASSET_REQUIREMENTS.md)
- Audio for Level 2 checkpoints
- Whether Jomana's run animation has 4 or 8 frames

These items need owner review before implementation.
