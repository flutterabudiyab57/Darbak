<#
.SYNOPSIS
    Run 'flutter test' and return only actionable output to Claude Code.

.DESCRIPTION
    Executes flutter test, saves the full log to a temp file, then filters
    the output so Claude Code only receives failures, errors, exceptions,
    stack traces, and the final pass/fail summary -- skipping per-test dot
    sequences and verbose framework noise that waste context tokens.

.PARAMETER ExtraArgs
    Any additional arguments forwarded verbatim to 'flutter test'.
    Examples:
        .\flutter_test_filtered.ps1
        .\flutter_test_filtered.ps1 test/widget_test.dart
        .\flutter_test_filtered.ps1 --plain-name "my test"

.EXAMPLE
    .\scripts\flutter_test_filtered.ps1
    .\scripts\flutter_test_filtered.ps1 test/widget_test.dart --plain-name "counter"
#>

param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# -- Temp log --
$logFile = Join-Path $env:TEMP ("flutter_test_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".log")

# -- Run --
Write-Host "[flutter_test_filtered] Running: flutter test $ExtraArgs" -ForegroundColor Cyan
$rawOutput = & flutter test @ExtraArgs 2>&1
$exitCode  = $LASTEXITCODE

$rawOutput | Out-File -FilePath $logFile -Encoding utf8
Write-Host "[flutter_test_filtered] Full log: $logFile" -ForegroundColor DarkGray

# -- Filter --
$keepPatterns = @(
    'FAILED',
    'EXCEPTION',
    'Exception',
    'Error[:\s]',
    'error[:\s]',
    'Expected:',
    'Actual:',
    'Which:',
    '^\s+#\d+',
    '\bat\s+\w',
    '\.dart:\d+',
    'package:',
    'Some tests failed',
    'All tests passed',
    '^\d+ test',
    'No tests ran',
    'Unhandled',
    'setUp',
    'tearDown'
)

$pattern = ($keepPatterns | ForEach-Object { "($_)" }) -join '|'

$filtered = $rawOutput | Where-Object { $_ -match $pattern }

# -- Output --
if ($filtered) {
    $filtered | ForEach-Object { Write-Output $_ }
} else {
    if ($exitCode -eq 0) {
        Write-Output "(All tests passed -- no failures or errors.)"
    } else {
        Write-Output "(No recognisable failure pattern found. Last 30 lines of raw output:)"
        $rawOutput | Select-Object -Last 30 | ForEach-Object { Write-Output $_ }
    }
}

$color = if ($exitCode -eq 0) { 'Green' } else { 'Red' }
Write-Host "`n[flutter_test_filtered] Exit code: $exitCode" -ForegroundColor $color
exit $exitCode
