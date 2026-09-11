# Forwards to repo-root copy-to-target.ps1 (see targ.txt).
param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
$forward = Join-Path $repoRoot "copy-to-target.ps1"

if (-not (Test-Path -LiteralPath $forward)) {
    throw "Missing $forward"
}

if ($WhatIf) {
    & $forward -WhatIf
}
else {
    & $forward
}

exit $LASTEXITCODE
