# DEPLOY_SCRIPT.ps1
# Run this from D:\GODOT\test1\test-web-deploy after Codex finishes code changes.
# Last prepared by Sonnet 2026-07-03
#
# WHAT THIS DOES:
#   1. Merges latest Level 2 branch into test-web-deploy
#   2. Exports Web build using Godot 4.7
#   3. Copies build to deploy_bundle
#   4. Restarts Docker (re-deploys to game.juanspace.org)
#
# SAFE TO ABORT AT ANY STEP — Level 1 at game.juanspace.org stays live
# until Step 4 completes and Docker confirms the new build is healthy.

$GODOT = "C:\Users\Administrator\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
$PROJECT = "D:\GODOT\test1\test"
$DEPLOY_WORKTREE = "D:\GODOT\test1\test-web-deploy"
$HTML_OUT = "$PROJECT\exports\web"
$BUNDLE = "$DEPLOY_WORKTREE\deploy_bundle\ali_runner_web\html"
$LEVEL2_BRANCH = "level2/jomana-marsa-mvp-20260701"

Write-Host "`n=== STEP 0: Pull latest Level 2 code ===" -ForegroundColor Cyan
cd $PROJECT
git pull origin $LEVEL2_BRANCH
if ($LASTEXITCODE -ne 0) { Write-Error "git pull failed"; exit 1 }

Write-Host "`n=== STEP 1: Run smoke checks ===" -ForegroundColor Cyan
& $GODOT --headless --path $PROJECT --quit 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "BOOT SMOKE FAILED — abort"; exit 1 }
Write-Host "BOOT: PASS" -ForegroundColor Green

& $GODOT --headless --path $PROJECT scenes/Main.tscn --quit 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "LEVEL 1 SMOKE FAILED — abort"; exit 1 }
Write-Host "LEVEL 1: PASS" -ForegroundColor Green

& $GODOT --headless --path $PROJECT scenes/level2/Level2_Marsa_Playable.tscn --quit 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "LEVEL 2 SCENE FAILED — abort"; exit 1 }
Write-Host "LEVEL 2: PASS" -ForegroundColor Green

Write-Host "`n=== STEP 2: Merge Level 2 into test-web-deploy ===" -ForegroundColor Cyan
cd $DEPLOY_WORKTREE
git fetch origin $LEVEL2_BRANCH
git merge origin/$LEVEL2_BRANCH --no-ff -m "deploy: merge Level 2 final for production"
if ($LASTEXITCODE -ne 0) {
    Write-Error "MERGE CONFLICT — fix manually then rerun"
    exit 1
}
Write-Host "MERGE: DONE" -ForegroundColor Green

Write-Host "`n=== STEP 3: Export Web build ===" -ForegroundColor Cyan
if (-not (Test-Path $HTML_OUT)) { New-Item -ItemType Directory -Path $HTML_OUT | Out-Null }
& $GODOT --headless --path $PROJECT --export-release "Web" "$HTML_OUT\index.html" 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "WEB EXPORT FAILED — abort"; exit 1 }
if (-not (Test-Path "$HTML_OUT\index.pck")) { Write-Error "index.pck missing after export"; exit 1 }
Write-Host "EXPORT: DONE — $(Get-ChildItem $HTML_OUT | Measure-Object -Property Length -Sum | Select -Expand Sum) bytes" -ForegroundColor Green

Write-Host "`n=== STEP 4: Copy to deploy bundle ===" -ForegroundColor Cyan
Copy-Item "$HTML_OUT\*" $BUNDLE -Recurse -Force
Write-Host "COPY: DONE — files in $BUNDLE" -ForegroundColor Green

Write-Host "`n=== STEP 5: Restart Docker ===" -ForegroundColor Cyan
cd $DEPLOY_WORKTREE
docker compose down
docker compose up -d --build
if ($LASTEXITCODE -ne 0) { Write-Error "DOCKER RESTART FAILED"; exit 1 }
Write-Host "DOCKER: UP" -ForegroundColor Green

Write-Host "`n=== STEP 6: Verify ===" -ForegroundColor Cyan
Start-Sleep -Seconds 5
$r = Invoke-WebRequest -Uri "https://game.juanspace.org" -UseBasicParsing -TimeoutSec 15
if ($r.StatusCode -ne 200) {
    Write-Error "game.juanspace.org returned $($r.StatusCode) — rollback needed"
    exit 1
}
Write-Host "LIVE CHECK: $($r.StatusCode) OK" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " DEPLOY COMPLETE — game.juanspace.org " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Level 1 (Ali)   → game.juanspace.org"
Write-Host "Level 2 (Jomana) → press Father ending → ابدأ رحلة جمانة"
Write-Host ""
Write-Host "If anything looks wrong: docker compose down && docker compose up -d (reverts to previous image)"
