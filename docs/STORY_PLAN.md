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
* Fatima is the baby sister and the smallest — shown as a seated baby helper/portrait, not a full runner.
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

## 13. Do Not Do Yet

* No camera zoom yet (see roadmap v1.15).
* No full cinematic system (see roadmap v1.1 for the simple version only).
* No complex dialogue tree.
* No multiple playable characters.
* No beach/desert level yet.
* No real shield/boost mechanic yet (flavor text first, real effects in v0.9).
* No animation system yet.
* No Android export yet.
* No ads, login, online features, or cloud saves.
