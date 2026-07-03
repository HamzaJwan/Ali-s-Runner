# خطوات الخير — Story Plan

## 1. Game Series Title

**خطوات الخير**
Subtitle: *حكايات من زليتن*
Core message: كل خطوة طيبة تترك أثرًا.

Internal/repository codename: **Ali Runner** (unchanged).

---

## 2. Values Foundation

This game teaches lasting life and Islamic values through play, not lectures.
Every story beat, dialogue line, and game-over message reflects one or more of:

| Value | Arabic | How it appears |
|---|---|---|
| Trying again after mistakes | المحاولة بعد الغلطة | Game Over tone, retry framing |
| Loss is not the end | الخسارة مش نهاية | Game Over message wording |
| Taking the means | الأخذ بالأسباب | Father's intro advice |
| Reliance on Allah | الاستعانة بالله | Father's intro line |
| Patience | الصبر | Zainab's lesson |
| Kind words | الكلمة الطيبة | Level 2 (Jomana at sea) |
| Helping family | مساعدة العائلة | The whole companion journey |
| Respect for parents | احترام الوالدين | Father relationship |
| Good character | حسن الخُلُق | Tone across all levels |

Rules:
- No preaching tone. No long Quran/Hadith quotes in gameplay UI.
- No supernatural/magical light as a fantasy element.
- No fear-based or punishment-heavy framing.
- Values appear through story, character warmth, and the retry tone — not slogans.

---

## 3. Full Series Arc (4 Levels + Finale)

| # | Level Title | Place | Main Value | Lesson |
|---|---|---|---|---|
| 1 | **علي وأول خطوة** | المنطرحة، زليتن | المحاولة، مساعدة العائلة، احترام الوالدين | الغلطة مش نهاية. حاول مرة ثانية، وخذ بالأسباب، واستعن بالله. |
| 2 | **جمانة وأثر الكلمة** | مرسى زليتن | الكلمة الطيبة، الحكمة، الصبر | الكلمة الطيبة تفتح الطريق المسكّر. اتكلم بخير وامشِ بهدوء. |
| 3 | **زينب وثبات القلب** | السوق / الحي | الشجاعة، الصبر، الثبات | الشجاعة مش ضجيج. الشجاعة تركيز وصبر وخطوة صحيحة. |
| 4 | **العائلة تجمع الخير** | طريق البيت / البيت | الرحمة، التعاون، العائلة | الخير يكبر لما العيلة تساعد بعض. |
| نهاية | **كل خطوة لها أثر** | — | التوكل مع العمل | نعمل اللي علينا، نعاون الناس، ونتوكل على الله. |

---

## 4. Level 1 — "علي وأول خطوة"

### Setting
شارع المنطرحة، زليتن، ليبيا

### Premise
علي يركض في شارع المنطرحة ليلتقي بأخواته ويصل إلى أبيه — ليس لأن هناك نور سحري، بل لأن العائلة تجتمع وتتساند.
كل خطوة يخطوها علي بتركيز ومحاولة هي أثر طيب في نفسه وعائلته.

### Emotional Tone
- دافئ وعائلي
- مشجّع لا مخيف
- محلّي (المنطرحة / زليتن)
- لا عنف، لا أعداء، لا رعب
- كل لقاء مع أخت هو لحظة دافئة، لا مكافأة خارقة

---

## 5. Checkpoint Thresholds (IMMUTABLE)

| Character | Score | Value gift |
|---|---|---|
| فاطمة | 15 | نجمة الفرح (Joy) |
| زينب | 35 | قلب الشجاعة (Courage) |
| جمانة | 60 | مفتاح الطريق (Wisdom) |
| الأب (ending) | 90 | اكتملت الرحلة |

Do NOT change these thresholds. They are immutable game constants.

---

## 6. Character Roles and Sizes (unchanged)

- **علي** — playable runner, largest child character.
- **جمانة** — older sister NPC helper, smaller than Ali but the tallest sister.
- **زينب** — younger than Jomana, appears smaller.
- **فاطمة** — baby sister, always seated, calm or gently happy, reaching out one hand. She never stands, jumps, runs, or crawls. She is a newborn.
- **الأب** — appears only at the ending. Adult height (~2× Ali in the ending scene).
- Sisters are NPC story moments, not playable characters in Level 1.

Story meeting order: Fatima → Zainab → Jomana → Father.

---

## 7. Level 1 Dialogue (CURRENT APPROVED TEXT)
## Last polished: 2026-07-02

All Arabic. RTL enforced in code via rtl_safe(). No emojis in gameplay strings.
No long quotes in UI — short, warm, child-friendly. Real back-and-forth conversation.

### Intro

الراوي:
"في شارع المنطرحة بزليتن… وقف علي مستعدًا للرحلة."

الأب:
"يا علي… الطريق يحتاج قلب طيب وتركيز.
لو غلطت، حاول مرة ثانية… وخذ بالأسباب واستعن بالله."

علي:
"حاضر يا بابا… بنمشي خطوة خطوة، ولو وقعنا بنقوم ونحاول."

### Fatima Checkpoint (score 15)

فاطمة: "آآ علي!"

