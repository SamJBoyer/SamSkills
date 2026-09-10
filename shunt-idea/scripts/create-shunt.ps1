param(
    [Parameter(Mandatory = $true)][string]$RepoRoot,
    [Parameter(Mandatory = $true)][string]$TargetPath
)

$ErrorActionPreference = "Stop"

function Get-AbsDir([string]$Path, [bool]$CreateIfMissing) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if (-not $CreateIfMissing) {
            throw "Path does not exist: $Path"
        }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
    $resolved = (Resolve-Path -LiteralPath $Path).Path
    if (-not (Test-Path -LiteralPath $resolved -PathType Container)) {
        throw "Not a directory: $resolved"
    }
    return $resolved
}

$repoAbs = Get-AbsDir $RepoRoot $false
$targetAbs = Get-AbsDir $TargetPath $true

$repoPrefix = $repoAbs.TrimEnd("\") + "\"
if ($targetAbs.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    $targetAbs.Equals($repoAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "TARGET must not be inside INVOKING_REPO: $targetAbs"
}

$name = Split-Path -Leaf $targetAbs
$shuntDir = Join-Path $repoAbs "shunt"
$linkPath = Join-Path $shuntDir $name
New-Item -ItemType Directory -Path $shuntDir -Force | Out-Null

if (Test-Path -LiteralPath $linkPath) {
    $existing = Get-Item -LiteralPath $linkPath -Force
    $existingTarget = $null
    if ($existing.LinkType) {
        $existingTarget = @($existing.Target)[0]
    }
    if ($existingTarget) {
        $existingAbs = Get-AbsDir $existingTarget $false
        if (-not $existingAbs.Equals($targetAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Slide already exists and points elsewhere: $linkPath -> $existingAbs"
        }
    }
    else {
        throw "Path exists and is not a junction/symlink: $linkPath"
    }
}
else {
    New-Item -ItemType Junction -Path $linkPath -Target $targetAbs | Out-Null
}

$gitignore = Join-Path $repoAbs ".gitignore"
$ignoreLine = "shunt/"
if (Test-Path -LiteralPath $gitignore) {
    $text = Get-Content -LiteralPath $gitignore -Raw
    if ($text -notmatch "(?m)^shunt/") {
        if (-not $text.EndsWith("`n")) { $text += "`n" }
        Add-Content -LiteralPath $gitignore -Value "`n# Local slides (junctions/symlinks to other folders on this machine)`n$ignoreLine"
    }
}
else {
    Set-Content -LiteralPath $gitignore -Value "# Local slides (junctions/symlinks to other folders on this machine)`n$ignoreLine`n"
}

$instructions = @"
Sliding means taking a file that belongs in TARGET and copying it across the slide (the symlink at SLIDE). The original stays in this repo unless the user specifically asks to clean it up.

TARGET: $targetAbs
SLIDE: $linkPath

When an idea or file belongs in TARGET, copy it across this SLIDE. Do not switch windows. Do not delete the invoking-repo copy unless the user requests cleanup.
"@
Set-Content -LiteralPath (Join-Path $repoAbs "INSTRUCTIONS.md") -Value $instructions -Encoding utf8

Write-Output "SLIDE=$linkPath"
Write-Output "TARGET=$targetAbs"
