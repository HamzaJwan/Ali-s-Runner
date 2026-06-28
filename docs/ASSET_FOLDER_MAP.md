# Ali Runner — Asset Folder Map

This is the single master map of every asset folder, every expected future file, which milestone needs it, whether it's required now or later, and whether the game already has fallback behavior if the file is missing.

**Do not create fake PNG/audio files. Put real generated assets here when ready.** Every empty folder below is kept tracked with a small `README.md` instead of a placeholder asset.

---

## Characters

| Path | File | Milestone | Required now or later | Fallback exists? |
| --- | --- | --- | --- | --- |
| `assets/characters/ali/` | `ali_idle.png` | v0.5 (existing) | **Required now** | N/A — already in use |
| `assets/characters/ali/` | `ali_run.png` | v0.8A/v0.8B | Single-pose fallback only, used if the 4-frame run cycle below is unavailable | Yes — falls back to `ali_idle.png` |
| `assets/characters/ali/` | `ali_run_1.png` | v0.8B | **Required for full run-cycle polish, but fallback exists.** | Yes — missing frames are skipped; if no run frames exist, falls back to `ali_run.png`, then `ali_idle.png`, then placeholder. Compatibility note: the loader also accepts `ali_run1.png` (no underscore) for this specific frame if `ali_run_1.png` is absent — this is a fallback path, not the preferred name. |
| `assets/characters/ali/` | `ali_run_2.png` | v0.8B | **Required for full run-cycle polish, but fallback exists.** | Yes — same skip/fallback chain as `ali_run_1.png` |
| `assets/characters/ali/` | `ali_run_3.png` | v0.8B | **Required for full run-cycle polish, but fallback exists.** | Yes — same skip/fallback chain as `ali_run_1.png` |
| `assets/characters/ali/` | `ali_run_4.png` | v0.8B | **Required for full run-cycle polish, but fallback exists.** | Yes — same skip/fallback chain as `ali_run_1.png` |
| `assets/characters/ali/` | `ali_jump.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28), not just the `ali_idle.png` fallback | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/ali/` | `ali_fall.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28) | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/ali/` | `ali_land.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28) | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/ali/` | `ali_slide.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28) | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/ali/` | `ali_hurt.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28) | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/ali/` | `ali_victory.png` | v0.8A | Later (per original plan) — **owner note:** a real distinct image now exists on disk for this path (verified 2026-06-28) | Yes — falls back to `ali_idle.png` if ever removed |
| `assets/characters/fatima/` | `fatima_helper.png` | v0.65/v0.67 (already implemented) | **Required for finished art**, game already runs without it | Yes — text placeholder ("فاطمة ⭐") if missing. **Status note:** a file already exists at this path, but it is a real photo (opaque, not cropped/transparent), not the documented game asset — see `assets/characters/fatima/README.md`. The game currently loads and displays this photo directly, since the loader only checks that the file exists and loads. |
| `assets/characters/zainab/` | `zainab_helper.png` | v0.70 (next implementation task) | Later — not required to implement v0.70 | Yes — placeholder ("زينب ❤️" or similar), same pattern as Fatima |
| `assets/characters/jomana/` | `jomana_helper.png` | v0.71 | Later | Yes — placeholder, same pattern |
| `assets/characters/father/` | `father_ending.png` | v0.72 | Later | Yes — placeholder, same pattern |

## Reward / UI Icons

| Path | File | Milestone | Required now or later | Fallback exists? |
| --- | --- | --- | --- | --- |
| `assets/ui/` | `dialogue_panel.png` | v0.85 (optional decoration) | Later, optional | Yes — default panel theme works without it |
| `assets/ui/` | `star_reward.png` | v0.85 | Later, optional | Yes — text-only reward still works |
| `assets/ui/` | `heart_courage.png` | v0.85 | Later, optional | Yes — text-only reward still works |
| `assets/ui/` | `key_path.png` | v0.85 | Later, optional | Yes — text-only reward still works |
| `assets/ui/` | `shield_icon.png` | v0.9 (real shield effect) | Later, optional | Yes — effect can work without an icon |
| `assets/ui/` | `boost_icon.png` | v0.9 (real boost effect) | Later, optional | Yes — effect can work without an icon |

