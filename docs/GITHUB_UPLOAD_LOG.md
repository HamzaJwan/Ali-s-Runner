# GitHub Upload Log

## Repository

* Remote URL: `https://github.com/HamzaJwan/Ali-s-Runner.git`
* Remote name: `origin`
* Branch pushed: `main`

## Upload Date

2026-06-28

## Milestone Uploaded

**v0.61 — stable prototype with story docs and obstacle spawn fix**, as the initial commit (this was the first Git history for the project — no prior repository existed).

Important completed milestones included in this snapshot:

* v0.5 — Playable visual prototype.
* v0.55 — Story and future feature documentation.
* v0.6 — Gameplay feel polish (gravity 1050, jump velocity -440, max fall speed 700, jump input buffer 0.12s, obstacle speed 225, spawn interval 2.25s).
* v0.61 — Obstacle spawn offscreen fix (obstacles now spawn at `x = 1292`).

## Files/Folders Included in Git

* `.editorconfig`, `.gitattributes`, `.gitignore`, `README.md`
* `project.godot`, `icon.svg`, `icon.svg.import`, `node_3d.tscn`
* `assets/` (all current backgrounds, character, and object PNGs and their `.import` files)
* `docs/` (`AI_GAME_ROADMAP.md`, `STORY_PLAN.md`, `FUTURE_FEATURE_BACKLOG.md`, `ASSET_REQUIREMENTS.md`, `AUDIO_DESIGN_PLAN.md`)
* `scenes/` (`Main.tscn`, `Player.tscn`, `Obstacle.tscn`)
* `scripts/` (`main.gd`, `player.gd`, `obstacle.gd`, `asset_utils.gd`, and their `.uid` files)
* `visual_check.gd.uid`

## Files/Folders Intentionally Ignored

Per `.gitignore`:

* `.godot/` (Godot's local editor cache — regenerated automatically, never belongs in source control)
* `/android/` (Android export artifacts)
* `*.translation`
* `export/`
* `builds/`
* `.DS_Store`, `Thumbs.db` (OS-specific files)

`.import` and `.uid` files were kept tracked, since they hold Godot import settings the project depends on.

## Exact Git Commands Used

```
git init
git remote add origin https://github.com/HamzaJwan/Ali-s-Runner.git
git add -- .editorconfig .gitattributes .gitignore README.md assets docs icon.svg icon.svg.import node_3d.tscn project.godot scenes scripts visual_check.gd.uid
git commit -m "v0.61 stable prototype with story docs and obstacle spawn fix"
git branch -M main
git push -u origin main
```

## Commit

* Commit hash: `a290410` (full: `a29041072ab4ffeb7645c4c136a37146a41a0704`)
* Commit message: `v0.61 stable prototype with story docs and obstacle spawn fix`
* 37 files changed, 2480 insertions.

## Remote Branch Pushed

`main` — set up to track `origin/main`. Push reported `[new branch] main -> main`.

## Warnings / Authentication Issues

None. The repository had no prior commits (fresh remote, matching the empty-repo state shown in the GitHub web UI), so this was a plain push with no conflicts and no force-push needed. Git's global identity (`user.name` / `user.email`) was already configured on this machine, so no credential prompt was required for the commit itself; the push to GitHub completed without any reported authentication error.
