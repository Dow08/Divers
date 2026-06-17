# Installs the ui-ux-pro-max skill pack into Cowork's active skills folder
# Run by right-clicking -> "Run with PowerShell"

$ErrorActionPreference = "Stop"

$src = "C:\Users\Dow\Desktop\skills-github\ui-ux-pro-max-skill\.claude\skills"
$dst = "C:\Users\Dow\AppData\Roaming\Claude\local-agent-mode-sessions\skills-plugin\142b6a33-fdc6-4fb5-b739-bacecfb9eabd\460199ea-5062-4622-b630-3fa5d8191916\skills"

Write-Host ""
Write-Host "=== ui-ux-pro-max installer ===" -ForegroundColor Cyan
Write-Host ""

# Sanity checks
if (-not (Test-Path $src)) {
    Write-Host "[ERROR] Source folder not found:" -ForegroundColor Red
    Write-Host "  $src" -ForegroundColor Red
    Write-Host "Did you clone the repo into skills-github?" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $dst)) {
    Write-Host "[ERROR] Cowork active skills folder not found:" -ForegroundColor Red
    Write-Host "  $dst" -ForegroundColor Red
    Write-Host ""
    Write-Host "The path may have changed after a Cowork update." -ForegroundColor Yellow
    Write-Host "Looking for similar folders..." -ForegroundColor Yellow
    $base = "C:\Users\Dow\AppData\Roaming\Claude\local-agent-mode-sessions\skills-plugin"
    if (Test-Path $base) {
        Get-ChildItem $base -Recurse -Directory -Filter "skills" | Select-Object -ExpandProperty FullName
    }
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Source : $src"
Write-Host "Target : $dst"
Write-Host ""

$subSkills = Get-ChildItem $src -Directory
Write-Host "Sub-skills to install:" -ForegroundColor Green
foreach ($s in $subSkills) {
    Write-Host "  - $($s.Name)"
}
Write-Host ""

$confirm = Read-Host "Proceed with copy? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

foreach ($s in $subSkills) {
    $target = Join-Path $dst $s.Name
    Write-Host "Copying $($s.Name) -> $target"
    Copy-Item -Path $s.FullName -Destination $dst -Recurse -Force
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Now CLOSE Cowork completely (system tray too) and reopen it."
Write-Host "The new skills should appear in the available_skills list."
Write-Host ""
Read-Host "Press Enter to exit"
