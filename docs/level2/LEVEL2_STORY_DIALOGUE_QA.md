# Level 2 Story and Encounter QA — جمانة وأثر الكلمة
# Reviewer: Sonnet | Date: 2026-07-02

**Verdict: PARTIAL — 3 code issues; dialogue needs correction; layout needs redesign**

---

## Overall Assessment

The checkpoint system WORKS: portraits load, NPC arrives, dialogue advances, countdown resumes.
But three issues prevent this from feeling cinematic and correct:

1. **Dialogue panel covers both characters** — Card at screen Y=382-602 on a 644px viewport
2. **Ali dialogue step 2 is logically wrong** — Jomana teaches Ali instead of Ali teaching Jomana
3. **NPC persists on screen after "تابع"** — No off-screen reset on continue

---

## 1. Dialogue Panel Position

### What the scene file says

The `CheckpointPanel/Card` is positioned:
```
offset_left   = 70px
offset_top    = 382px   ← very low
offset_right  = 610px
offset_bottom = 602px   ← near bottom of 644px viewport
```

**The DimBG** is a full-screen dark overlay at 72% opacity (`Color(0.04, 0.03, 0.015, 0.72)`).
This covers the ENTIRE scene behind the card, including both characters.

**The Card** (540×220px at Y=382) lands DIRECTLY over where Jomana and Ali stand
(screen Y ≈ 370-640). Both characters are behind the dimmed overlay OR under the card.

### What the owner sees

The dialogue panel covers Jomana. Ali is barely visible on the right. The encounter feels like
a text screen rather than a face-to-face cinematic moment.

### Screenshot evidence

The first screenshot (from owner) shows the dark card with text at the bottom while the characters
are partially visible behind the dim overlay. The second screenshot shows both Jomana (waving) and
Ali (standing with flag) visible side-by-side ON the pier — this is the cinematic moment the owner wants.

### Recommended layout

The goal is: **characters fill the bottom 60% of the screen, dialogue text floats above them.**

Move the Card to the TOP of the screen:

```
offset_left   = 40px
offset_top    = 12px      ← top of screen
offset_right  = 730px     ← wider
offset_bottom = 160px     ← only 148px tall (single Arabic line + button)
```

Remove or significantly reduce DimBG opacity from 72% → 30% so characters remain clearly visible.
Make the card smaller: only enough space for one line of text and the continue button.

Speaker name: above the card or small at the top of the card.
Text: single line of Arabic at font_size 20-24.
Continue button: right side of card (RTL: left visual position).

This gives the effect of subtitle captions at the top with the characters fully visible below.

---

## 2. Dialogue Correctness — Full Review

### Ali (score 15)

**Current dialogue:**
```
Step 1 (HELPER / Ali):   "جمانة! ما توقعت تلحقيني هنا في المرسى."
Step 2 (JOMANA):          "كلمة طيبة منك تكفي تشجع اللي معاك يا علي."
Step 3 (REWARD):          "حصلت على كلمة علي الطيبة."
```

**Problem — Step 2:** Jomana is TEACHING ALI to say good words. This is backwards.
Ali is supposed to give Jomana the lesson. The line reads: "A good word FROM YOU [Ali] is enough
to encourage those with you, Ya Ali." Jomana is instructing her brother, which reverses the story logic.

**Also:** The speaker label shows "علي" on Step 2, but ROLE_JOMANA is set.
`cp_speaker.text = enc.get("speaker_name", "")` is set ONCE at the top of `_show_enc_step()`
and does NOT update per-step. So the speaker name always shows "علي" even when Jomana speaks.

**Corrected dialogue (3 steps, clean flow):**
```
Step 1 (HELPER / Ali):   "جمانة! ما توقعت تلحقيني هنا في المرسى!"
Step 2 (HELPER / Ali):   "الكلمة الطيبة تفتح القلوب يا جمانة — امشي بخير."
Step 3 (REWARD):          "حصلت على كلمة علي الطيبة. ✦"
```

Why: Ali greets Jomana, then delivers the value lesson to HER. Jomana receives it (reward).
This matches the story theme: family members GIVE Jomana a value, she collects it.

**2-step simpler alternative:**
```
Step 1 (HELPER / Ali):   "جمانة! كلمة طيبة تشجع اللي معاك — وأنتِ دايماً تعرفين."
Step 2 (REWARD):          "حصلت على كلمة علي الطيبة. ✦"
```

---

### Zainab (score 35)

