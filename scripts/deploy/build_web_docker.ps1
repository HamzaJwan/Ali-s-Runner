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

    $webRoot = Join-Path $repoRoot "builds\web_rc"
    $webExtras = @(
        @{ Source = "deploy\web\manifest.webmanifest"; Destination = "manifest.webmanifest" },
        @{ Source = "deploy\web\sw.js"; Destination = "sw.js" },
        @{ Source = "deploy\web\icon-192.png"; Destination = "icon-192.png" },
        @{ Source = "deploy\web\icon-512.png"; Destination = "icon-512.png" },
        @{ Source = "assets\fonts\Cairo-Regular.ttf"; Destination = "Cairo-Regular.ttf" }
    )
    foreach ($extra in $webExtras) {
        $source = Join-Path $repoRoot $extra.Source
        if (-not (Test-Path -LiteralPath $source)) {
            throw "Required Web shell asset is missing: $source"
        }
        Copy-Item -LiteralPath $source -Destination (Join-Path $webRoot $extra.Destination) -Force
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
