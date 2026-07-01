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

## Current browser-test blocker

The first Docker browser run loads the HTML, JavaScript, PCK, and WASM files
successfully, but Arabic UI text renders as missing-glyph boxes. The project has
no embedded `.ttf` or `.otf` font, so the Web build cannot rely on the Windows
system-font fallback available during local editor testing.

Before this build can pass owner browser review, add a locally packaged Arabic
font with documented redistribution rights, assign it through the Godot UI
theme, and rebuild the Web export. Do not solve this by copying a Windows font
or downloading an unlicensed font into the deployment branch.

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
