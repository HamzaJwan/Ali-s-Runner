# Ali Runner — Story Plan

## 1. Story Title

**علي ونور البيت**
English reference title: *Ali and the Light of Home*

## 2. Setting

شارع المنطرحة، زليتن، ليبيا
(Al-Mantarah street, Zliten, Libya)

## 3. Premise

In Al-Mantarah, Zliten, Ali finds that the family lantern — the light of home — has faded. His father leaves him a simple message: to bring the light back, Ali must collect three warm family gifts:

* فرحة فاطمة (Fatima's joy)
* شجاعة زينب (Zainab's courage)
* حكمة جمانة (Jomana's wisdom)

Ali runs through Al-Mantarah, jumps over normal road obstacles, meets his sisters one by one, receives encouragement from each of them, and finally reaches his father at the end of the road.

## 4. Main Goal

Reach Baba at the end of the road by collecting Fatima's joy, Zainab's courage, and Jomana's wisdom along the way.

## 5. Emotional Goal

At the ending, Ali learns that the real light is not magic or fighting — it is family, courage, and staying together.

Tone:

* Warm
* Suspenseful but not scary
* Family-friendly
* Emotional
* Child-safe
* Local to Al-Mantarah/Zliten
* No violence
* No enemies
* No horror

The player should always wonder:

* Who will Ali meet next?
* What will each sister give him?
* Where is Baba?
* What happens when the light is complete?

## 6. Character Roles and Sizes

* Ali is the main playable character and the largest child character.
* Jomana is Ali's older sister helper — smaller than Ali, but older than the other sisters.
* Zainab is younger than Jomana and appears smaller than her.
* Fatima is the baby sister and the smallest — shown as a seated baby helper/portrait, not a full runner. She is a newborn: she cannot stand, jump, or run. Her pose is always seated, calm/breathing or gently happy, reaching out one hand to offer her gift — never standing, jumping, or active like an older child.
* Father appears only in the ending. He is about 2x Ali's height in the ending image/panel, because he is an adult.
* Sisters are NPC story/helper moments, not playable characters yet.
* A possible future Part 2 may allow playing as the sisters in another area. This is backlog only (see `docs/FUTURE_FEATURE_BACKLOG.md`) and does not affect Level 1 scope.

## 7. Story Order

Although Ali is the largest character, the story meetings happen from youngest to oldest:

1. Fatima
2. Zainab
3. Jomana
4. Father ending

## 8. Checkpoint Thresholds

| Checkpoint | Score threshold |
| --- | --- |
| Fatima | 15 |
| Zainab | 35 |
| Jomana | 60 |
| Father ending | 90 |

Difficulty direction:

* Do not change obstacles dramatically at the first Fatima checkpoint.
* After Fatima: slightly increase speed or spawn pressure.
* After Zainab: later introduce one new safe obstacle type.
* After Jomana: increase challenge slightly before the father ending.
* Obstacle variety is a later milestone (v0.75), not part of the first Fatima checkpoint prototype.
* Do not make the game frustrating for a child.

## 9. Arabic Dialogue

All in-game story dialogue is Arabic. This is the first official draft.

### Intro

الراوي:
"في شارع المنطرحة بزليتن… بدأ نور البيت يضعف."

الأب:
"يا علي… لو تبي ترجع النور، اجمع فرحة فاطمة، وشجاعة زينب، وحكمة جمانة."

علي:
"حاضر يا بابا… بنوصل للنهاية."

### Fatima Checkpoint (score 15)

Visual note: Fatima is seated, calm/breathing or gently smiling, reaching out one hand to offer the star. She does not stand, jump, or move toward Ali — she is a newborn and physically cannot. Ali comes to her.

فاطمة:
"آآ… علي! ⭐"

علي:
"فاطمة! لقيتك… نجمتك بتنور الطريق."

System reward text:
"حصلت على نجمة الفرح."

### Zainab Checkpoint (score 35)

زينب:
"علي، دير بالك… الطريق بدأ يصعب."

علي:
"ما نخافش يا زينب."

زينب:
"خذ قلب الشجاعة."

System reward text:
"حصلت على قلب الشجاعة."

### Jomana Checkpoint (score 60)

جمانة:
"قريب وصلت يا علي… لكن لازم تختار الطريق الصح."

علي:
"وريني الطريق يا جمانة."

جمانة:
"خذ مفتاح الطريق… وكمل لبابا."

System reward text:
"حصلت على مفتاح الطريق."

### Father Ending (score 90)

الأب:
"أحسنت يا علي… وصلت وجبت النور معاك."

علي:
"النور طلع فينا نحنا."

الأب:
"بالضبط… البيت ينور بأهله."

Final success text:
"اكتملت الرحلة — المنطرحة، زليتن."

## 10. Reward Meaning

| Reward | Meaning | First implementation (v0.65/v0.7) | Real effect later (v0.9) |
| --- | --- | --- | --- |
| نجمة الفرح (Fatima's star) | Joy | Visual / flavor text only | Bonus star / extra score |
| قلب الشجاعة (Zainab's heart) | Courage | Flavor text only | One-hit shield / temporary protection |
| مفتاح الطريق (Jomana's key) | Wisdom / guidance | Flavor text only | Short boost / safer obstacle spacing |

No reward is ever framed as a weapon or combat power — each one is a feeling or a piece of guidance, consistent with the no-violence, no-enemies tone.

## 11. Technical Implementation Notes

* Use score thresholds, not distance, because score already increases when obstacles are passed.
* Use one reusable checkpoint panel for all four story beats (Fatima, Zainab, Jomana, Father).
* Add one helper image slot with fallback placeholder if the asset is missing.
* Add Arabic dialogue labels (right-to-left text rendering should be verified once implemented).
* Add a Continue button.
* Use `get_tree().paused = true` for the checkpoint pause.
* Set the checkpoint UI's process mode so the Continue button still works while the tree is paused.
* Resume gameplay after Continue.
* Increase difficulty slightly after each checkpoint (see Section 8).
* Keep `player.gd` and `obstacle.gd` mostly untouched for the first checkpoint (v0.65).
* First full version stays entirely in Al-Mantarah — no beach or desert yet.

## 12. Death and Retry Tone

Game Over should not feel like failure only — it should motivate Ali to continue.

* Each checkpoint gives Ali emotional strength: reaching Fatima, Zainab, or Jomana means he carries part of their gift (joy, courage, wisdom) with him even after a fall.
* Death text should reflect the last story gift collected, not a generic "you lost" message. See `docs/AI_GAME_ROADMAP.md` ("v0.66 — Checkpoint Retry and Emotional Game Over") for the draft lines tied to each checkpoint stage (before Fatima, after Fatima, after Zainab, after Jomana, near Father).
* The framing is always "try again," never "you failed" — consistent with the no-violence, no-horror tone in Section 5.
* Retry from the last reached checkpoint and Restart from the beginning are both offered, so a fall never erases the emotional progress Ali has already made in the story.
* This tone must carry through any future death/retry/checkpoint system: family, courage, hope — never punishment, fear, or shame.

## 13. Cinematic Checkpoint Presentation

The Fatima checkpoint (and, by template, Zainab/Jomana/Father later) should not feel like a flat UI panel dropped on top of the game — it should feel like Ali actually arrives at a moment in the street.

Fatima encounter flow (v0.65/v0.67, corrected by v0.70P):

1. Obstacles stop spawning once the checkpoint score is reached, and any active obstacles clear safely — Ali is never put in danger during the encounter.
2. Fatima is revealed already seated in place near the curb, with a gentle fade-in — she does not walk, run, or slide in like a world object. She is a newborn, so she never stands, jumps, or crawls toward Ali. Ali comes to her, not the other way around.
3. Gameplay pauses, and the scene becomes cinematic: a soft dim overlay and a focused dialogue presentation (rounded golden-bordered card, speaker-name badge above the current line), while the same Al-Mantarah background stays visible underneath.
4. Fatima speaks first, the player advances with Space/click/tap, Ali replies, the player advances again, the reward text appears (with a small pop animation), and the player presses Continue.
5. Ali returns to his runner position, a 3-2-1 countdown plays (each digit popping in), and gameplay resumes at the harder post-checkpoint difficulty.

This is a "fake zoom" presentation (dim overlay + focused panel/portraits), not a real `Camera2D` zoom — real camera zoom stays a separate, later milestone (v1.15) so it doesn't risk the fixed viewport layout.

**v0.65, v0.66, v0.67, v0.70, v0.70P, v0.71, and v0.72 are all now complete** — this flow is the official, fully implemented template for every checkpoint and the ending, documented in `docs/AI_GAME_ROADMAP.md`:

* **v0.70 — Zainab** (score 35, gives قلب الشجاعة). Enters actively from offscreen right, like the original Fatima pattern.
* **v0.71 — Jomana** (score 60, gives مفتاح الطريق). Also enters actively from offscreen right.
* **v0.72 — Father Ending / Level Complete** (score 90). A win state, not a mid-run checkpoint — no countdown/resume, since the run ends here. Revealed in place with a fade-in, like Fatima, since an adult shouldn't sprint down the road either.

Entry style now varies sensibly by character: Fatima and Father are **revealed in place** (fade-in, no movement); Zainab and Jomana **enter actively** from offscreen right. All four share the same pause-and-cinematic-dialogue pattern, the same v0.70P-polished panel, and the same countdown-and-resume close (except Father, who ends the run instead). All dialogue stays Arabic-first, exactly as drafted in Section 9.

**Presentation direction update (v0.73 — owner preference, 2026-06-28):** the large centered popup card from v0.67/v0.70P is being superseded as the long-term presentation, not erased from history — it was a real, working step, and v0.73 builds on it rather than discarding it. The preferred final direction is:

* **In-world characters.** Ali and the current character appear facing/near each other in the street, not as portraits inside a card. Ali stands slightly left of center; the character (Fatima, Zainab, Jomana, Father) appears to his right.
* **Speech bubble / small dialogue panel**, positioned above or near whoever is currently speaking — not a large card covering most of the screen.
* **No large popup unless necessary for readability** — a subtle dim overlay is fine, but the Al-Mantarah street must stay visible underneath at all times.
* **Fatima stays seated on the curb**, never in the road lane, never walking/running/crawling — she is a newborn. The scene should read as Ali reaching her, not her approaching him.
* **Reward text appears in a small golden banner**, not a large centered label.

This direction applies to all four checkpoints/ending, reusing one shared presentation rather than four separate implementations — see `docs/AI_GAME_ROADMAP.md` ("v0.73 — In-World Cinematic Encounter Template + Story Architecture Cleanup") for the full scene composition and the scalable per-character config fields.

**Bubble placement update (v0.74 — owner observation, 2026-06-28):** the in-world presentation from v0.73 is implemented, but the dialogue bubble sometimes covers a character's face. Going forward:

* In-world dialogue bubbles should avoid covering either character's face — Ali's or the current helper's — at all times, not just in the common cases.
* The reward/system banner should likewise never hide either character; it stays a small centered golden banner, not a face-covering box.

See `docs/AI_GAME_ROADMAP.md` ("v0.74 — Dialogue Bubble Layout Fix and Story Code Modularization") for the full placement rules.

**Cinematic intro update (v1.25B planning — owner feedback, 2026-06-28):** the opening intro (currently a flat, centered-text "الراوي" narration, implemented as v1.1) does not yet use this in-world presentation style. The owner wants the intro redesigned to match it:

* Same Al-Mantarah street background, always visible.
* **Ali and Father** facing each other in-world (not a narrator caption) — explicitly **not** a new character; do not add anyone named "Hamza" unless the owner instructs it later.
* Dialogue as a speech bubble near whichever character is speaking, with the speaking character getting a slight scale/focus emphasis and the non-speaking character dimming/shrinking slightly.
* Warm dim overlay, soft focus — a "fake zoom" exactly like the checkpoint encounters, not a real `Camera2D` (real zoom stays deferred to v1.15).
* Advance via التالي / تخطي (Next/Skip), reusing the buttons that already exist on the current intro.
* Use only the existing documented intro lines from Section 9 above (الراوي → الأب → علي) — no new Arabic story meaning is to be invented. Exactly how the narrator line gets re-attributed in-world (e.g. as Father's opening line, or as plain on-screen text with no visible narrator character) is left to implementation time.

This is planning only — not implemented yet. See `docs/AI_GAME_ROADMAP.md` ("v1.25B — Cinematic Intro Story Presentation") for the full scope and the "Visual Novel Lite / In-world Cinematic Dialogue" style reference.

## 14. Do Not Do Yet

* No real `Camera2D` zoom yet (see roadmap v1.15) — the v0.67 checkpoint cinematic uses a "fake zoom" (dim overlay + focused panel) instead, which is the approved exception.
* No full cinematic cutscene system (see roadmap v1.1 for the simple intro version, and v0.67/Section 13 for the checkpoint version — both are intentionally small, not a general cutscene engine).
* No complex dialogue tree.
* No multiple playable characters.
* No beach/desert level yet.
* No real shield/boost mechanic yet (flavor text first, real effects in v0.9).
* No animation system yet.
* No Android export yet.
* No ads, login, online features, or cloud saves.
