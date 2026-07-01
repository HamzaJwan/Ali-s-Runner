# Mobile Web Playtest Guide — خطوات الخير
# Last updated: 2026-07-01

Deployment status: **DEPLOYED TO LEVEL 1 HTTPS PLAYTEST / OWNER MOBILE
CONFIRMATION REQUIRED**.

The overlay code is reusable across future chapters, but the build currently
served at `game.juanspace.org` contains Level 1 only. Level 2 remains excluded
until owner F6 approval and a later reviewed merge/cherry-pick.

---

## Public Playtest URL

https://game.juanspace.org

(Internal / LAN fallback: http://172.31.1.71:8088 — note: this may fail Secure Context
for audio/sensors; always prefer the HTTPS route for mobile testing.)

---

## Recommended Mode: Landscape

This is a side-scrolling runner. Landscape gives the player the widest possible view
so obstacles are visible early enough to react.

**Do NOT play in portrait on a phone.** The game is designed for wide screens.

---

## Portrait Gate ("اقلب الهاتف بالعرض")

When a mobile user opens the game in portrait orientation, an overlay appears:

```
[📱 ↔ ▬▬▬]

اقلب الهاتف بالعرض
اللعبة مصممة للعب بالعرض
بعد قلب الهاتف المس الشاشة للمتابعة
```

- Overlay covers full screen with dark background
- Gameplay is automatically paused — no unfair game over while rotating
- When user rotates to landscape, overlay disappears and game resumes

---

## Overlay Technical Notes

- Implemented as a Godot 4 autoload (CanvasLayer, layer=100)
- Active in all scenes included by a build; the current hosted build includes
  Level 1 (Ali) only
- Detection: `viewport_height > viewport_width` AND screen fits phone/tablet dimensions
- Desktop windows are unaffected (screen long-side > 1400px is ignored)
- Game tree paused only if WE triggered the pause — checkpoint dialogues are unaffected
- file: `scripts/ui/mobile_rotate_overlay.gd`

---

## Device Test Checklist

### Android Chrome
- [ ] Open https://game.juanspace.org in portrait
- [ ] Portrait overlay appears ("اقلب الهاتف بالعرض")
- [ ] Game is paused (no background gameplay)
- [ ] Rotate to landscape → overlay disappears
- [ ] Tap screen → gameplay resumes
- [ ] Jump input (tap) works correctly
- [ ] Arabic text readable
- [ ] Audio plays after first tap (browser requires user gesture)
- [ ] Score counter visible top-left

### Samsung Internet
- [ ] Same checks as above
- [ ] No UI overlap with Samsung's navigation bar

### iPhone Safari (if available)
- [ ] Same checks as above
- [ ] No overlap with iOS home bar or notch
- [ ] Touch input correct (no 300ms delay)

### Desktop (Chrome/Firefox)
- [ ] Open at normal size → no overlay
- [ ] Resize window to portrait shape → overlay should appear for testing
- [ ] Resize back to landscape → overlay disappears

---

## Sound on Mobile

Mobile browsers require a user gesture before playing audio. The game handles this
via the play button press ("ابدئي الرحلة") which satisfies the browser policy.

If audio is silent:
1. Tap the screen once (any tap)
2. Press the play button again

---

## Known Limitations

| Item | Status |
|---|---|
| iOS Safari landscape lock | Requires user permission from Settings — overlay is the fallback |
| Level 2 Jomana | Internal F6 only — not yet in Web build |
| Audio loop on Web | WAV files used; OGG conversion later for smaller downloads |
| Orientation lock API | Not implemented (requires JS bridge) — overlay handles UX |
