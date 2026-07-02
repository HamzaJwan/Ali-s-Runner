# خطوات الخير — Story Bible
# Last updated: 2026-07-02

---

## Game Identity

| Field | Value |
|---|---|
| Series title | **خطوات الخير** |
| Subtitle | حكايات من زليتن |
| Core message | كل خطوة طيبة تترك أثرًا |
| Genre | Family runner, values-based, Arabic language |
| Setting | Zliten, Libya — real neighborhoods, real places |
| Tone | Warm, encouraging, family-safe. Never punishing. Never preachy. |

---

## The Central Idea

خطوات الخير is not a game about collecting power-ups or defeating enemies.
It is a game about a child moving through their neighborhood and learning,
through family encounters, that every good step — and every kind word — leaves
a mark (أثر) that matters, even if no one is watching.

The core mechanic (one-button runner, jump over obstacles) is a metaphor:
life has obstacles. You do not fight them. You jump over them. You try again.
Your family is not a power-up — they are the reason you keep going.

---

## Chapter Structure

### Chapter 1 — علي وأول خطوة
- **Hero:** علي (school-age boy)
- **Place:** شارع المنطرحة، زليتن
- **Theme:** المحاولة، مساعدة العائلة، الأخذ بالأسباب، التوكل
- **Scene:** `scenes/Main.tscn`
- **Status:** PRODUCTION — live at game.juanspace.org
- **Core arc:** Ali runs through al-Mantarah to meet his family. Each sister gives him a quality he
  carries for the rest of the run. The Father ends the journey with a lesson about أثر طيب.

### Chapter 2 — جمانة وأثر الكلمة
- **Hero:** جمانة (Ali's sister)
- **Place:** مرسى زليتن
- **Theme:** الكلمة الطيبة، الهدوء، الرفق، التوكل مع العمل
- **Scene:** `scenes/level2/Level2_Marsa_Playable.tscn`
- **Status:** INTERNAL TESTING — not deployed, not in main menu
- **Core arc:** Jomana runs along the harbor. Each family member gives her a value related to
  HOW she speaks — kind words, calm thinking, gentle heart, lasting أثر.

### Future Chapters (Not in Scope Now)
- Chapter 3: **زينب وثبات القلب** — Zainab's story of courage and patience
- Chapter 4: **العائلة تجمع الخير** — The full family gathers, each child's أثر joins

---

## Family Characters (Both Levels)

| Character | Role | Age | Value in L1 | Value in L2 |
|---|---|---|---|---|
| علي | L1 hero, L2 NPC | ~8 | الأثر يبدأ بخطوة | الكلمة الطيبة تقوّي الآخرين |
| جمانة | L1 NPC, L2 hero | ~10 | مفتاح الطريق (wisdom + kind words) | أثر الكلمة الطيبة |
| زينب | NPC in both | ~7 | قلب الشجاعة | الهدوء والثبات |
| فاطمة | NPC in both | toddler | نجمة الفرح (joy) | الرفق يفرّح القلب |
| الأب | NPC in both | adult | التوكل والمحاولة | الكلمة + الخطوة = أثر طيب |

---

## Chapter 1 ↔ Chapter 2 Connection

Level 1 Ali learns that good STEPS leave أثر.
Level 2 Jomana learns that good WORDS leave أثر.

The bridge: in Level 1's Jomana checkpoint, she tells Ali:
"الكلمة الطيبة تخلي الطريق أخف."
This is the seed of Level 2's entire theme.

### Recommended Transition Text (for future implementation)

When Level 1 → Level 2 transition is built:

**Transition card title:** "والآن… رحلة جمانة"
**Body:** "بعد ما تعلّم علي أن كل خطوة طيبة تترك أثرًا، تبدأ جمانة رحلتها في مرسى زليتن لتتعلم أن كل كلمة طيبة تترك أثرًا أيضًا."
**Button:** "ابدئي رحلة جمانة"

Do NOT implement this transition until Level 2 passes owner F6 approval.
See `docs/GAME_CHAPTER_FLOW.md` for implementation plan.

---

## Value Progression Map

```
L1: Ali in al-Mantarah
  Fatima (15):  Joy → الطريق أهون بابتسامة
  Zainab (35):  Courage → الشجاعة تمشي برغم الصعوبة
  Jomana (60):  Kind words → الكلمة الطيبة تخفّف الطريق  ← SEEDS Level 2
  Father (90):  Tawakkul → اعمل + توكّل + خطواتك تترك أثرًا

L2: Jomana in Marsa Zliten
  Ali (15):     Kind words → الكلمة الطيبة تقوّي اللي جنبك
  Zainab (35):  Calm → بالهدوء تختارين الكلمة الصح
  Fatima (60):  Gentleness → الرفق يفرّح القلب
  Father (90):  Full circle → كلمة + خطوة = أثر طيب
```

---

## Story Rules (Both Levels)

1. No supernatural elements — أثر is not magical light, it is moral impact
2. No violence, no enemies, no hostility
3. No preaching — lessons emerge from warmth, not lectures
4. Every game-over message offers hope and retry, never shame
5. Family members give VALUES, not items/weapons
6. Dialogue must feel like real Libyan-family conversation, not a religious textbook
7. Ali (L1) always speaks in first person about what he learns
8. Jomana (L2) reflects the lesson back to the family member
9. Father always has the deepest line — he closes the arc
10. The rewards are قيم, not قوى: نجمة الفرح is a feeling, not a shield

---

## Staging / Deployment Plan

| Chapter | Where | Status | Next step |
|---|---|---|---|
| Chapter 1 | game.juanspace.org | LIVE | No changes — stable |
| Chapter 2 | localhost/editor only | NOT DEPLOYED | Owner F6 → internal staging |
| Transition card | Not built | PLANNED | After Level 2 staging approved |
| Main menu chapter select | Not built | PLANNED | After both chapters stable |
