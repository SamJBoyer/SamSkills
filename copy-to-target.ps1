# Copies this repo's skill contents into the path stored in targ.txt (one-way sync).
# Excludes .git, the local link folder, and these sync helpers.
#
# Usage (from this repo root):
#   powershell -NoProfile -File .\copy-to-target.ps1
#   powershell -NoProfile -File .\copy-to-target.ps1 -WhatIf

param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$targFile = Join-Path $repoRoot "targ.txt"

if (-not (Test-Path -LiteralPath $targFile)) {
    throw "Missing targ.txt next to this script. Put the absolute destination path on the first line."
}

$targetRaw = (Get-Content -LiteralPath $targFile -TotalCount 1).Trim()
if ([string]::IsNullOrWhiteSpace($targetRaw)) {
    throw "targ.txt is empty. Put the absolute destination path on the first line."
}

$targetPath = [Environment]::ExpandEnvironmentVariables($targetRaw)
$repoAbs = (Resolve-Path -LiteralPath $repoRoot).Path

if (-not (Test-Path -LiteralPath $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
}

$targetAbs = (Resolve-Path -LiteralPath $targetPath).Path
if (-not (Test-Path -LiteralPath $targetAbs -PathType Container)) {
    throw "Target exists and is not a directory: $targetAbs"
}

$repoPrefix = $repoAbs.TrimEnd("\") + "\"
if ($targetAbs.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    $targetAbs.Equals($repoAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target must not be inside this repo: $targetAbs"
}

$robocopyArgs = @(
    $repoAbs,
    $targetAbs,
    "/E",
    "/XD", ".git", "skills-target",
    "/XF", "targ.txt", "link-to-target.ps1", "copy-to-target.ps1", ".gitignore",
    "/R:1",
    "/W:1",
    "/NFL",
    "/NDL",
    "/NP"
)

if ($WhatIf) {
    $robocopyArgs += "/L"
    Write-Output "WhatIf: listing copy plan (no files written)."
}

Write-Output "SOURCE=$repoAbs"
Write-Output "TARGET=$targetAbs"

& robocopy @robocopyArgs
$code = $LASTEXITCODE

# Robocopy: 0-7 success / informational; 8+ failure
if ($code -ge 8) {
    throw "robocopy failed with exit code $code"
}

Write-Output "COPY_OK exit=$code"
Write-Output "Synced repo contents into the path from targ.txt."
exit 0