**Current dialogue:**
```
Step 1 (HELPER / Zainab): "اهدئي يا جمانة… خذي بالأسباب، وامشي خطوة خطوة."
Step 2 (JOMANA):           "الصبر والتركيز — شجاعتك دايمًا تقوّيني يا زينب."
Step 3 (REWARD):           "حصلت على ثبات زينب."
```

**Assessment:** Step 1 is fine — Zainab tells Jomana to calm down and take it step by step.
Step 2 (Jomana): "Patience and focus — your courage always strengthens me, Ya Zainab." This is
a Jomana reflection thanking Zainab. This is acceptable, but slightly formal for a child's voice.

**Minor improvement:**
```
Step 1 (HELPER / Zainab): "اهدئي يا جمانة… خطوة خطوة، والصبر يبلّغ كل شيء."
Step 2 (JOMANA):           "شكراً يا زينب — ثباتك يقوّيني."
Step 3 (REWARD):           "حصلت على ثبات زينب. ✦"
```

**Also:** Add `"speaker_name"` update per step. When Jomana speaks, speaker label should say "جمانة".

---

### Fatima (score 60)

**Current dialogue:**
```
Step 1 (HELPER / Fatima): "آآ… جمانة! ⭐"
Step 2 (JOMANA):           "فاطمة! الرفق يخلي الطريق أخف، والكلمة الحلوة تفرّح القلب."
Step 3 (REWARD):           "حصلت على فرحة فاطمة."
```

**Problem:** Fatima's line is just "آآ… جمانة! ⭐" — a single surprised exclamation. Fatima in the
portrait is a BABY/TODDLER. A toddler character having no words but just an excited sound is actually
CHARMING and correct for her age. However the emoji ⭐ in dialogue text looks unpolished.

**Jomana's line (Step 2):** She's speaking TO Fatima explaining the value of gentleness.
This is also slightly backwards (Jomana is the lesson-giver). But Fatima being a baby cannot deliver
a lesson — so Jomana REFLECTING the lesson upon seeing baby Fatima is the correct interpretation.

