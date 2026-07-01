# خطوات الخير — Level 2 Plan (Planning Only)

**Series:** خطوات الخير | **Internal codename:** Ali Runner | **This document covers:** Level 2 planning only.

This is a planning document only. Nothing in this document implements code, scenes, or assets. Level 2 work must not begin until the owner has completed their F6 visual/audio review of Level 1 and explicitly approved Level 1 Gold status (see `docs/LEVEL_1_GOLD_CHECKLIST.md`).

**Status update (2026-07-01):** Story values refactored away from "النور as magic" toward "الأثر الطيب / good deeds and effort" across the full series (see `docs/STORY_PLAN.md`). Level 1 remains at INTERNAL RELEASE CANDIDATE, awaiting owner final visual/audio approval before any Level 2 code begins.

## Series Overview

The full خطوات الخير series spans four levels and a finale, each teaching one core life/Islamic value through play:

| Level | Title | Place | Value |
|---|---|---|---|
| 1 | علي وأول خطوة | المنطرحة، زليتن | المحاولة — trying again after mistakes |
| **2** | **جمانة وأثر الكلمة** | **مرسى زليتن** | **الكلمة الطيبة — kind words and wisdom** |
| 3 | زينب وثبات القلب | السوق / الحي | الشجاعة والصبر — courage and steadiness |
| 4 | العائلة تجمع الخير | طريق البيت | الرحمة والتعاون — mercy and cooperation |
| نهاية | كل خطوة لها أثر | — | التوكل مع العمل — tawakkul with action |

## Why Level 2 Exists

Level 1 tells Ali's story of gathering his sisters' gifts and reaching Father together. Level 2 gives the player a sister's perspective — Jomana's — and deepens the same family theme: each person in the family has their own journey and their own أثر (good trace left behind).

## Level 2 Story

**Title:** جمانة وأثر الكلمة
**Place:** مرسى زليتن — Zliten seaside / harbour
**Playable character:** جمانة (Jomana)
**Value:** الكلمة الطيبة (kind words), الحكمة (wisdom), الصبر (patience)

**Lesson:**
"الكلمة الطيبة تفتح الطريق المسكّر. تكلّم بخير وامشِ بهدوء."
(A kind word can open a closed path. Speak well and move calmly.)

**Seed story premise (owner to approve before implementation):**
جمانة تمشي في مرسى زليتن وتساعد صيادين وأطفال في طريقها — بكلمة طيبة هنا، وصبر هناك — وتصل إلى نهاية الرصيف وهي تحمل أثرًا من كل لقاء.
(Jomana walks through Zliten harbour and helps fishermen and children along the way — with a kind word here, patience there — arriving at the end of the pier carrying an أثر from each encounter.)

## Title

Public title for the full series is **خطوات الخير** (established). Each episode has its own subtitle. Internal/repo name "Ali Runner" remains unchanged.

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

## Recommended First Theme (v1.50 addition)

Given the three candidate characters above, the recommended Level 2 first theme is **جمانة في الشط (Jomana at the Zliten seafront)** for these reasons:
- Jomana is already the "wisest/path-finder" sister in Level 1 lore - a seafront/beach obstacle course (rocks, fishing boats, wave hazards?) naturally extends that "knowing the right path" theme.
- A beach/seafront in Zliten is visually distinct from the urban street of Level 1, giving immediate "new world" feel without rebuilding the game.
- The same runner loop (tap/jump over obstacles) applies trivially — no new gameplay mechanic required for the first iteration.
- Jomana is neither too young (Fatima) nor too similar to Ali (Zainab might feel like a colour-swap of Ali's existing mechanics), making her feel like a genuine new perspective.

This is a recommendation only. The owner decides.

## Mechanics Deferred from Level 1 (For Level 2 Consideration)

These were explicitly blocked from Level 1 but could be considered for Level 2 after proper design and testing:

- **Slide mechanic** — deliberately excluded from Level 1 (too complex, not needed for the story). Could be introduced in Level 2 if the beach/terrain context makes it feel natural (sliding under a wave?). Must not conflict with the one-tap simplicity that makes the game child-friendly.
- **Ambience loops** — city/birds/wind ambient audio was blocked from Level 1 by missing CC0 sources. A beach/seafront level naturally wants wave sounds — source these before Level 2 audio work begins.
- **Companion followers / playable sisters** — if Level 2 features Jomana as protagonist, Ali and the other sisters could appear as "companion followers" (visual only, not player-controlled) in a mirror of Level 1's companion ribbon. No implementation yet.
- **Web/Android public release** — waiting on export templates, Android SDK/JDK, and the public license documentation for `level1_exciting_loop.ogg` before any public-facing release. Internal testing (APK sideload, local static server) can happen once templates are installed.

## Level 2 Asset Requirements (Blocked Until Owner Approves)

Before any Level 2 code begins, the following assets are needed at minimum:
- **Background:** `bg_beach_sky.png`, `bg_beach_buildings.png`, `bg_beach_foreground.png`, `ground_beach.png` — same pipeline as the current Zliten urban art, needs to look authentically Zliten's coastline.
- **Character sprite:** `jomana_run_1..8.png` (8-frame, same canvas convention as `ali_run_1..8.png`), `jomana_idle.png`, `jomana_jump.png`, `jomana_fall.png`, `jomana_land.png`, `jomana_hurt.png`, `jomana_victory.png`.
- **Obstacles:** at least 2-3 beach-appropriate obstacles (rock, fishing net, boat mooring) in the same `visual_target_height` / `collision_height` ranges already tuned for the runner.
- **Optional:** `bg_beach_ambience_loop.ogg` (wave sounds, must be CC0/documented before integration).

None of these exist yet. This is an asset-sourcing and owner-approval gate before any Level 2 code begins.

## What Remains Blocked

| Item | Blocker |
|---|---|
| Level 2 code | Owner F6 review of Level 1 not yet complete |
| Web public release | Missing export templates; `level1_exciting_loop.ogg` license docs for public release |
| Android public release | Missing JDK, Android SDK, export templates, signing key, Play Store setup |
| Beach/Jomana assets | Not sourced yet |
| Ambience audio | No CC0 source found yet |
| Slide mechanic | Design/scope decision pending |

## Status

**PLANNING ONLY — LEVEL 2 GATE NOT YET OPENED.** The gate is: owner completes F6 visual/audio review of Level 1 → owner explicitly approves Level 1 Gold → Level 2 work may begin with this document as the initial brief.
