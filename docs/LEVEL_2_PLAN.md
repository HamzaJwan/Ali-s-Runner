# Ali Runner — Level 2 Plan (Planning Only)

This is a planning document only. Nothing in this document implements code, scenes, or assets. Level 2 work must not begin before **v1.34 — Level 1 Gold Candidate** (see `docs/LEVEL_1_GOLD_CHECKLIST.md`) and **v1.35 — Complete Roadmap Refresh** are both reached, per `docs/AI_GAME_ROADMAP.md` ("v2.0 — Level 2 Design Plan").

## Why Level 2 Exists

Level 1 (Al-Mantarah, Zliten) tells Ali's story: gathering فرحة فاطمة، شجاعة زينب، and حكمة جمانة on his way to Father, with the family reunited as نور البيت returns (see `docs/STORY_PLAN.md` Section 14, "Family Companion Journey"). That framing — the family coming together, not just Ali succeeding alone — is what makes a second part centered on a sister feel like a continuation rather than a spin-off.

## Title Universe (Not a Final Decision)

The current working title "علي رنر" (and the English "Ali Runner") is tied specifically to Ali. If Level 2 ever lets the player control or follow a sister, a title scoped to "Ali" alone stops fitting. This document records the candidate direction already raised elsewhere in the docs (`docs/STORY_PLAN.md` Section 14, `docs/AI_GAME_ROADMAP.md` "v1.25A-P") without deciding it:

* **مغامرة نور البيت** (Adventure of the Light of Home)
* **رحلة نور البيت** (Journey of the Light of Home)
* **أبطال نور البيت** (Heroes of the Light of Home)

Any of these reads naturally whether the playable character is Ali, Jomana, or Zainab — none of them name a single character. "Ali Runner" can remain the internal/project/repository name regardless of what the public/in-game title becomes. **The final title is an owner decision, not an AI-agent decision** — this document only keeps the candidate list visible so it isn't lost.

## Candidate Playable/Helper Characters

Per `docs/FUTURE_FEATURE_BACKLOG.md` ("Dream Backlog — Part 2 Sisters Adventure," owner-confirmed direction, 2026-06-28):

* **جمانة في الشط — Jomana at the beach** (Zliten seafront). Jomana is the oldest sister and already gives مفتاح الطريق (wisdom/guidance) in Level 1 — a seafront setting and a "guide/path-finder" gameplay angle would extend that role naturally.
* **زينب في حديقة أو طريق جديد — Zainab in a garden or a new road/area.** Zainab already gives قلب الشجاعة (courage) and has the one-hit-shield reward in Level 1 — a "braver, more active" Level 2 role would fit her established character.
* **فاطمة — stays a baby/bonus character, never a full runner.** Consistent with her character rules in `docs/STORY_PLAN.md` (Section 6 and Section 14) — Fatima cannot stand, jump, or run, in any level. If she appears in Level 2 at all, it stays a portrait/bonus presence, not a playable runner.

No character has been chosen as "the" Level 2 protagonist yet — this is a list of candidates, not a decision.

## Design Considerations Carried Over From Level 1

* **Same core loop first.** Level 2 should reuse the proven tap/click/Space jump runner loop before inventing a new gameplay mechanic — consistent with the project's "small testable steps" philosophy (`docs/AI_GAME_ROADMAP.md`, "Core Rule for Future AI Agents").
* **Same tone.** Warm, family-friendly, no violence, no enemies, no horror (`docs/STORY_PLAN.md` Section 5) — Level 2 is not an opportunity to introduce combat or threat mechanics.
* **Companion/Family continuity.** If Level 1 ships with the Family Companion Journey (v1.26/v1.27 — sisters joining Ali symbolically, Father ending as a reunion), Level 2 should feel like it continues that family thread (e.g. Jomana's beach level could reference the same نور البيت theme), not like an unrelated new game bolted on.
* **No HP/lives bar, no procedural terrain** — both already decided against for Level 1 (`docs/FUTURE_FEATURE_BACKLOG.md`, "Design Decisions — Not Doing For Now") and there's no stated reason for Level 2 to revisit either decision.
* **Asset sourcing stays the same:** Libyan/Zliten-specific characters and backgrounds stay AI-generated/custom per `docs/ASSET_SOURCING_PLAN.md` — a beach or garden setting still needs to read as authentically Zliten, not generic stock art.

## What This Document Does Not Do

* It does not choose a Level 2 protagonist.
* It does not choose a final title.
* It does not specify gameplay mechanics, checkpoints, or assets for Level 2.
* It does not change anything about Level 1.

## Status

**PLANNED ONLY.** Waiting on `docs/LEVEL_1_GOLD_CHECKLIST.md` (v1.34) and the roadmap refresh (v1.35) before any further Level 2 design work begins, per `docs/AI_GAME_ROADMAP.md` ("v2.0 — Level 2 Design Plan").