علي: "فاطمة! ابتسامتك تذكّرني إن حتى أصغر خطوة بخير فيها أثر."

نص المكافأة: "حصلت على نجمة الفرح."

نص game-over بعد هذه النقطة:
"فرحة فاطمة مازالت معاك… ارجع وحاول من جديد."

### Zainab Checkpoint (score 35)

زينب: "علي، الطريق بدأ يصعب — والشجاعة مش غياب الخوف."

علي: "إذن الشجاعة إنك تمشي برغم الصعوبة؟"

زينب: "بالضبط يا خوي… خطوة واحدة برغم الخوف تساوي كثير."

نص المكافأة: "حصلت على قلب الشجاعة."

نص game-over بعد هذه النقطة:
"الشجاعة لا تعني أنك لا تقع… بل أنك تقوم مرة أخرى."

### Jomana Checkpoint (score 60)

جمانة: "قريب توصل يا خوي… وأنا شايفاك تجاوزت كل شي بخطوة وكلمة."

علي: "الكلمة برضو لها دور يا جمانة؟"

جمانة: "أيه… الكلمة الطيبة تخلي الطريق أخف. خذ مفتاح الطريق وكمل لبابا."

جمانة: "خذ مفتاح الطريق… وكمل لبابا."

نص المكافأة: "حصلت على مفتاح الطريق."

نص game-over بعد هذه النقطة:
"مفتاح الطريق معك… النهاية قريبة."

### Father Ending (score 90)

الأب: "أحسنت يا علي… وصلت وكل خطوة طيبة تركت أثرًا في طريقك."

علي: "الأثر ما يكون إلا بالمحاولة والتوكل يا بابا."

الأب: "بالضبط — اعمل اللي عليك، وتوكل على الله، وكلامك وخطواتك تترك أثرًا طيبًا."

نص نهاية الرحلة: "اكتملت الرحلة — المنطرحة، زليتن."

*Note: "اكتملت الرحلة — المنطرحة، زليتن." is owner-approved. This exact reward text must not change without owner approval. The preceding dialogue lines were improved 2026-07-02 to include التوكل and the "كلامك وخطواتك" dual lesson (words + steps), which seeds Level 2's theme.*

### Game Over (before first checkpoint)

"الخسارة مش نهاية الطريق. ركّز، وخذ بالأسباب، وحاول مرة ثانية."

---

## 8. Collectible / UI Terminology

| Old term | New term | Notes |
|---|---|---|
| النور | الأثر | UI counter label |
| النور: N | الأثر: N | In-game HUD label |
| النور الذي جمعته | الأثر الذي تركته | Game Over panel label |

Asset file names (`light_shard_sheet.png`, `shard_pickup.wav`) remain unchanged internally.
The word "light shard" as a technical asset name is fine — "النور" as a *magical fantasy force* is what we avoid.
These are physical collectible items that leave a mark (أثر) on the journey, nothing supernatural.

---

## 9. Reward Meaning (aligned with values)

| Reward | Value connection | Game effect |
|---|---|---|
| نجمة الفرح (Fatima's star) | Joy, mercy — رحمة | Flavor → future: bonus score |
| قلب الشجاعة (Zainab's heart) | Courage, steadiness — شجاعة وثبات | Flavor → future: one-hit shield |
| مفتاح الطريق (Jomana's key) | Wisdom, guidance — حكمة وتوجيه | Flavor → future: safer spacing |

No reward is ever a weapon or a combat power. Each is a feeling, a quality, a value — consistent with the no-violence, no-enemies tone.

---

## 10. Death and Retry Tone

Game Over must never feel like punishment or shame.

Rules:
- Always frame it as "try again" — never "you failed."
- Reflect the last sister's value in the wording.
- "الأخذ بالأسباب" (take the means) is a recurring phrase: focus, try, and trust Allah.
- Both Retry (from last checkpoint) and Restart (from beginning) are offered.

---

## 11. Companion Journey (unchanged mechanics)

Story beats 1-5 (Start → Fatima → Zainab → Jomana → Father) form Ali's companion journey.
Each sister who joins symbolically stays with Ali for the rest of the run — shown via the HUD ribbon.
The Father ending scene shows all three sisters with Ali as a family reunion.

Companion state rules, checkpoint restore, and visual stages: see previous implementation notes.
These values meanings do NOT change the checkpoint thresholds (15/35/60/90), physics, or collision.

---

## 12. Technical Notes (unchanged)

- Score thresholds: 15, 35, 60, 90 — immutable.
- All dialogue text is Arabic-first, RTL-safe (using `rtl_safe()` wrapper).
- No supernatural references in game-facing strings.
- Asset file names (light_shard_*, shard_pickup.*) remain unchanged.
- `_update_light_shard_label()` format: `"الأثر: %d"`.
- Game Over collectible count: `"الأثر الذي تركته: %d"`.

---

## 13. What Is Intentionally NOT In This Game

- No HP/lives bars.
- No enemies or combat.
- No procedural terrain.
- No fantasy magic system.
- No long direct religious quotes in gameplay UI.
- No multiple lanes.
- No ads, accounts, cloud saves, or online features.
- No Level 2 content until Level 1 reaches Final Gold status (owner visual/audio approval).
