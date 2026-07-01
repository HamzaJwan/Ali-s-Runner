# Level 2 Audio Asset Requirements
# الصوت — مرسى زليتن

**Rule:** Every audio file must have a CC0 (or explicitly owner-licensed) source entry
in `docs/AUDIO_CREDITS.md` before integration into the game. File presence alone
does NOT authorize use. Owner must verify license before ANY public release.

---

## Required Audio Files

### 1. Sea Ambience Loop
**File:** `assets/level2/marsa/audio/sea_ambience_loop.ogg`
**Format:** OGG Vorbis, stereo, 44100 Hz
**Loop:** Yes — must loop cleanly (no audible click or gap at loop point)
**Volume target:** -24 dB (background, never competing with music or SFX)
**Content:** Gentle harbor waves lapping stone. No storm. No ships. No voices.
**Feel:** The moment you hear it, you should feel the sea breeze.
**Source:** CC0 from Freesound or OpenGameArt. Document exactly: filename, author, URL, license.
**Status:** ⬜ PENDING

### 2. Harbour Theme Music
**File:** `assets/level2/marsa/audio/marsa_theme_loop.ogg`
**Format:** OGG Vorbis, stereo, 44100 Hz
**Loop:** Yes — seamless
**Volume target:** -20 dB (calm background music)
**Content:** Gentle, uplifting Arabic/Mediterranean instrumental. Oud, qanun, or soft
string-based theme. Light, hopeful, not dramatic.
**Feel:** Matches the morning sun, the open sea, and Jomana's kind personality.
**Source:** CC0 required. If using a custom track, owner authorizes locally first, documents license before public release.
**Status:** ⬜ PENDING

### 3. Seagull Distant SFX
**File:** `assets/level2/marsa/audio/seagull_distant_01.wav`
**Format:** WAV, mono, 22050–44100 Hz
**Loop:** No — played occasionally (every 10–20 seconds randomly)
**Volume target:** -18 dB
**Content:** A single distant seagull call. Not screaming. Not multiple birds. Just one.
**Source:** CC0 from Freesound. Document source.
**Status:** ⬜ PENDING

### 4. أثر Pickup SFX
**File:** `assets/level2/marsa/audio/athar_pickup_01.wav`
**Format:** WAV, mono
**Volume target:** -12 dB
**Content:** Soft, magical chime / water-drop / sea-crystal sound. Warm, not harsh.
**Alternative:** Reuse Level 1 `shard_pickup.wav` for MVP (already licensed CC0).
**Status:** ⬜ PENDING (reusing L1 in MVP)

### 5. Checkpoint Chime
**File:** `assets/level2/marsa/audio/checkpoint_chime_01.wav`
**Format:** WAV, mono
**Volume target:** -10 dB
**Content:** A gentle, warm bell/chime indicating a story moment. Different character than Level 1.
**Alternative:** Reuse Level 1 `checkpoint.wav` for MVP.
**Status:** ⬜ PENDING (reusing L1 in MVP)

### 6. Retry / Soft Game Over
**File:** Reuse Level 1 `game_over.wav`
**Status:** ✅ Available (Level 1 reuse)

### 7. Footstep on Stone (Later Only)
**File:** `assets/level2/marsa/audio/footstep_stone_01.wav`
**Format:** WAV, mono, short (~0.1s)
**Volume target:** -22 dB (very subtle)
**Notes:** This is nice-to-have, NOT MVP. Implement only after full art integration.

---

## Audio Integration Architecture

Level 2 should create its own audio manager wrapper (do NOT modify Level 1 `audio_manager.gd`):

**Future file:** `scripts/level2/audio/level2_audio_manager.gd`

This wraps Level 1 AudioManager for shared SFX and adds Level 2-specific audio.

---

## License Gate

**Public release is blocked until:**
- Every audio file has a verified source/license entry in `docs/AUDIO_CREDITS.md`
- Owner explicitly approves each track by listening (HUMAN_AUDIO_REVIEW_REQUIRED)
- `level1_exciting_loop.ogg` license is documented (this is a LEVEL 1 blocker, separate from Level 2)

---

## Volume Hierarchy (Reference)

| Layer | Volume | Notes |
|---|---|---|
| Sea ambience | -24 dB | Always present, felt not heard |
| Harbour music | -20 dB | Background, mood-setting |
| Pickup SFX | -12 dB | Clear but not jarring |
| Checkpoint chime | -10 dB | Moment of attention |
| Jump SFX | -10 dB | Feedback |
| Seagull distant | -18 dB | Environmental flavour |
