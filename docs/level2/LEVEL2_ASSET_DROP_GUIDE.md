# Level 2 Asset Drop Guide — جمانة وأثر الكلمة
# For the owner: how to add new art/audio to the game

**No code changes needed for most assets. Just drop the file in the right folder and reopen the scene.**

---

## Quick Reference Table

| What to drop | Folder | Filename | Auto-loads? |
|---|---|---|---|
| Jomana run frames (8) | `assets/level2/marsa/characters/jomana/run/` | `jomana_run_01.png` … `08.png` | ✅ Yes |
| Jomana idle frames (4) | `assets/level2/marsa/characters/jomana/idle/` | `jomana_idle_01.png` … `04.png` | ✅ Yes |
| Jomana jump | `assets/level2/marsa/characters/jomana/jump/` | `jomana_jump_01.png` | ✅ Yes |
| Jomana land | `assets/level2/marsa/characters/jomana/jump/` | `jomana_land_01.png` | ✅ Yes |
| Jomana wave | `assets/level2/marsa/characters/jomana/story/` | `jomana_smile_wave_01.png` | ✅ Yes |
| Jomana dialogue closeup | `assets/level2/marsa/characters/jomana/story/` | `jomana_dialogue_closeup_01.png` | ✅ Yes |
| Sky background | `assets/level2/marsa/backgrounds/` | `bg_sky_marsa.png` | ✅ Yes |
| Sea + breakwater | `assets/level2/marsa/backgrounds/` | `bg_sea_breakwater.png` | ✅ Yes |
| Harbor buildings | `assets/level2/marsa/backgrounds/` | `bg_harbor_buildings.png` | ✅ Yes |
| Boats mid | `assets/level2/marsa/backgrounds/` | `mg_boats_mid.png` | ✅ Yes |
| Pier ground | `assets/level2/marsa/backgrounds/` | `fg_pier_ground.png` | ✅ Yes |
| Concrete obstacle | `assets/level2/marsa/obstacles/` | `obs_concrete_block_01.png` | ✅ Yes |
| Crate stack obstacle | `assets/level2/marsa/obstacles/` | `obs_crate_stack_01.png` | ✅ Yes |
| Bollard obstacle | `assets/level2/marsa/obstacles/` | `obs_bollard_rope_01.png` | ✅ Yes |
| Broken pier obstacle | `assets/level2/marsa/obstacles/` | `obs_broken_pier_chunk_01.png` | ✅ Yes |
| Ali checkpoint art | `assets/level2/marsa/characters/family/` | `ali_checkpoint_01.png` | ✅ Yes |
| Zainab checkpoint art | `assets/level2/marsa/characters/family/` | `zainab_checkpoint_01.png` | ✅ Yes |
| Fatima checkpoint art | `assets/level2/marsa/characters/family/` | `fatima_checkpoint_01.png` | ✅ Yes |
| Father checkpoint art | `assets/level2/marsa/characters/family/` | `father_checkpoint_01.png` | ✅ Yes |
| Family ending image | `assets/level2/marsa/characters/family/` | `family_marsa_ending_01.png` | ✅ Yes |
| أثر collectible single | `assets/level2/marsa/collectibles/` | `col_athar_shard_pink_gold_01.png` | ✅ Yes |
| أثر collectible sheet | `assets/level2/marsa/collectibles/` | `col_athar_shard_sheet_6f.png` | ✅ Yes |
| Sea ambience audio | `assets/level2/marsa/audio/` | `sea_ambience_loop.ogg` | ✅ Yes (internal test) |
| Harbour music | `assets/level2/marsa/audio/` | `marsa_theme_loop.ogg` | ✅ Yes (internal test) |
| Seagull SFX | `assets/level2/marsa/audio/` | `seagull_distant_01.wav` | ✅ Yes (internal test) |

---

## Step-by-Step After Dropping a File

1. **Copy the PNG/OGG/WAV** to the correct folder using File Explorer.
2. **Switch to Godot editor** — it will automatically detect and import the new file.
3. Wait for the import spinner (bottom-right) to finish.
4. **Press F6** to run `scenes/level2/Level2_Marsa_Playable.tscn`.
5. The new asset appears automatically — no code changes needed.

---

## How to Verify It Worked

| Asset type | What changes in F6 |
|---|---|
| Jomana run frames (all 8) | Teal polygon disappears. Real Jomana runs. |
| Single background layer | That procedural layer replaced by real art. |
| All 5 backgrounds | Full harbor scene renders. |
| Obstacle art | Obstacle nodes show PNG texture on top. |
| Checkpoint art | Ali/Zainab/Fatima/Father show as sprites during dialogue. |
| Audio | Sea sounds and music play on start. |

Also run the asset check tool:
```
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
```

---

## Image Format Requirements (MUST FOLLOW)

- **Format:** PNG with transparent background (alpha channel)
- **No white background** — transparent only
- **Canvas size:** 256×256 px per character frame (all frames SAME size)
- **Background layers:** 1152×648 minimum (2304×648 preferred for looping)
- **Same foot baseline:** in every run/idle/jump frame, feet at same Y pixel
- **Same character scale:** Jomana same height in all frames
- **Facing right:** all gameplay frames must face right
- **No embedded text** or watermarks in the image
- **No baked-in shadow** — transparent PNG only

---

## Common Problems

| Problem | Likely cause | Fix |
|---|---|---|
| Placeholder still shows after dropping run frames | Not all 8 frames present | Check exact filenames: `jomana_run_01.png` … `jomana_run_08.png` |
| Jomana sinks into ground | Foot baseline not consistent across frames | Ensure all frames have feet at same Y pixel |
| Background looks stretched/squashed | Wrong canvas size | Use 1152px wide minimum; do not force non-proportional scale |
| Art looks tiny | Godot is using wrong scale | Check art is 256×256 per frame, not 64×64 |
| Tween "white flash" on background | Transparent layer missing alpha | Export PNG with transparency, not white background |
| Audio not playing | File not found or wrong name | Check exact filename and extension (`.ogg`/`.wav`) |
| Audio plays but no license | File present but no AUDIO_CREDITS entry | Mark as INTERNAL_TEST_ONLY in docs/AUDIO_CREDITS.md |
| File not importing | Godot hasn't noticed yet | Click "Reimport" in FileSystem panel or restart editor |

---

## Audio License Note

Any audio file you drop into `assets/level2/marsa/audio/` will:
- Play correctly for **internal testing** (F6 in editor)
- Be marked `INTERNAL_TEST_ONLY` in the console log
- **Block public release** until you add a CC0/licensed source entry in `docs/AUDIO_CREDITS.md`

This is intentional. Internal testing = OK. Publishing without license docs = NOT OK.
