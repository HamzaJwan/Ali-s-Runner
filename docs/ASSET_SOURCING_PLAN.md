# Ali Runner — Free Asset Sourcing and License Plan

This is a planning document only. No assets are downloaded, replaced, or marked as included by this document. Nothing in this document changes scripts, scenes, gameplay, or `project.godot`.

## Why This Document Exists

Ali Runner is set in a specific, real place — شارع المنطرحة، زليتن، ليبيا (Al-Mantarah street, Zliten, Libya) — and tells a specific family's story (علي ونور البيت). That specificity means generic internet stock art cannot carry most of the game's identity. This document splits future assets into two honest categories so the project never accidentally relies on a mismatched or license-risky asset:

* **Assets that must stay AI-generated/custom**, because they represent specific people, a specific family, and a specific Libyan place.
* **Assets that can safely use free/CC0 internet sources**, because they're generic and don't carry story-specific identity.

## 1. Safe Asset Source Rules

* Never download a random image from a general web/image search ("Google Images") and use it directly — there is no reliable way to know its real license that way.
* Only use assets from sources that publish clear, asset-level license information (see Section 3).
* Every downloaded asset must be logged in `docs/ASSET_CREDITS.md` (or `docs/AUDIO_CREDITS.md` for audio) before — or as part of — being placed in the project.
* If a source's license for a specific asset is unclear, unlisted, or contradictory, do not use that asset. Pick a different one or wait.
* Never place a downloaded asset with the intent to "fix the license later" — the credit/license entry must exist at the same time the file is added.

## 2. Preferred License Order

1. **CC0 first** (public domain / no rights reserved) — no attribution required, safest for a project that may be shared publicly with family or beyond.
2. **CC-BY** only if attribution is documented in `docs/ASSET_CREDITS.md` (visuals) or `docs/AUDIO_CREDITS.md` (audio) at the time the asset is added.
3. **Avoid NonCommercial (NC) licenses** if the game may ever be shared publicly (web export, app store, shown outside the family) — NC licenses restrict exactly that kind of distribution.
4. **Avoid unknown or undocumented licenses** entirely — if a source doesn't clearly state a license per-asset, treat it as not usable.

## 3. Suggested Source Types (Generic Assets Only)

These are appropriate only for the generic categories in Section 6 below — never for Fatima/Zainab/Jomana/Father/Ali or any Libyan-specific background element.

* **Kenney** (kenney.nl) — CC0 game/UI asset packs; a strong first choice for generic UI icons and simple obstacle-style shapes.
* **OpenGameArt** — filter specifically for CC0 collections; many contributors use other licenses, so the filter matters.
* **Freesound** — only when filtering specifically for CC0 sounds, or when an asset's CC-BY attribution can be documented correctly and completely.
* **Pixabay** and **Mixkit** — usable only after checking the license shown on that specific asset's page; their site-wide license terms have changed over time, so don't assume based on the platform name alone.

## 4. Required Metadata for Every Downloaded Asset

Every asset sourced from outside the project must have this metadata recorded in `docs/ASSET_CREDITS.md` (visual) or `docs/AUDIO_CREDITS.md` (audio) before it's considered usable:

* File name (the exact name placed in the project).
* Source URL (the exact page the asset was found on).
* Author.
* License (exact license name/version, e.g. "CC0 1.0", "CC-BY 4.0").
* Usage in game (where/how it's used).
* Whether attribution is required, and if so, where the attribution is shown (credits screen, README, etc. — to be decided when audio/credits screens are actually implemented).
* Date downloaded.

## 5. Downloaded Assets Are Temporary Unless They Match Libyan/Zliten Style

Any free/sourced asset used as a placeholder or stand-in (e.g. a generic UI icon, a generic obstacle shape) should be treated as temporary unless it genuinely matches the project's established semi-realistic, warm, Al-Mantarah/Zliten art direction. A free asset that doesn't match the established look is acceptable as a stepping stone, not as a final answer — it's fine to plan replacing it later with a custom or better-matched asset.

## 6. AI-Generated Custom Assets Are Preferred For

These must not be sourced from generic free-asset sites, because they carry specific identity that no generic asset can correctly represent:

* **Fatima** (newborn baby sister) — has an established reference look (cream outfit, pink floral pattern, soft brown hair) that only a custom-generated or custom-photographed asset can match.
* **Zainab** — same reasoning; a specific sister with an established or future reference look.
* **Jomana** — same reasoning.
* **Father** — same reasoning, plus the specific adult/family-relationship framing of the ending.
* **Libyan buildings** — the project's whole visual identity is Al-Mantarah, Zliten specifically, not a generic Middle Eastern or generic "desert town" template; generic stock buildings would undercut that.
* **Zliten-specific environmental objects** — anything meant to read as authentically local (street furniture, signage style, palm/architecture details) should stay custom-generated or custom-sourced from real reference, not generic stock art.

## 7. What This Document Does Not Do

* It does not download, place, or mark any asset as "included." Every category above remains unsourced until the owner actually generates or downloads something and it's logged per Section 4.
* It does not replace any existing asset (including the real-photo `fatima_helper.png` already in the project — see `docs/ASSET_FOLDER_MAP.md` and `docs/AI_GAME_ROADMAP.md` for that open item).
* It does not change which assets are required vs. optional — that remains governed by `docs/ASSET_REQUIREMENTS.md` and the existing fallback/placeholder system.

See also `docs/AUDIO_DESIGN_PLAN.md` (audio-specific licensing rules, already aligned with this plan) and `docs/ANIMATION_AND_ASSET_PLAN.md` (the Asset Request Workflow for proactively flagging needed character assets with ready prompts).
