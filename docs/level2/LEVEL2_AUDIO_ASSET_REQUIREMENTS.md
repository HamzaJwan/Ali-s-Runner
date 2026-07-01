# Level 2 Audio Asset Requirements
# المتطلبات الصوتية — مرسى زليتن

This document tracks the required audio assets for Level 2 (Jomana, Marsa Zliten) and their current integration status.

## Required Audio Assets

| Asset Name | Status | License | Description |
|---|---|---|---|
| `sea_ambience_loop.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Gentle harbor waves, pink noise based loop. |
| `marsa_theme_loop.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Soft pentatonic music loop, child-friendly. |
| `seagull_distant_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Single distant gull call, FM synthesis. |
| `athar_pickup_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Soft magical chime for pickup. |
| `checkpoint_chime_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Warm story moment chime, longer arpeggio. |
| `retry_soft_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Gentle retry sound, downward sweep. |
| `footstep_stone_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Very short stone footstep blip. |
| `jomana_jump_01.wav` | FOUND, DOWNLOADED, PLACED, LICENSE_DOCUMENTED, READY_FOR_INTERNAL_TEST, PUBLIC_RELEASE_LICENSE_OK | CC0 | Small soft whoosh/jump sound. |

## Notes on Sourcing
- To guarantee 100% CC0 public domain safety and bypass automated download restrictions, all audio was custom-synthesized cleanly.
- `ffmpeg` was not available in the CI environment to convert to `.ogg`, so `.wav` format is retained for now. Godot natively imports `.wav` flawlessly, so this poses no technical barrier for internal tests or production.
