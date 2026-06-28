# Ali Runner — Animation, Asset, Obstacle, and Helper Plan

This is a planning document. Random obstacle selection (Section 3/4) is now implemented as of v0.75 — see the note there. Ali's pose-slot system (v0.8A) and 4-frame run cycle (v0.8B) are also now implemented — see Section 1 below. Helper powers are still not implemented. Nothing in this document changes scenes, scripts, assets, or `project.godot`.

## Guiding Rule

The easiest path is preferred. We do not assume sprite sheets are required to start. The preferred first implementation is separate PNG poses, swapped on a single `Sprite2D` — the same pattern already used for Ali's idle pose, the obstacle, and the backgrounds (`ASSET_UTILS.set_sprite_texture_if_exists`, with a placeholder fallback if the file is missing). Sprite sheets are a later option, only if clearly beneficial once separate poses are working.

---

## 1. Ali Animation Plan (Staged)

### Stage 1 — Pose Switching With Separate PNG Files (preferred first step) — IN PROGRESS (run cycle complete as of v0.8B)

Each pose is its own PNG, swapped on the existing `Sprite2D` the same way `ali_idle.png` is loaded today. No new node types, no `AnimationPlayer`, no `AnimatedSprite2D` yet.

* `ali_idle.png`
* `ali_run.png` (single-pose fallback, used only if the 4-frame run cycle below is unavailable)
* `ali_jump.png`
* `ali_fall.png`
* `ali_land.png`
* `ali_slide.png`
* `ali_hurt.png`
* `ali_victory.png`

Each pose can be added one at a time — the game keeps working with `ali_idle.png` as the fallback for poses that don't exist yet, exactly like the current placeholder behavior.

**Run cycle update (v0.8B, complete):** running specifically now uses a real 4-frame cycle (`ali_run_1.png` through `ali_run_4.png`) instead of a single static run pose — see "Ali 4-Frame Run Cycle Assets" below. This is still Stage 1: separate cached PNG textures swapped on the same `Sprite2D`, at 10 FPS, with no `AnimatedSprite2D` and no sprite sheet involved. `AnimatedSprite2D`/`SpriteFrames` (Stage 2) remains a later optional step only if the animation system grows beyond what simple cached texture-swapping can handle.

### Stage 2 — AnimatedSprite2D / SpriteFrames

Use only after Stage 1's separate poses are stable and already feel good in-game.

* Can use either frame sequences (multiple PNGs per pose) or a sprite sheet at this stage — whichever is easier to produce.
* Does not require perfect/smooth animation early; a 2-4 frame run cycle is enough to start.

### Stage 3 — Full Sprite Sheet

Only later, and only if Stage 2 shows a clear benefit (e.g. smoother run cycle, jump arc, or file-count reduction).

If used, document at implementation time:

* Grid size (columns x rows).
* Frame count per pose.
* Frame naming/order convention.

This is not needed now and should not be designed in detail until Stage 1 and Stage 2 are both working.

### Future Asset Paths — Ali

* `res://assets/characters/ali/ali_idle.png`
* `res://assets/characters/ali/ali_run.png` (single-pose fallback)
* `res://assets/characters/ali/ali_run_1.png`
* `res://assets/characters/ali/ali_run_2.png`
* `res://assets/characters/ali/ali_run_3.png`
* `res://assets/characters/ali/ali_run_4.png`
* `res://assets/characters/ali/ali_jump.png`
* `res://assets/characters/ali/ali_fall.png`
* `res://assets/characters/ali/ali_land.png`
* `res://assets/characters/ali/ali_slide.png`
* `res://assets/characters/ali/ali_hurt.png`
* `res://assets/characters/ali/ali_victory.png`

See roadmap `v0.8 — Ali Basic Animation` and `v0.8B — Ali 4-Frame Run Cycle` for the implementation milestones.

### Ali 4-Frame Run Cycle Assets (v0.8B — complete)

* `res://assets/characters/ali/ali_run_1.png`
* `res://assets/characters/ali/ali_run_2.png`
* `res://assets/characters/ali/ali_run_3.png`
* `res://assets/characters/ali/ali_run_4.png`

Asset creation guidance:

* Best generation workflow: generate one wide image containing four running poses of Ali side by side, then manually cut it into four separate transparent PNG files. This is an art-production technique only — the game still loads four separate PNGs, not a sprite sheet at runtime.
* Each frame must be transparent, with the same face, clothing, proportions, and art style as the rest of Ali's poses.
* Same feet baseline across all four frames, and the same approximate height — misaligned feet or inconsistent height will visibly "slide" or "jump" during the cycle.
* Small dust under Ali's feet is acceptable as future polish (see the dust/shadow reminder below), but it must not break transparency or feet-baseline alignment.

