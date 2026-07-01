# Web Server Deployment Notes - 2026-07-01

Status: **INTERNAL WEB PLAYTEST PASS / OWNER BROWSER REVIEW REQUIRED**.

This document records the current Ali Runner / Khutwat Al-Khair internal Web RC
deployment. It is documentation only and does not declare a public release.

## Current Deployment

```text
Deployment branch: deploy/internal-web-20260701
Source state: Level 1 RC plus fixed mobile landscape overlay from f439f60
Server: 172.31.1.71
Server path: /opt/Appdata/ali_runner_web
Compose project: ali-runner-web
Container: ali-runner-web
Published port: 8088:80
Internal diagnostic URL: http://172.31.1.71:8088
HTTPS playtest URL: https://game.juanspace.org
```

Latest redeploy:

- Mobile landscape overlay deployed on 2026-07-01.
- Parser-safe RTL escapes are used in `mobile_rotate_overlay.gd`.
- Container health and HTTP/MIME checks passed.
- Server backup: `/opt/Appdata/ali_runner_web.backup_20260701_214626`.
- Previous live directory: `/opt/Appdata/ali_runner_web.previous_20260701_214626`.
- Production remains Level 1 only. Level 2 was not imported or deployed.

## Cloudflare Tunnel Route

```text
Hostname: game.juanspace.org
Service: http://127.0.0.1:8088
Connector: Adc1.71
```

The Cloudflare HTTPS route is the correct browser playtest URL.

Architecture:

```text
Owner browser / phone
        |
        | HTTPS
        v
https://game.juanspace.org
        |
        | Cloudflare Tunnel connector Adc1.71
        v
http://127.0.0.1:8088 on the Ubuntu server
        |
        | Docker published port 8088:80
        v
ali-runner-web container
        |
        | nginx
        v
Godot Web export files
```

The direct IP URL is useful for diagnostics only. Godot Web requires a secure
browser context, so plain HTTP IP access shows:

```text
Secure Context - Check web server configuration (use HTTPS)
```

That direct-IP error is expected and does not mean the Docker deployment is
broken.

## Validation Completed

- Docker image built successfully on the Ubuntu server.
- Container reached `healthy`.
- Existing protected containers remained running and untouched.
- Server-side MIME checks passed:
  - `/` -> `text/html`
  - `index.wasm` -> `application/wasm`
  - `index.pck` -> `application/octet-stream`
  - `index.js` -> `application/javascript`
- Windows-side HTTPS checks for `https://game.juanspace.org` returned HTTP 200
  for `/`, `index.wasm`, `index.pck`, and `index.js`.

## Server Commands

Run on `172.31.1.71`:

```bash
cd /opt/Appdata/ali_runner_web
docker compose -p ali-runner-web ps
docker logs ali-runner-web --tail 100
docker compose -p ali-runner-web up -d --build
docker compose -p ali-runner-web down
```

Follow logs:

```bash
docker logs ali-runner-web --tail 100 -f
```

## Local Rebuild and Bundle

From Windows:

```powershell
cd D:\GODOT\test1\test-web-deploy
.\scripts\deploy\build_web_docker.ps1
```

The current deploy bundle is prepared manually. Copy the generated
`builds/web_rc/` contents into `deploy_bundle/ali_runner_web/html/`, alongside:

```text
Dockerfile
nginx.conf
docker-compose.yml
```

`builds/web_rc/` and `deploy_bundle/` are temporary generated/deployment
content and must not be committed.

## Emergency Localhost Test

If Cloudflare is unavailable but the server is reachable by SSH:

```powershell
ssh -L 8090:127.0.0.1:8088 jwan@172.31.1.71
```

Then open:

```text
http://localhost:8090
```

Browsers treat localhost as a secure context.

## Browser Review Checklist

- Confirm the game loads past the Godot splash on `https://game.juanspace.org`.
- Confirm Arabic text renders correctly with the embedded Cairo font.
- Confirm Start, intro, gameplay, checkpoints, Game Over, Retry, and Restart.
- Confirm audio starts only after browser interaction.
- Confirm desktop and mobile browser layouts are acceptable.

## Remaining Gates

- Owner browser playtest approval.
- Owner visual/audio approval.
- Exact public source/license record for embedded font files.
- Exact public source/license record for release music and SFX.
- Public release approval.

## Level 2 Deployment Path

Do not add Level 2 directly in this deploy-only branch.

Recommended future sequence:

1. Approve Level 1 Gold.
2. Develop Level 2 in `D:\GODOT\test1\test` on branch
   `level2/jomana-marsa-mvp-20260701`.
3. Keep Level 1 playable while adding Level 2 scenes and assets.
4. Obtain owner F6 approval with real art and confirm Level 1 smoke still
   passes.
5. Merge or cherry-pick the approved Level 2 commits into the deploy worktree.
   Do not manually copy random Level 2 files.
6. Add an owner-approved entry point: level select, internal debug button, or
   transition after the Level 1 ending.
7. Extend smoke tests to cover both Level 1 and Level 2 loading.
8. Export a fresh Web build.
9. Deploy first to a separate staging route, such as:

```text
https://level2-test.juanspace.org
```

10. Promote the combined Level 1 + Level 2 build to:

```text
https://game.juanspace.org
```

only after owner visual, audio, story, and browser approval.

Suggested Level 2 asset folders:

```text
assets/backgrounds/level2_marsa/
assets/characters/jomana/
assets/objects/level2/
assets/audio/level2/
```

Using a separate Level 2 staging container and Cloudflare route keeps the
current Level 1 internal RC recoverable while Level 2 is still in progress.