**Correction — keep the reversal intentional for Fatima (because she's a baby):**
```
Step 1 (HELPER / Fatima): "آآ جمانة!"           ← remove emoji, keep exclamation pure
Step 2 (JOMANA):           "فاطمة! مجرد ابتسامتك تذكّرني إن الرفق يفتح كل باب."
Step 3 (REWARD):           "حصلت على فرحة فاطمة. ✦"
```

This makes Jomana reflect on the value of gentleness *inspired by* baby Fatima's innocent joy.
The direction reversal is intentional and emotionally correct for a baby character.

---

### Father (score 90)

**Current dialogue:**
```
Step 1 (HELPER / Father): "أحسنت يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا."
Step 2 (JOMANA):           "الأثر ما يكون إلا بالمحاولة والصبر يا بابا."
Step 3 (HELPER / Father):  "بالضبط… اللي يمشي بحكمة ويتكلم بخير يترك أثرًا طيبًا."
Step 4 (REWARD):           "اكتملت رحلة جمانة — مرسى زليتن."
```

**Assessment:** This is the BEST written checkpoint. Father speaks, Jomana responds, Father confirms.
The call-and-response feels natural for a father-daughter relationship. No logic errors.

**Minor polish:**
```
Step 1 (HELPER / Father): "أحسنتِ يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا."
Step 2 (JOMANA):           "والأثر ما يكون إلا بالمحاولة والصبر يا بابا."
Step 3 (HELPER / Father):  "بالضبط — من مشى بحكمة وتكلّم بخير بقي ذكره طيباً."
Step 4 (REWARD):           "اكتملت رحلة جمانة في مرسى زليتن. ✦"
```

Note: `أحسنت` → `أحسنتِ` (feminine form for Jomana). The original drops the ة kasra.

---

## 3. Speaker Name Per Step

**Current bug:** `cp_speaker.text = enc.get("speaker_name", "")` is set ONCE per `_show_enc_step()` call.
It always shows the character's name (e.g., "علي") even when the ROLE is ROLE_JOMANA.

**Fix required:** Per-step speaker name:
```
ROLE_HELPER → show character's name (e.g., "علي")
ROLE_JOMANA → show "جمانة"
ROLE_REWARD → show "" (no speaker for reward)
```

This change is in `_show_enc_step()` in `level2_marsa_playable.gd`.

---

## 4. Encounter Cinematic Composition

### What works in the screenshots

Looking at the owner's second screenshot (score=15, countdown=2 visible):
- Jomana (waving pose) is visible on the left at full size ✅
- Ali portrait is visible on the right at appropriate scale ✅
- Both stand on the same pier ground line ✅
- The harbor background is behind them ✅
- This IS the cinematic side-by-side moment the owner wants

### What blocks the cinematic moment

The **checkpoint dialogue panel** appears ON TOP of this beautiful composition.
Once the checkpoint_panel becomes visible, the DimBG (72% dark, full-screen) obscures the scene.

### Recommended camera behavior during checkpoint

Current: `_apply_checkpoint_cam()` tweens to `_gameplay_cam_pos` with +5% zoom boost.
This is minimal change. The characters look correct in this view.

The PANEL covering them is the only problem. Fix the panel position and the cinematic feel returns.

**Optional enhancement (not required for MVP):**
`_apply_checkpoint_cam()` could zoom to 1.35 (slightly more than 1.18) and center between
Jomana (X=220) and NPC (X=850) to frame both characters. This would make the encounter feel
more intentional. But this is a nice-to-have — fixing the panel position is the priority.

---

## 5. NPC Persists After Checkpoint

### The bug

In `_on_continue_pressed()`:
```gdscript
checkpoint_panel.visible = false
get_tree().paused = false
checkpoint_active = false
```

There is NO code to:
- Reset `encounter_npc.position.x` to off-screen (1300)
- Remove the NPCCard child from encounter_npc
- Hide the encounter_npc node

So after "تابع" is pressed:
1. The panel hides ✅
2. The countdown starts ✅
3. BUT Ali (or Zainab/Fatima/Father) is still standing on the pier at X=850
4. As obstacles and collectibles resume, the character portrait OVERLAPS with obstacles
5. The NPC portrait remains visible until the NEXT checkpoint calls `_build_npc_card()` (which clears it)

### Fix required

In `_on_continue_pressed()`, after `checkpoint_active = false`, before the countdown block:

```gdscript
# Reset NPC — slide off-screen right
npc_arriving = false
var npc_tween := create_tween()
npc_tween.tween_property(encounter_npc, "position:x", 1350.0, 0.35).set_trans(Tween.TRANS_SINE)
npc_tween.finished.connect(func() -> void:
    for child in encounter_npc.get_children():
        if child.name != "NPCLabel":
            child.queue_free()
    npc_label.visible = false
, CONNECT_ONE_SHOT)
```

This slides the NPC off to the right (like they walked away) before the countdown begins.

---

## 6. Collectibles After Checkpoint

### What happens

`_start_checkpoint()` calls:
```gdscript
collectible_spawner.stop_spawning()
collectible_spawner.clear_collectibles()
```

`_finish_countdown()` calls:
```gdscript
collectible_spawner.start_spawning(current_speed)
```

The collectible spawner has a timer interval. After `start_spawning`, the first collectible
appears after the timer fires (a few seconds delay). The screen is momentarily empty of shards.

### Is this a bug?

This is EXPECTED BEHAVIOR, not a bug. The owner may perceive the brief gap as "collectibles stopped."

### Recommended response to owner

Collectibles restart after the countdown + a short natural spawn delay. This is the same behavior
as the start of the level. It is intentional — a brief breathing space after the emotional checkpoint
before shards appear again. No code change needed here.

---

## 7. Corrected Final Dialogue Table

### Canonical dialogue for Codex to implement

**ALI (score 15, "الكلمة الطيبة"):**
```
Step 1: Ali (HELPER)   → "جمانة! ما توقعت تلحقيني هنا في المرسى!"
Step 2: Ali (HELPER)   → "الكلمة الطيبة تفتح القلوب يا جمانة — امشي بخير."
Step 3: REWARD         → "حصلت على كلمة علي الطيبة. ✦"
```
game_over_line: "علي ما زال ينتظرك في المرسى… ارجع وحاول."

**ZAINAB (score 35, "الصبر والثبات"):**
```
Step 1: Zainab (HELPER)  → "اهدئي يا جمانة… خطوة خطوة، والصبر يبلّغ كل شيء."
Step 2: Jomana (JOMANA)  → "شكراً يا زينب — ثباتك يقوّيني."
Step 3: REWARD           → "حصلت على ثبات زينب. ✦"
```
Speaker for Step 2 in UI: "جمانة"
game_over_line: "الشجاعة مش ضجيج… ارجع وامشِ بثبات."

**FATIMA (score 60, "الرفق والفرحة"):**
```
Step 1: Fatima (HELPER)  → "آآ جمانة!"
Step 2: Jomana (JOMANA)  → "فاطمة! مجرد ابتسامتك تذكّرني إن الرفق يفتح كل باب."
Step 3: REWARD           → "حصلت على فرحة فاطمة. ✦"
```
Speaker for Step 2 in UI: "جمانة"
game_over_line: "فرحة فاطمة مازالت معاك… ارجع وحاول."

**FATHER (score 90, "التوكل والأثر"):**
```
Step 1: Father (HELPER)  → "أحسنتِ يا جمانة… كل كلمة طيبة وكل خطوة صالحة تترك أثرًا."
Step 2: Jomana (JOMANA)  → "والأثر ما يكون إلا بالمحاولة والصبر يا بابا."
Step 3: Father (HELPER)  → "من مشى بحكمة وتكلّم بخير بقي ذكره طيباً — أحسنتِ."
Step 4: REWARD           → "اكتملت رحلة جمانة في مرسى زليتن. ✦"
```
Speaker for Step 2 in UI: "جمانة"
game_over_line: "" (no game over after Father — ending triggers instead)

---

## 8. Resume Flow Verification

| Step | Expected | Code status |
|---|---|---|
| Checkpoint triggers at score N | `_start_checkpoint(char_id)` called | ✅ |
| Obstacles cleared | `clear_obstacles()` called | ✅ |
| Collectibles cleared | `clear_collectibles()` called | ✅ |
| Player movement stopped | `set_gameplay_active(false)` | ✅ |
| Tree paused | `get_tree().paused = true` | ✅ |
| NPC slides in from right | `npc_arriving = true` → `_process()` slides X | ✅ |
| Portrait loads | `_build_npc_card()` → `apply_npc_art()` | ✅ |
| Dialogue shows | `_show_enc_step()` | ✅ |
| Player taps → advance | `_input()` → enc_step++ | ✅ |
| Continue pressed | `_on_continue_pressed()` | ✅ |
| Panel hides | `checkpoint_panel.visible = false` | ✅ |
| Tree unpaused | `get_tree().paused = false` | ✅ |
| **NPC leaves screen** | **Missing — NPC stays on pier** | ❌ BUG |
| Countdown 3-2-1 | `countdown_active = true` | ✅ |
| Spawners restart | `_finish_countdown()` | ✅ |
| Camera restored | `_apply_gameplay_cam()` | ✅ |
| Jomana starts running | `set_pose(RUN)` | ✅ |
| First shard spawn | After timer interval (expected delay) | ✅ expected |

---

## 9. What Codex Must Fix

| # | Issue | File | Priority |
|---|---|---|---|
| C1 | Move CheckpointPanel/Card to top of screen (Y=12-160) | `scenes/level2/Level2_Marsa_Playable.tscn` | HIGH |
| C2 | Reduce DimBG opacity from 0.72 → 0.30 | Same scene | HIGH |
| C3 | Fix speaker name per step (ROLE_JOMANA → "جمانة") | `level2_marsa_playable.gd` `_show_enc_step()` | HIGH |
| C4 | Fix Ali dialogue — Step 2 must be from ALI, not Jomana | `level2_encounter_data.gd` | HIGH |
| C5 | NPC slides off-screen on continue (before countdown) | `level2_marsa_playable.gd` `_on_continue_pressed()` | HIGH |
| C6 | Apply corrected dialogue for all 4 characters | `level2_encounter_data.gd` | MEDIUM |
| C7 | Female suffix `أحسنتِ` (not أحسنت) for Father's first line | Same | LOW |

---

## 10. Owner F6 Readiness

**NOT READY for F6 sign-off on the story/encounter flow.**

The gameplay core (running, obstacles, collectibles, camera) is solid.
The encounter VISUAL works (portraits load, characters appear side-by-side).
But the dialogue panel cover issue and the NPC persist issue make the story moment feel broken.

After Codex applies C1–C5: Owner should re-run F6 with this specific focus:
1. Reach score 15 → confirm Ali portrait visible AND dialogue card does not cover him
2. Press "تابع" → confirm Ali slides off-screen before countdown starts
3. Reach score 35 → confirm Zainab portrait visible, speaker name updates correctly per step
4. Run through to Father (score 90) → ending panel with family portrait image

**DO NOT DEPLOY until after this targeted story F6 passes.**
