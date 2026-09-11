# Copies this repo into the path stored in targ.txt (one-way sync, mirror purge).
# For each path present in both places, the newer file wins and is written to the target.
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

$excludeDirNames = @(".git", "skills-target")
$excludeFileNames = @("targ.txt", "link-to-target.ps1", "copy-to-target.ps1", ".gitignore")

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
    if ($WhatIf) {
        Write-Output "WhatIf: would create target directory: $targetPath"
    }
    else {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    }
}

$targetAbs = if (Test-Path -LiteralPath $targetPath) {
    (Resolve-Path -LiteralPath $targetPath).Path
}
else {
    [System.IO.Path]::GetFullPath($targetPath)
}

if (-not (Test-Path -LiteralPath $targetAbs -PathType Container)) {
    throw "Target exists and is not a directory: $targetAbs"
}

$repoPrefix = $repoAbs.TrimEnd("\") + "\"
if ($targetAbs.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    $targetAbs.Equals($repoAbs, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Target must not be inside this repo: $targetAbs"
}

function Test-UnderExcludedDir {
    param(
        [string]$FullPath,
        [string]$RootAbs
    )
    $rootPrefix = $RootAbs.TrimEnd("\") + "\"
    if (-not $FullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $false
    }
    $rel = $FullPath.Substring($rootPrefix.Length)
    foreach ($part in $rel.Split([char[]]@('\', '/'), [System.StringSplitOptions]::RemoveEmptyEntries)) {
        if ($excludeDirNames -contains $part) {
            return $true
        }
    }
    return $false
}

function Get-RelativePath {
    param(
        [string]$FullPath,
        [string]$RootAbs
    )
    $rootPrefix = $RootAbs.TrimEnd("\") + "\"
    return $FullPath.Substring($rootPrefix.Length).Replace("/", "\")
}

function Get-SyncFileMap {
    param(
        [string]$RootAbs
    )
    $map = @{}
    if (-not (Test-Path -LiteralPath $RootAbs)) {
        return $map
    }
    Get-ChildItem -LiteralPath $RootAbs -Recurse -File -Force | ForEach-Object {
        if (Test-UnderExcludedDir -FullPath $_.FullName -RootAbs $RootAbs) {
            return
        }
        if ($excludeFileNames -contains $_.Name) {
            return
        }
        $rel = Get-RelativePath -FullPath $_.FullName -RootAbs $RootAbs
        $map[$rel] = $_
    }
    return $map
}

function Copy-NewerToTarget {
    param(
        [System.IO.FileInfo]$SourceItem,
        [string]$DestPath
    )
    $destDir = [System.IO.Path]::GetDirectoryName($DestPath)
    if (-not (Test-Path -LiteralPath $destDir)) {
        if ($WhatIf) {
            Write-Output "WhatIf: mkdir $destDir"
        }
        else {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    if (-not (Test-Path -LiteralPath $DestPath)) {
        if ($WhatIf) {
            Write-Output "WhatIf: copy -> $DestPath"
        }
        else {
            Copy-Item -LiteralPath $SourceItem.FullName -Destination $DestPath -Force
        }
        return "copied"
    }

    $destItem = Get-Item -LiteralPath $DestPath -Force
    if ($SourceItem.LastWriteTimeUtc -gt $destItem.LastWriteTimeUtc) {
        if ($WhatIf) {
            Write-Output "WhatIf: newer source -> $DestPath"
        }
        else {
            Copy-Item -LiteralPath $SourceItem.FullName -Destination $DestPath -Force
        }
        return "copied"
    }
    if ($SourceItem.LastWriteTimeUtc -lt $destItem.LastWriteTimeUtc) {
        return "skipped_newer_at_target"
    }

    if ($SourceItem.Length -ne $destItem.Length) {
        if ($WhatIf) {
            Write-Output "WhatIf: same time, different size -> $DestPath"
        }
        else {
            Copy-Item -LiteralPath $SourceItem.FullName -Destination $DestPath -Force
        }
        return "copied"
    }
    return "skipped_same"
}

Write-Output "SOURCE=$repoAbs"
Write-Output "TARGET=$targetAbs"
if ($WhatIf) {
    Write-Output "WhatIf: no files written."
}

$sourceMap = Get-SyncFileMap -RootAbs $repoAbs
$targetMap = Get-SyncFileMap -RootAbs $targetAbs

$copied = 0
$skippedNewerAtTarget = 0
$skippedSame = 0
$purged = 0

foreach ($rel in @($sourceMap.Keys | Sort-Object)) {
    $destPath = Join-Path $targetAbs $rel
    $result = Copy-NewerToTarget -SourceItem $sourceMap[$rel] -DestPath $destPath
    switch ($result) {
        "copied" { $copied++ }
        "skipped_newer_at_target" { $skippedNewerAtTarget++ }
        "skipped_same" { $skippedSame++ }
    }
}

foreach ($rel in @($targetMap.Keys | Sort-Object)) {
    if ($sourceMap.ContainsKey($rel)) {
        continue
    }
    $extraPath = Join-Path $targetAbs $rel
    if ($WhatIf) {
        Write-Output "WhatIf: purge $rel"
    }
    else {
        Remove-Item -LiteralPath $extraPath -Force
    }
    $purged++
}

if (-not $WhatIf) {
    Get-ChildItem -LiteralPath $targetAbs -Recurse -Directory -Force |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object {
            $children = Get-ChildItem -LiteralPath $_.FullName -Force
            if ($children.Count -eq 0) {
                Remove-Item -LiteralPath $_.FullName -Force
            }
        }
}

Write-Output "COPY_OK copied=$copied skipped_newer_at_target=$skippedNewerAtTarget skipped_same=$skippedSame purged=$purged"
Write-Output "Synced repo contents into the path from targ.txt (newer file wins at target; extras removed)."
exit 0
