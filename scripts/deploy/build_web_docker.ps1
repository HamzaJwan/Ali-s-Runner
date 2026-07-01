param(
    [string]$GodotPath = "C:\Users\Administrator\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$indexPath = Join-Path $repoRoot "builds\web_rc\index.html"

if (-not (Test-Path -LiteralPath $GodotPath)) {
    throw "Godot console executable not found: $GodotPath"
}

Push-Location $repoRoot
try {
    New-Item -ItemType Directory -Force "builds\web_rc" | Out-Null
    & $GodotPath --headless --path . --export-release Web $indexPath
    if ($LASTEXITCODE -ne 0) {
        throw "Godot Web export failed with exit code $LASTEXITCODE. Install the Godot 4.7 export templates and retry."
    }
    if (-not (Test-Path -LiteralPath $indexPath)) {
        throw "Godot reported success but did not create $indexPath"
    }

    docker compose -f docker-compose.web.yml config --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose validation failed with exit code $LASTEXITCODE"
    }
    docker compose -f docker-compose.web.yml build
    if ($LASTEXITCODE -ne 0) {
        throw "Docker image build failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}