**Next code step (v0.75D planning, 2026-06-28): not full animation yet.** The next implementation task is `v0.8A — Ali Animation Slot System` — building the pose-slot/fallback mechanism described in Stage 1 above (one named slot per pose, each falling back to `ali_idle.png` if its file doesn't exist), without requiring any real pose art to exist yet. The easiest path remains unchanged: (1) support separate pose PNG files first, reusing the existing fallback pattern; (2) support sprite sheets later, only if Stage 2 proves it's actually needed. When real pose images are eventually needed, the assistant must proactively tell the owner the exact path, required size/style, a ready AI-generation prompt, and whether a static PNG or sprite sheet is needed — per the Asset Request Workflow in Section 7 below.

**Future polish reminder (v0.74 planning, 2026-06-28):** when Ali's animation image-generation prompts are actually written (v0.8), include these small ground-feel details so Ali reads as grounded and in motion rather than floating:

* Running dust under his feet.
* A small jump dust puff.
* A small landing dust puff.
* A grounded shadow under Ali.

These are visual polish for later (v0.8 for the dust puffs tied to pose changes, v1.2 for the parallax-layer shadow/dust system already planned there) — not needed now, and not part of v0.74's scope.

---

## 2. Sister / Father Helper Assets

Each helper is a single static portrait image, shown in the reusable checkpoint panel (see `docs/STORY_PLAN.md` Section 11, "Technical Implementation Notes"). **No animation is needed for any helper at this stage** — these are checkpoint portraits, not playable/animated characters.

* `res://assets/characters/fatima/fatima_helper.png` — seated, calm/breathing or gently happy, reaching out one hand offering the star (نجمة الفرح). Not standing, not jumping — Fatima is a newborn and cannot do either. See Section 6 below for the full image-generation prompt.
* `res://assets/characters/zainab/zainab_helper.png`
* `res://assets/characters/jomana/jomana_helper.png`
* `res://assets/characters/father/father_ending.png`

Relative size rules (already documented in `docs/STORY_PLAN.md` Section 6 — repeated here for asset-creation reference):

* Ali is the largest child character.
* Jomana is smaller than Ali, but older than the other sisters.
* Zainab is smaller than Jomana.
* Fatima is the smallest, shown as a seated baby helper/portrait, not a full runner.
* Father is about 2x Ali's height in the ending panel, because he is an adult.

Reward icons (shown alongside or instead of a full helper portrait during the reward moment):

* `res://assets/ui/star_reward.png` (فرحة فاطمة)
* `res://assets/ui/heart_courage.png` (شجاعة زينب)
* `res://assets/ui/key_path.png` (حكمة جمانة)

See roadmap `v0.85 — Static Helper Assets` for the implementation milestone.

**Static-for-now note (v0.73 planning, 2026-06-28):** static PNGs remain fully acceptable for every encounter character right now, including Fatima — a static `fatima_helper.png` is enough for the in-world cinematic encounter template (v0.73). Later idle/breathing animations (small subtle motion, not full pose-switching) would make encounter characters feel more alive, but are not required and should wait until well after the in-world presentation is stable. Separately, Ali's own animation (v0.8) will eventually solve the related issue of Ali standing in a static idle pose while the world implies he's running — but that's Ali's own animation milestone, not a helper-character concern, and is not part of v0.73.

---

## 3. Obstacle Variety Planning — STATUS: COMPLETE (v0.75, verified in code)

**Current state:** all five planned obstacle types exist with real PNG art and are wired up in `scripts/gameplay/obstacle_spawner.gd`, gated by difficulty chapter (`min_chapter`) via `scripts/gameplay/difficulty_manager.gd`. This is no longer planning-only — see Section 4 below for the implemented design.

### Obstacle Types (implemented)

* `obstacle_block.png` — chapter 1+ (weight 8, most common)
* `obstacle_barrier.png` — chapter 2+ (weight 4)
* `obstacle_cone.png` — chapter 3+ (weight 3)
* `obstacle_crate.png` — chapter 4+ (weight 3)
* `obstacle_sign.png` — chapter 4+ (weight 2, rarest)

### Asset Paths (all exist on disk as real PNGs as of v0.75)

* `res://assets/objects/obstacle_block.png`
* `res://assets/objects/obstacle_barrier.png`
* `res://assets/objects/obstacle_cone.png`
* `res://assets/objects/obstacle_crate.png`
* `res://assets/objects/obstacle_sign.png`

See roadmap `v0.75 — Obstacle Variety and Difficulty Chapters` for the full implementation note.

---

## 4. Random Obstacle Selection Design — STATUS: COMPLETE (v0.75, verified in code)

Random obstacle selection is implemented in `ObstacleSpawner._choose_weighted_definition()`.

Implemented approach:

* `OBSTACLE_DEFINITIONS` in `scripts/gameplay/obstacle_spawner.gd` is an array of dictionaries, one per obstacle type, each with: `id`, `asset_path`, `placeholder_color` (fallback, kept for safety even though real art now exists for all five), `visual_target_height`, `collision_width`/`collision_height`, `min_chapter`, and `weight`.
* On each spawn, the current difficulty chapter is read from `DifficultyManager.get_chapter_for_speed()`, then a weighted random pick is made among only the definitions whose `min_chapter` is unlocked.
* All obstacle types spawn offscreen to the right (`SPAWN_X = VIEW_W + SPAWN_MARGIN`), per v0.61 — unchanged by variety.
* Spacing/impossible-combination safety still relies on the existing single-spawn-timer cadence (`SPAWN_INTERVAL`) — no two-obstacle pattern logic was added, so there's no risk of overlapping/impossible jump combinations.

---

## 5. Helper System Planning — How Ali Receives Help

This matches `docs/STORY_PLAN.md` Section 10 ("Reward Meaning") and is repeated here for asset/implementation planning convenience.

**Fatima** — gives نجمة الفرح (the star of joy):

* First implementation (v0.65/v0.7): visual reward text only, no gameplay effect.
* Later effect (v0.9): bonus score or a star bonus.

**Zainab** — gives قلب الشجاعة (the heart of courage):

* First implementation (v0.65/v0.7): visual reward text only.
* Later effect (v0.9): one-hit shield or temporary protection.

**Jomana** — gives مفتاح الطريق (the key to the path):

* First implementation (v0.65/v0.7): visual reward text only.
* Later effect (v0.9): safer obstacle spacing, a short boost, or path guidance.

**Father** — ending only, first:

* No gameplay power.
* Emotional completion of the story (see `docs/STORY_PLAN.md` Section 9, "Father Ending").

No reward is ever framed as a weapon or combat ability, consistent with the no-violence tone.

---

## 6. Future Image-Generation Prompt Planning

Placeholder sections only — full prompts are not written yet, beyond the shared requirements below. When prompts are written later (one character/asset at a time), each must request:

* Transparent PNG.
* Single character only (no extra characters or background scenery baked in).
* No text anywhere in the image.
* No UI elements baked into the image.
* Consistent outfit (matching any previously generated art of the same character).
* Same art style as current Ali (`ali_idle.png`) — semi-realistic 2D, family-friendly.
* Clean alpha (no checkerboard or gray-square artifacts baked into pixels — see `docs/ASSET_REQUIREMENTS.md` "Transparency warning").
* Tightly cropped to the character (minimal empty padding).
* Correct relative size, per the size rules in Section 2 above and `docs/STORY_PLAN.md` Section 6.
* Child-friendly, semi-realistic 2D style — matching the existing project art direction.

### Placeholder Prompt Sections (to be filled in later, one at a time)

* Ali — run pose: *(not written yet)*
* Ali — jump pose: *(not written yet)*
* Ali — fall pose: *(not written yet)*
* Ali — land pose: *(not written yet)*
* Ali — slide pose: *(not written yet)*
* Ali — hurt pose: *(not written yet)*
* Ali — victory pose: *(not written yet)*
* Fatima helper portrait: **written — see "Fatima Helper Portrait — Ready Prompt" below.**
* Zainab helper portrait: *(not written yet)*
* Jomana helper portrait: *(not written yet)*
* Father ending portrait: *(not written yet)*
* Obstacle variety (barrier/cone/crate/sign): *(not written yet)*

### Fatima Helper Portrait — Ready Prompt

Corrected story note (owner feedback): Fatima is a newborn baby. She cannot stand, jump, or run toward Ali — the original generic "happy and active" framing was wrong for her. The correct visual is: Ali arrives and finds Fatima already seated, calm/breathing or gently smiling, reaching out one hand to offer her gift (the star, نجمة الفرح). She stays still; Ali comes to her.

When generating this asset, give the image generator both (a) this prompt and (b) the owner's existing AI-generated reference image of Fatima (the baby character reference sheet already produced earlier — front view / 3/4 view / seated pose / helper pose), so the output matches the established look (cream baby outfit with soft floral pattern, pink color palette, soft brown hair).

Ready prompt:

> Transparent PNG, single character only, no text, no UI, no background, no other characters. A newborn baby girl (Fatima), seated on the ground, calm and breathing or gently smiling — not standing, not jumping, not crawling. She reaches out one hand toward the viewer, offering a small glowing golden star (the gift she gives). Wearing a soft cream-colored baby outfit with a subtle pink floral pattern, matching her established character reference exactly (same outfit, same color palette, same proportions). Semi-realistic 2D children's-game art style, matching the existing art style of the character "Ali" already used in this project. Clean alpha transparency — no checkerboard or gray-square artifacts baked into the pixels. Tightly cropped around the character with minimal empty padding. Proportioned as the smallest character in the cast (smaller than her sisters Zainab and Jomana, much smaller than Ali). Warm, gentle, family-friendly lighting — no violence, no scary elements, no horror.

Confirmed: no animation is needed for this asset — it is one static pose only, used in the checkpoint panel, exactly as already documented in Section 2 above.

---

## 7. Asset Request Workflow

This documents the process for handling future character/asset needs, per owner direction (2026-06-28).

Whenever a roadmap milestone, a story beat, or a Codex implementation report references a character or asset that does not exist yet (e.g. `fatima_helper.png` was referenced by the v0.65 implementation, but is currently missing and using a placeholder), the assistant should proactively:

1. Flag it to the owner — do not wait to be asked.
2. State exactly which file is needed (the exact `res://` path) and which milestone needs it.
3. State the required size/style (dimensions, transparency, art style — matching the existing rules in `docs/ASSET_REQUIREMENTS.md`).
4. Provide a ready-to-use image-generation prompt for that specific asset (see the format used in "Fatima Helper Portrait — Ready Prompt" above as the template: transparent PNG, single character, no text/UI, consistent outfit/style matching the established reference, clean alpha, tightly cropped, correct relative size, child-friendly semi-realistic style, plus any story-specific pose/action detail).
5. State whether a static PNG or a sprite sheet/frame sequence is needed — for every character/asset today, the answer is a static PNG (see Section 1 Stage 1 for Ali, Section 2 for helpers); sprite sheets are not needed for anything currently planned.

For characters/objects carrying specific identity (Fatima, Zainab, Jomana, Father, Libyan buildings, Zliten-specific objects), the prompt must always pair with the owner's existing AI-generated reference — these are not candidates for generic free/stock sourcing. See `docs/ASSET_SOURCING_PLAN.md` for the full sourcing/license plan and which asset categories may safely use free sources instead (generic UI icons, generic obstacles, audio).

Owner's side of the workflow:

* The owner already has AI-generated reference art establishing each character's look (face, outfit, colors, proportions) — produced earlier for Ali, Jomana, Zainab, and Fatima.
* When ready, the owner feeds that reference image plus the provided prompt into an AI image generator to produce the actual transparent-background PNG.
* The owner places the resulting PNG at the documented path. The existing fallback system (`ASSET_UTILS.set_sprite_texture_if_exists`) means the game works with a placeholder until then, and picks up the real asset automatically once it's placed — no code changes needed.

This workflow applies to all future character assets (Zainab, Jomana, Father, Ali's animation poses, obstacle variety) — each one gets this same notify-and-prompt treatment as its milestone approaches, one asset at a time.

---

## 8. Owner Asset Replacement Workflow

A short, explicit checklist version of Section 7, for quick reference. All future asset folders already exist on disk as of v0.68 (see `docs/ASSET_FOLDER_MAP.md`), so the owner only ever needs to drop a file in — no folders to create.

1. When a character or asset is needed, the assistant tells the owner the exact path (e.g. `res://assets/characters/zainab/zainab_helper.png`).
2. The assistant provides a ready-to-use AI image-generation prompt for that specific asset.
3. The owner generates the PNG using the character's existing AI-generated reference image plus that prompt.
4. The owner places the PNG at the exact path given.
5. Godot picks it up automatically through the existing asset loading/fallback system (`ASSET_UTILS.set_sprite_texture_if_exists` / `load_texture_with_fallback`) once implemented for that character — no code changes needed.
6. Start with static helper images first. Do not animate helper characters yet (see Section 2 — no animation is needed for any helper at this stage).

---

## Reminder

Before implementing animation or helper characters, ask the owner to generate/provide the needed PNG assets first. Code changes for these features should not begin until the relevant asset (or an explicit decision to use the placeholder fallback) is in hand.
