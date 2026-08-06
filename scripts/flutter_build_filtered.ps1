<#
.SYNOPSIS
    Run 'flutter build' and return only actionable output to Claude Code.

.DESCRIPTION
    Executes flutter build <target>, saves the full log to a temp file, then
    filters the output so Claude Code only receives errors, warnings, exceptions,
    Gradle errors, and the final build result -- skipping megabytes of verbose
    Gradle task logs and download progress that waste context tokens.

.PARAMETER Target
    The build target: apk, ios, appbundle, web, etc. (required)

.PARAMETER ExtraArgs
    Any additional arguments forwarded verbatim to 'flutter build <target>'.
    Examples:
        .\flutter_build_filtered.ps1 apk
        .\flutter_build_filtered.ps1 apk --release --split-per-abi
        .\flutter_build_filtered.ps1 appbundle --obfuscate --split-debug-info=symbols/

.EXAMPLE
    .\scripts\flutter_build_filtered.ps1 apk
    .\scripts\flutter_build_filtered.ps1 apk --release
#>

param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Target,

    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# -- Temp log --
$logFile = Join-Path $env:TEMP ("flutter_build_" + $Target + "_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".log")

# -- Run --
Write-Host "[flutter_build_filtered] Running: flutter build $Target $ExtraArgs" -ForegroundColor Cyan
$rawOutput = & flutter build $Target @ExtraArgs 2>&1
$exitCode  = $LASTEXITCODE

$rawOutput | Out-File -FilePath $logFile -Encoding utf8
Write-Host "[flutter_build_filtered] Full log: $logFile" -ForegroundColor DarkGray

# -- Filter --
$keepPatterns = @(
    'error[:\s]',
    'Error[:\s]',
    'warning[:\s]',
    'Warning[:\s]',
    'Exception',
    'Unhandled',
    '\.dart:\d+',
    'lib[\\/]',
    '\bat\s+\w',
    '^\s+#\d+',
    'Built\s+build[\\/]',
    'build[\\/].+\.apk',
    'build[\\/].+\.aab',
    'build[\\/].+\.app',
    'Gradle task',
    'FAILED',
    'BUILD FAILED',
    'BUILD SUCCESSFUL',
    'Execution failed',
    'What went wrong',
    '> Task',
    'Caused by',
    '\.kt:\d+',
    '\.java:\d+',
    'error:',
    'error:.*\.swift',
    'CompileSwift',
    'Undefined symbol',
    'clang error'
)

$pattern = ($keepPatterns | ForEach-Object { "($_)" }) -join '|'

$filtered = @($rawOutput | Where-Object { $_ -match $pattern })

# Secondary pass: drop "> Task :app:XYZ" lines that are NOT followed by FAILED
$cleanedLines = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $filtered.Count; $i++) {
    $line = $filtered[$i]
    if ($line -match '^\> Task ') {
        $nextLine = if ($i + 1 -lt $filtered.Count) { $filtered[$i + 1] } else { '' }
        if ($line -match 'FAILED' -or $nextLine -match 'FAILED') {
            $cleanedLines.Add($line)
        }
    } else {
        $cleanedLines.Add($line)
    }
}

# -- Output --
if ($cleanedLines.Count -gt 0) {
    $cleanedLines | ForEach-Object { Write-Output $_ }
} else {
    if ($exitCode -eq 0) {
        Write-Output "(Build succeeded -- no errors or warnings.)"
    } else {
        Write-Output "(Build failed but no recognisable pattern matched. Last 40 lines of raw output:)"
        $rawOutput | Select-Object -Last 40 | ForEach-Object { Write-Output $_ }
    }
}

$color = if ($exitCode -eq 0) { 'Green' } else { 'Red' }
Write-Host "`n[flutter_build_filtered] Exit code: $exitCode" -ForegroundColor $color
exit $exitCode
