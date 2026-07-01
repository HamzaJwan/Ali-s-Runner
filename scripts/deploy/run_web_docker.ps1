param(
    [switch]$OpenBrowser
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$indexPath = Join-Path $repoRoot "builds\web_rc\index.html"
$url = "http://localhost:8088"

if (-not (Test-Path -LiteralPath $indexPath)) {
    throw "Web build is missing: $indexPath. Run scripts/deploy/build_web_docker.ps1 first."
}

Push-Location $repoRoot
try {
    docker compose -f docker-compose.web.yml up -d
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose failed to start with exit code $LASTEXITCODE"
    }
    docker compose -f docker-compose.web.yml ps
} finally {
    Pop-Location
}

Write-Host "Ali Runner internal Web RC: $url"
if ($OpenBrowser) {
    Start-Process $url
}
