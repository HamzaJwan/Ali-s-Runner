# Level 2 Playable Foundation — Owner Test Guide
# جمانة وأثر الكلمة — مرسى زليتن

**Status:** MVP Foundation — Internal Testing Only
**Not wired into main menu.  Not default boot scene.  Not public release.**

---

## How to Open the Scene

1. Open the Godot editor.
2. In the **FileSystem** panel, navigate to:
   ```
   scenes/level2/Level2_Marsa_Playable.tscn
   ```
3. Double-click to open.
4. Press **F6** (or the Run Scene button) to play THIS scene directly.

> **Do NOT press F5** — that runs `scenes/Main.tscn` (Level 1). Press F6 for Level 2.

---

## What You Will See

| Element | Status |
|---|---|
| Title screen: "جمانة وأثر الكلمة" | ✅ |
| Harbour background (5 layers) | ✅ Procedural placeholder |
| Water shimmer animation | ✅ Shader or tween fallback |
| Boat bobbing | ✅ Sin animation |
| Seagulls flying | ✅ Procedural |
| Jomana character | ✅ Teal placeholder (same physics as Ali) |
| "جمانة" label above character | ✅ |
| Run and jump with Space/click/tap | ✅ |
| Obstacle spawning | ✅ Same engine as Level 1 |
| Pink/gold أثر collectibles | ✅ Same engine as Level 1 |
| "الأثر: N" HUD counter | ✅ |
| Ali checkpoint at score 15 | ✅ Placeholder text |
| Zainab checkpoint at score 35 | ✅ Placeholder text |
| Fatima checkpoint at score 60 | ✅ Placeholder text |
| Father ending at score 90 | ✅ Placeholder text |
| Game Over card | ✅ Arabic, animated |
| Retry / Restart buttons | ✅ Working |
| Camera cinematic reveal on start | ✅ |
| Harbor establishing zoom-in | ✅ |

---

## What is Placeholder Only — Do NOT Judge Yet

| Element | What is missing |
|---|---|
| Jomana visual | No real art — teal polygon with label |
| Harbor backgrounds | Procedural colored shapes — no final art |
| Checkpoint NPC sprites | Text emoji only — no Ali/Fatima/Zainab/Father art |
| Obstacle visuals | Same Level 1 shapes — no harbor-specific art |
| Sea ambience sound | Not yet integrated |
| Harbor music | Not yet integrated |
| Seagull sound | Not yet integrated |
| Jomana voice/expression | Not yet |
| Checkpoint dialogue (final text) | Draft only — owner approval needed |

---

## What to Verify in Testing

✅ **Gameplay feel:** Does the jump feel the same as Level 1?
✅ **HUD readable:** Is "الأثر: N" visible and not overlapping anything?
✅ **Checkpoint flow:** When score reaches 15, does the panel open?
✅ **Family characters:** Ali → Fatima → Zainab → Father (in this order)?
✅ **Game Over card:** Is it readable? Do Retry/Restart work?
✅ **Arabic RTL:** Are all labels right-to-left and not clipped?
✅ **No visual glitches:** Seagulls, boats, water shimmer — subtle and non-distracting?
✅ **Camera feel:** Does the harbor reveal feel good at the start?

---

## Controls

| Action | Input |
|---|---|
| Jump | Space bar / Click / Tap |
| Advance dialogue | Space / Click / Tap |
| Retry after game over | Click "حاولي من آخر نقطة" |
| Restart from beginning | Click "ابدئي من البداية" |

---

## Testing on Phone (via Docker)

If the web build is deployed (see `docs/WEB_DOCKER_PLAYTEST.md`):
- The main game (Level 1) loads at `http://localhost:8088`
- Level 2 is NOT in the web build yet (not wired to main menu)
- Test Level 2 only via Godot editor for now

---

## What Comes Next

1. Owner approves gameplay feel → start character art sprint
2. Jomana sprite sheets (idle, run 8 frames, jump, land) → replace teal placeholder
3. Harbor background art → replace procedural shapes
4. NPC art for Ali, Fatima, Zainab, Father at harbour positions
5. Final checkpoint dialogue wording → owner approval
6. Sea ambience audio → source CC0, integrate
7. Wire Level 2 into main menu (new scene select or continuation)

---

## Known Limitations at This Stage

- Seagulls disappear when the scene restarts (new ones spawn fresh — normal for MVP)
- Checkpoint NPC arrives from off-screen right (same as Level 1) — placeholder motion only
- No sound effects specific to Level 2 yet (reuses Level 1 audio system)
- Water shimmer may fall back to a tween if the shader fails to compile — still works
- Background does NOT scroll yet (static procedural layers) — parallax comes in Phase 4

---

## Camera / Animation Review Checklist (Phase 2)

After pressing F6, verify:

| Check | What to look for |
|---|---|
| **Jomana large enough?** | She should fill roughly 18–22% of screen height |
| **Camera zoom comfortable?** | Harbor should feel "close-in" but not claustrophobic |
| **Jump arc visible?** | During a full jump, head should NOT be cropped at top |
| **Obstacles visible early?** | You should see obstacles 300+ px before they reach Jomana |
| **Collectible arcs readable?** | Pink gem arcs should be easy to see and judge |
| **Opening reveal smooth?** | Harbor should zoom in gently over ~1.4 seconds |
| **Checkpoint focus OK?** | Slight zoom during dialogue should not feel sudden |
| **UI readable?** | Arabic labels (الأثر: N) must be clear and not too large |
| **Feet on pier?** | Jomana's feet should always touch the stone surface |
| **Placeholder acceptable?** | Teal polygon should read clearly as "a character" |
| **Checkpoint order correct?** | علي (15) → زينب (35) → فاطمة (60) → الأب (90) |
| **Difficulty feels fair?** | Speed increases gradually, obstacles remain beatable |

## Updated Family Checkpoint Order

| Score | Character | Value |
|---|---|---|
| 15 | علي | الكلمة الطيبة بين الأخوة |
| 35 | زينب | الصبر والتفكير الهادئ |
| 60 | فاطمة | الرفق والرحمة |
| 90 | الأب | التوكل والعمل وخير العائلة |

## When to Start Character Art

Once the owner confirms the camera feel is acceptable, signal the Character Lane coder to start generating/sourcing Jomana images per `docs/level2/JOMANA_IMAGE_REQUESTS.md`.
Drop the PNGs in `assets/level2/marsa/characters/jomana/run/` and re-open the scene — the placeholder disappears automatically.
