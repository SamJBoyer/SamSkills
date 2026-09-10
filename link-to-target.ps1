# Creates a junction/symlink inside this repo that points at the path in targ.txt.
# Default link location: .\skills-target\  (gitignored)
#
# Usage (from this repo root):
#   powershell -NoProfile -File .\link-to-target.ps1

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$targFile = Join-Path $repoRoot "targ.txt"
$linkName = "skills-target"
$linkPath = Join-Path $repoRoot $linkName

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
    throw "Not a directory: $targetAbs"
}

$repoPrefix = $repoAbs.TrimEnd("\") + "\"
if ($targetAbs.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    $targetAbs.Equals($repoAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target must not be inside this repo: $targetAbs"
}

function Get-LinkTarget([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    if (-not $item.LinkType) { return $null }
    $t = @($item.Target)[0]
    if (-not $t) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($t)) {
        $t = Join-Path $item.Parent.FullName $t
    }
    return [System.IO.Path]::GetFullPath($t)
}

if (Test-Path -LiteralPath $linkPath) {
    $existingTarget = Get-LinkTarget $linkPath
    if ($existingTarget) {
        $existingAbs = (Resolve-Path -LiteralPath $existingTarget).Path
        if ($existingAbs.Equals($targetAbs, [StringComparison]::OrdinalIgnoreCase)) {
            Write-Output "Already linked: $linkPath -> $targetAbs"
            exit 0
        }
        throw "Link already exists and points elsewhere: $linkPath -> $existingAbs"
    }
    throw "Path exists and is not a junction/symlink: $linkPath"
}

try {
    New-Item -ItemType Junction -Path $linkPath -Target $targetAbs | Out-Null
    Write-Output "JUNCTION=$linkPath"
}
catch {
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetAbs | Out-Null
    Write-Output "SYMLINK=$linkPath"
}

Write-Output "TARGET=$targetAbs"

# Keep the local slide out of git
$gitignore = Join-Path $repoAbs ".gitignore"
$ignoreLine = "$linkName/"
if (Test-Path -LiteralPath $gitignore) {
    $text = Get-Content -LiteralPath $gitignore -Raw
    if ($text -notmatch "(?m)^skills-target/") {
        if (-not $text.EndsWith("`n")) { $text += "`n" }
        Add-Content -LiteralPath $gitignore -Value "`n# Local junction to Cursor skills target (see targ.txt)`n$ignoreLine"
    }
}
else {
    Set-Content -LiteralPath $gitignore -Value "# Local junction to Cursor skills target (see targ.txt)`n$ignoreLine`n"
}