## Obstacles

| Path | File | Milestone | Required now or later | Fallback exists? |
| --- | --- | --- | --- | --- |
| `assets/objects/` | `obstacle_block.png` | v0.5 (existing) | **Required now** | N/A — already in use |
| `assets/objects/` | `obstacle_barrier.png` | v0.75 | Later | Yes — colored `Polygon2D` placeholder, same pattern as existing obstacle |
| `assets/objects/` | `obstacle_cone.png` | v0.75 | Later | Yes — same placeholder pattern |
| `assets/objects/` | `obstacle_crate.png` | v0.75 | Later | Yes — same placeholder pattern |
| `assets/objects/` | `obstacle_sign.png` | v0.75 | Later | Yes — same placeholder pattern |

## Audio

No audio files exist anywhere yet. All of the following are **later**, starting at v0.95 at the earliest, and none currently have fallback needs since no audio plays at all today (silence is the current "fallback").

| Path | File | Milestone |
| --- | --- | --- |
| `assets/audio/ui/` | `button_click.wav` | v0.95 |
| `assets/audio/ui/` | `dialogue_blip.wav` | v0.96 |
| `assets/audio/player/` | `jump.wav` | v0.95 |
| `assets/audio/player/` | `land.wav` | v0.95 |
| `assets/audio/gameplay/` | `hit.wav` | v0.95 |
| `assets/audio/story/` | `checkpoint.wav` | v0.95 |
| `assets/audio/story/` | `reward_star.wav` | v0.95 |
| `assets/audio/story/` | `reward_heart.wav` | v0.95 |
| `assets/audio/story/` | `reward_key.wav` | v0.95 |
| `assets/audio/story/` | `game_over_soft.wav` | v0.95 |
| `assets/audio/story/` | `victory.wav` | v0.95 |
| `assets/audio/ambience/` | `city_day_loop.ogg` | v0.97 |
| `assets/audio/ambience/` | `wind_light_loop.ogg` | v0.97 |
| `assets/audio/ambience/` | `birds_light_loop.ogg` | v0.97 |
| `assets/audio/music/` | `main_loop.ogg` | "Future — Dynamic Music" |
| `assets/audio/music/` | `checkpoint_soft.ogg` | "Future — Dynamic Music" |
| `assets/audio/music/` | `victory_theme.ogg` | "Future — Dynamic Music" |

See `docs/AUDIO_DESIGN_PLAN.md` for file format rules, licensing rules, and the required `docs/AUDIO_CREDITS.md` format for when any audio file is actually added.

---

## Folder Status Summary (as of v0.68)

| Folder | Exists | Tracked (has a file) | Notes |
| --- | --- | --- | --- |
| `assets/characters/ali/` | Yes | Yes | Has `ali_idle.png` + new `README.md` |
| `assets/characters/fatima/` | Yes | Yes | Has `fatima_helper.png` (real photo, see note above) + new `README.md` |
| `assets/characters/zainab/` | Created in v0.68 | Yes (`README.md` only) | Empty until real asset is added |
| `assets/characters/jomana/` | Created in v0.68 | Yes (`README.md` only) | Empty until real asset is added |
| `assets/characters/father/` | Created in v0.68 | Yes (`README.md` only) | Empty until real asset is added |
| `assets/ui/` | Existed, was empty | Yes (`README.md` only, added in v0.68) | Was previously untracked since it had no files |
| `assets/objects/` | Yes | Yes | Has `obstacle_block.png` + new `README.md` |
| `assets/audio/` and all 6 subfolders | Created in v0.68 | Yes (`README.md` only) | Empty until real audio is added |

---

## Reminder

This map exists so future Codex tasks and the owner always know exactly where each future asset belongs, without guessing. Do not create fake/placeholder PNG or audio files anywhere in `assets/` — missing files are handled entirely by the game's existing fallback system, not by fake files on disk.
