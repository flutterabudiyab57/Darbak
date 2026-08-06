<#
.SYNOPSIS
    Run 'flutter analyze' and return only actionable output to Claude Code.

.DESCRIPTION
    Executes flutter analyze, saves the full log to a temp file, then filters
    the output so Claude Code only receives errors, warnings, hints, file paths,
    and line numbers -- skipping verbose progress lines that waste context tokens.

.PARAMETER ExtraArgs
    Any additional arguments forwarded verbatim to 'flutter analyze'.
    Example: .\flutter_analyze_filtered.ps1 --no-pub

.EXAMPLE
    .\scripts\flutter_analyze_filtered.ps1
    .\scripts\flutter_analyze_filtered.ps1 --no-pub
#>

param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# -- Temp log --
$logFile = Join-Path $env:TEMP ("flutter_analyze_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".log")

# -- Run --
Write-Host "[flutter_analyze_filtered] Running: flutter analyze $ExtraArgs" -ForegroundColor Cyan
$rawOutput = & flutter analyze @ExtraArgs 2>&1
$exitCode  = $LASTEXITCODE

# Save full log for manual inspection
$rawOutput | Out-File -FilePath $logFile -Encoding utf8
Write-Host "[flutter_analyze_filtered] Full log: $logFile" -ForegroundColor DarkGray

# -- Filter --
# Keep lines that contain actionable signals; drop pure progress noise.
$keepPatterns = @(
    'error[:\s]',
    'warning[:\s]',
    'hint[:\s]',
    'info[:\s]',
    '^\s*\d+ error',
    '^\s*\d+ warning',
    '^\s*\d+ hint',
    '^\s*\d+ issue',
    'No issues found',
    'lib[\\/]',
    'test[\\/]',
    '\bat\s+\w',
    '\.dart:\d+',
    'Exception',
    'Error:',
    'Unhandled',
    'flutter analyze'
)

$pattern = ($keepPatterns | ForEach-Object { "($_)" }) -join '|'

$filtered = $rawOutput | Where-Object { $_ -match $pattern }

# -- Output --
if ($filtered) {
    $filtered | ForEach-Object { Write-Output $_ }
} else {
    Write-Output "(No errors, warnings, or hints -- flutter analyze passed cleanly.)"
}

$color = if ($exitCode -eq 0) { 'Green' } else { 'Red' }
Write-Host "`n[flutter_analyze_filtered] Exit code: $exitCode" -ForegroundColor $color
exit $exitCode
