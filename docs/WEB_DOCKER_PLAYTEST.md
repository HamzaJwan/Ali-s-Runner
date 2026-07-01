# Internal Web RC Playtest with Docker

This setup serves the current Level 1 RC locally at `http://localhost:8088`.
It is for internal testing only. It is not a public release and contains no
Level 2 implementation.

## Prerequisites

- Godot 4.7 stable and its matching export templates.
- Docker Desktop using the `desktop-linux` context.
- A Chromium-based browser or Firefox with WebGL 2.0 support.

Godot 4 Web exports use WebGL 2.0 and the Compatibility renderer. This isolated
deployment branch therefore uses `renderer/rendering_method="gl_compatibility"`;
the gameplay branch remains untouched. The Web preset explicitly disables
thread support, so this local server does not require COOP/COEP headers for the
first internal test.

The Web preset keeps desktop texture compression enabled and disables mobile
ETC2/ASTC compression. Godot 4.7 otherwise rejects the preset when those mobile
texture variants have not been imported, even though this internal build targets
desktop browsers.

## Install the Web export templates

In Godot, open **Editor > Manage Export Templates**, then download and install
the templates matching `4.7.stable`. Alternatively, install the official
`Godot_v4.7-stable_export_templates.tpz` manually in that dialog.

The expected template folder is:

```text
%APPDATA%\Godot\export_templates\4.7.stable\
```

## Build and run

From PowerShell at the repository root:

```powershell
.\scripts\deploy\build_web_docker.ps1
.\scripts\deploy\run_web_docker.ps1 -OpenBrowser
```

The build script exports `builds/web_rc/index.html`, validates the Compose
configuration, and builds the nginx image. The run script starts the container
and optionally opens `http://localhost:8088`.

Useful commands:

```powershell
docker compose -f docker-compose.web.yml ps
docker compose -f docker-compose.web.yml logs --tail 100
docker compose -f docker-compose.web.yml down
```

## Browser checklist

1. Confirm the title is `خطوات الخير` and the subtitle is `حكايات من زليتن`.
2. Confirm click/tap/Space starts and jumps.
3. Confirm music starts only after browser interaction.
4. Confirm the HUD, checkpoints, Retry, Restart, and Game Over card work.
5. Open browser developer tools and check for missing `.wasm`, `.pck`, or `.js`
   requests.
6. Test the page at desktop size and in mobile device emulation.

## Embedded Arabic font

The Web build embeds `assets/fonts/Cairo-Regular.ttf` and applies it globally
through `themes/arabic_ui_theme.tres`. This avoids relying on Windows system-font
fallbacks, which are unavailable inside the WebAssembly build and previously
caused Arabic UI text to render as missing-glyph boxes.

The owner explicitly authorized this font for the internal Web playtest. Record
its exact download source and redistribution license before any public release;
this internal approval is not a substitute for public-release license records.

## Moving to a production server later

1. Complete owner visual, audio, and story approval.
2. Resolve the public license/source record for `level1_exciting_loop.ogg`.
3. Produce a fresh release Web export and build a versioned Docker image.
4. Push the image to a private or public container registry.
5. Deploy behind HTTPS with a real domain and a reverse proxy.
6. Add cache headers for versioned assets only after release filenames are
   stable. Keep `index.html` short-lived.
7. Run desktop and mobile browser acceptance tests before public traffic.

Official references:

- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://docs.godotengine.org/en/stable/classes/class_editorexportplatformweb.html

## Hosted internal HTTPS playtest

The current hosted test is available at:

```text
https://game.juanspace.org
```

Architecture:

```text
Owner browser / phone
        |
        | HTTPS
        v
https://game.juanspace.org
        |
        | Cloudflare Tunnel connector: Adc1.71
        v
http://127.0.0.1:8088 on 172.31.1.71
        |
        | Docker published port 8088:80
        v
ali-runner-web container
        |
        | nginx
        v
Godot Web export files
```

Deployment details:

```text
Server: 172.31.1.71
Host path: /opt/Appdata/ali_runner_web
Compose project: ali-runner-web
Container: ali-runner-web
Port: 8088:80
Cloudflare hostname: game.juanspace.org
Cloudflare service: http://127.0.0.1:8088
```

### Why direct IP HTTP may fail but Cloudflare HTTPS works

`http://172.31.1.71:8088` is useful for server and container diagnostics.
Browser playtesting should use `https://game.juanspace.org`.

Godot Web can require a browser Secure Context. A plain HTTP IP address is not
a Secure Context, while the Cloudflare Tunnel provides HTTPS externally and
forwards requests internally to `http://127.0.0.1:8088`. The direct-IP Secure
Context message is expected and is not a Docker failure.

### Rebuild and redeploy

Local Windows export/build:

```powershell
cd D:\GODOT\test1\test-web-deploy
.\scripts\deploy\build_web_docker.ps1
```

The current server bundle was prepared manually. It contains only:

```text
deploy_bundle/ali_runner_web/
  Dockerfile
  nginx.conf
  docker-compose.yml
  html/
```

The `html/` folder is copied from `builds/web_rc/`. Neither folder is committed.

Server rebuild:

```bash
ssh jwan@172.31.1.71
cd /opt/Appdata/ali_runner_web
docker compose -p ali-runner-web up -d --build
docker logs ali-runner-web --tail 100
```

Follow logs:

```bash
docker logs ali-runner-web --tail 100 -f
```

Stop this stack only:

```bash
cd /opt/Appdata/ali_runner_web
docker compose -p ali-runner-web down
```

### Public release blockers

This is an **internal HTTPS playtest**, not a public release.

- Owner visual, audio, story, desktop, and mobile approval.
- Confirm the embedded Arabic font source and redistribution license.
- Confirm public asset/audio credits.
- Confirm the license/source for `level1_exciting_loop.ogg`.
- Complete final mobile QA.
- Level 2 is not wired into the Web build yet.

### How to add Level 2 later

Phase 1:

- Finish Level 2 in `D:\GODOT\test1\test`.
- Use branch `level2/jomana-marsa-mvp-20260701`.
- Obtain owner F6 approval with real art.
- Confirm the Level 1 smoke test still passes.

Phase 2:

- Merge or cherry-pick the approved Level 2 commits into the deploy worktree.
- Do not manually copy random Level 2 files into the deploy worktree.
- Preserve Git history so the combined build is reviewable and reversible.

Phase 3:

- Wire Level 2 through one owner-approved entry point:
  - level-select menu;
  - internal debug route/button;
  - transition after the Level 1 ending.

Phase 4:

- Re-export the Web build with Level 2 included.
- Recreate the runtime bundle.
- Deploy to a separate Level 2 staging hostname first.
- Test desktop and phone.
- Promote to `https://game.juanspace.org` only after approval.

Level 2 must not enter the Web build until its F6 review passes, real character
and background assets are confirmed, Arabic text/font rendering works, and Web
performance has been checked.
