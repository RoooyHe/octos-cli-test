# Octos CLI Automated Test Script
# For Windows PowerShell

param(
    [string]$OctosBinary = "octos",
    [string]$OutputDir = "test-results",
    [string]$ConfigFile = "",
    [switch]$Verbose
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($ConfigFile -eq "")
{
    $ConfigFile = Join-Path $ScriptDir "test_cases.json"
}

$ErrorActionPreference = "Continue"
$Script:Cancelled = $false

# Ctrl+C Handler
$host.UI.RawUI.FlushInputBuffer()
$script:Cancelled = $false
$global:originalCancelToken = $null

function Stop-TestRun
{
    $Script:Cancelled = $true
    Write-Host "`n[CANCELLED] Test run cancelled by user" -ForegroundColor Yellow
    Write-Log "[CANCELLED] Test run cancelled by user"

    # Kill any running processes
    Get-Process | Where-Object { $_.CommandLine -like "*octos*" } | ForEach-Object {
        try
        {
            $_.Kill()
        }
        catch
        {
        }
    }

    # Generate partial report
    if ($Script:Results.Count -gt 0)
    {
        $reportPath = "$OutputDir\CLI_TEST_REPORT_CANCELLED_$( Get-Date -Format 'yyyyMMdd_HHmmss' ).md"
        $partialReport = @()
        $partialReport += "# Octos CLI Test - Cancelled"
        $partialReport += ""
        $partialReport += "Test run was cancelled. Partial results:"
        $partialReport += ""
        $partialReport += "| ID | Category | Test Name | Status |"
        $partialReport += "|----|----------|-----------|--------|"
        foreach ($r in $Script:Results)
        {
            $partialReport += "| $( $r.TestId ) | $( $r.Category ) | $( $r.TestName ) | $( $r.Status ) |"
        }
        $partialReport += "" | Out-File -FilePath $reportPath -Encoding UTF8
        Write-Host "Partial report: $reportPath" -ForegroundColor Yellow
    }

    exit 1
}

# Register Ctrl+C handler
[Console]::TreatControlCAsInput = $false
if ($Host.Name -eq "ConsoleHost")
{
    $script:CancelHandler = {
        Stop-TestRun
    }
    [Console]::CancelKeyPress += $script:CancelHandler
}
$TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ReportDate = Get-Date -Format "yyyy-MM-dd_HHmm"
$Script:Passed = 0
$Script:Failed = 0
$Script:Skipped = 0
$Script:Total = 0
$Script:Results = @()

# Setup directories
if (-not (Test-Path $OutputDir))
{
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$logsDir = "$OutputDir\logs"
if (-not (Test-Path $logsDir))
{
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$logFile = "$logsDir\test_$( Get-Date -Format 'yyyyMMdd_HHmm' ).log"

function Write-Log
{
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8
}

function Write-VerboseLog
{
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8
    if ($Verbose)
    {
        Write-Host $logLine -ForegroundColor Gray
    }
}

function Load-TestCases
{
    param([string]$ConfigPath)

    if (-not (Test-Path $ConfigPath))
    {
        Write-Host "[ERROR] Config file not found: $ConfigPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "Loading tests from: $ConfigPath" -ForegroundColor Cyan
    Write-Log "Loading test configuration from: $ConfigPath"

    $jsonContent = Get-Content -Path $ConfigPath -Raw -Encoding UTF8
    $config = $jsonContent | ConvertFrom-Json

    $tests = @()
    foreach ($t in $config.tests)
    {
        $testObj = @{
            Id = $t.id
            Category = $t.category
            Name = $t.name
            Command = $t.command
            Expected = $t.expected
            Validation = if ($t.validation) { $t.validation } else { "contains" }
            Timeout = if ($t.timeout) { [int]$t.timeout } else { 60 }
            Type = if ($t.type) { $t.type } else { "cli" }
            Path = if ($t.path) { $t.path } else { "" }
            ShouldExist = if ($t.should_exist) { [bool]$t.should_exist } else { $true }
        }
        $tests += [PSCustomObject]$testObj
    }

    Write-Log "Loaded $($tests.Count) test cases"
    return $tests
}

function Invoke-TestCase
{
    param(
        [PSCustomObject]$Test,
        [string]$TestDir,
        [string]$TempDir
    )

    if ($Script:Cancelled)
    {
        return
    }

    $Script:Total++

    $cmdArgs = $Test.Command
    $cmdArgs = $cmdArgs.Replace("{testDir}", $TestDir)
    $cmdArgs = $cmdArgs.Replace("{tempDir}", $TempDir)

    if ($Test.Type -eq "file_check")
    {
        $path = $Test.Path.Replace("{testDir}", $TestDir).Replace("{tempDir}", $TempDir)
        $path = $path.Replace("/", "\")

        $exists = Test-Path $path
        $passed = $exists -eq $Test.ShouldExist

        if ($passed)
        {
            $Script:Passed++
        }
        else
        {
            $Script:Failed++
        }

        $actualMsg = if ($exists) { "Path exists: $path" } else { "Path not found: $path" }

        $Script:Results += [PSCustomObject]@{
            TestId = $Test.Id
            Category = $Test.Category
            TestName = $Test.Name
            Args = "(file check)"
            Expected = if ($Test.ShouldExist) { "exists" } else { "not exists" }
            Actual = $actualMsg
            FullOutput = $actualMsg
            Status = if ($passed) { "PASS" } else { "FAIL" }
            ExitCode = 0
        }

        Write-Log "[FILE CHECK] $path"
        Write-Log "[STATUS] $( if ($passed) { 'PASS' } else { 'FAIL' } )"
        Write-Log ""

        $status = if ($passed) { "[PASS]" } else { "[FAIL]" }
        $color = if ($passed) { "Green" } else { "Red" }
        Write-Host "$status $( $Test.Id ) $( $Test.Name )" -ForegroundColor $color
    }
    else
    {
        $result = Get-OctoOutput -CmdArgs $cmdArgs -Timeout $Test.Timeout
        $actual = $result.Stdout + $result.Stderr
        $passed = $false

        switch ($Test.Validation)
        {
            "contains" { $passed = $actual -like "*$($Test.Expected)*" }
            "not_contains" { $passed = $actual -notlike "*$($Test.Expected)*" }
            "exitcode" { $passed = $result.ExitCode -eq [int]$Test.Expected }
        }

        if ($passed)
        {
            $Script:Passed++
        }
        else
        {
            $Script:Failed++
        }

        $actualTruncated = $actual.Substring(0, [Math]::Min(200, $actual.Length)).Replace("`n", " ").Replace("`r", "")

        $Script:Results += [PSCustomObject]@{
            TestId = $Test.Id
            Category = $Test.Category
            TestName = $Test.Name
            Args = $cmdArgs
            Expected = $Test.Expected
            Actual = $actualTruncated
            FullOutput = $actual
            Status = if ($passed) { "PASS" } else { "FAIL" }
            ExitCode = $result.ExitCode
        }

        Write-Log "[EXEC] octos $cmdArgs"
        Write-Log "[EXITCODE] $( $result.ExitCode )"
        Write-Log "[STDOUT] $( $result.Stdout )"
        if ($result.Stderr)
        {
            Write-Log "[STDERR] $( $result.Stderr )"
        }
        Write-Log "[STATUS] $( if ($passed) { 'PASS' } else { 'FAIL' } )"
        Write-Log ""

        $status = if ($passed) { "[PASS]" } else { "[FAIL]" }
        $color = if ($passed) { "Green" } else { "Red" }
        Write-Host "$status $( $Test.Id ) $( $Test.Name )" -ForegroundColor $color
    }
}

function Get-OctoOutput
{
    param([string]$CmdArgs, [int]$Timeout = 60)

    if ($Script:Cancelled)
    {
        return @{
            ExitCode = -1
            Stdout = ""
            Stderr = "Test cancelled"
        }
    }

    $proc = $null
    try
    {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "cmd"
        $fullCmd = "/c `"`"$OctosBinary`" $CmdArgs`""
        $psi.Arguments = $fullCmd
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
        $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
        $proc = [System.Diagnostics.Process]::Start($psi)

        $stdout = ""
        $stderr = ""
        $exited = $proc.WaitForExit($Timeout * 1000)

        if (-not $exited)
        {
            try
            {
                $proc.Kill($true)
                $proc.WaitForExit(1000)
            }
            catch
            {
            }
            return @{
                ExitCode = -1
                Stdout = ""
                Stderr = "Timeout after $Timeout seconds"
            }
        }

        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()

        return @{
            ExitCode = $proc.ExitCode
            Stdout = $stdout
            Stderr = $stderr
        }
    }
    catch
    {
        if ($proc -and -not $proc.HasExited)
        {
            try
            {
                $proc.Kill()
            }
            catch
            {
            }
        }
        return @{
            ExitCode = -1
            Stdout = ""
            Stderr = $_.Exception.Message
        }
    }
    finally
    {
        if ($proc -and -not $proc.HasExited)
        {
            try
            {
                $proc.Dispose()
            }
            catch
            {
            }
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Octos CLI Automated Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Time: $TestDate" -ForegroundColor Gray
Write-Host "Binary: $OctosBinary" -ForegroundColor Gray
if ($Verbose)
{
    Write-Host "Log File: $logFile" -ForegroundColor Gray
}
Write-Host ""

Write-Log "========================================"
Write-Log "Octos CLI Automated Test"
Write-Log "========================================"
Write-Log "Test Time: $TestDate"
Write-Log "Binary: $OctosBinary"
Write-Log "Verbose Mode: $Verbose"
Write-Log ""

# Check if binary exists
$binaryPath = if (Test-Path $OctosBinary)
{
    $OctosBinary
}
else
{
    (Get-Command $OctosBinary -ErrorAction SilentlyContinue).Source
}
if (-not $binaryPath)
{
    Write-Host "[ERROR] Binary not found: $OctosBinary" -ForegroundColor Red
    Write-Host "Please run: cargo build --all-features" -ForegroundColor Yellow
    Write-Log "[ERROR] Binary not found: $OctosBinary"
    exit 1
}

# Setup test workspace
$testDir = "$env:TEMP\octos-cli-test"
if (Test-Path $testDir)
{
    Remove-Item -Recurse -Force $testDir
}
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Write-Host "Test workspace: $testDir" -ForegroundColor Gray
Write-Log "Test workspace: $testDir"
Write-Host ""

$tempDir = "$env:TEMP\octos-cli-test-temp"
if (-not (Test-Path $tempDir))
{
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

$tests = Load-TestCases -ConfigPath $ConfigFile

$currentCategory = ""
foreach ($test in $tests)
{
    if ($Script:Cancelled)
    {
        break
    }

    if ($test.Category -ne $currentCategory)
    {
        $currentCategory = $test.Category
        Write-Host "`n[$currentCategory]" -ForegroundColor Yellow
        Write-Log "[SECTION] $currentCategory"
    }

    Invoke-TestCase -Test $test -TestDir $testDir -TempDir $tempDir
}

if (Test-Path $tempDir)
{
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

# ========================================
# Generate Report
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Generating Report..." -ForegroundColor Cyan
Write-Log "========================================"
Write-Log "Generating Report..."

$reportPath = "$OutputDir\CLI_TEST_REPORT_$ReportDate.md"
$passRate = if ($Script:Total -gt 0)
{
    [math]::Round($Script:Passed / $Script:Total * 100, 1)
}
else
{
    0
}

$grouped = $Script:Results | Group-Object Category
$catStats = @()
foreach ($g in $grouped)
{
    $cName = $g.Name
    $cTotal = $g.Count
    $cPassed = ($g.Group | Where-Object { $_.Status -eq "PASS" }).Count
    $cFailed = $cTotal - $cPassed
    $cRate = if ($cTotal -gt 0)
    {
        [math]::Round($cPassed / $cTotal * 100, 0)
    }
    else
    {
        0
    }
    $catStats += [PSCustomObject]@{ Category = $cName; Total = $cTotal; Passed = $cPassed; Failed = $cFailed; Rate = $cRate }
}

$reportLines = @()
$reportLines += "# Octos CLI Automated Test Report"
$reportLines += ""
$reportLines += "## Test Information"
$reportLines += ""
$reportLines += "| Item | Content |"
$reportLines += "|------|---------|"
$reportLines += "| Test Date | $TestDate |"
$reportLines += "| Binary | $OctosBinary |"
$reportLines += "| Total Tests | $( $Script:Total ) |"
$reportLines += "| Passed | $( $Script:Passed ) |"
$reportLines += "| Failed | $( $Script:Failed ) |"
$reportLines += "| Pass Rate | $passRate% |"
$reportLines += "| Log File | $logFile |"
$reportLines += ""
$reportLines += "## Summary by Category"
$reportLines += ""
$reportLines += "| Category | Total | Passed | Failed | Pass Rate |"
$reportLines += "|----------|-------|--------|--------|-----------|"
foreach ($stat in $catStats)
{
    $reportLines += "| $( $stat.Category ) | $( $stat.Total ) | $( $stat.Passed ) | $( $stat.Failed ) | $( $stat.Rate )% |"
}
$reportLines += ""
$reportLines += "## Detailed Test Results"
$reportLines += ""
$reportLines += "| ID | Category | Test Name | Args | Expected | Actual | Status |"
$reportLines += "|----|----------|-----------|------|----------|--------|--------|"
foreach ($r in $Script:Results)
{
    $actualEscaped = $r.Actual -replace '"', '\"'
    $reportLines += "| $( $r.TestId ) | $( $r.Category ) | $( $r.TestName ) | $( $r.Args ) | $( $r.Expected ) | $( $actualEscaped ) | $( $r.Status ) |"
}
$reportLines += ""
$reportLines += "## Failed Tests Detail"
$reportLines += ""
$failedTests = $Script:Results | Where-Object { $_.Status -eq "FAIL" }
if ($failedTests.Count -eq 0)
{
    $reportLines += "All tests passed!"
}
else
{
    foreach ($t in $failedTests)
    {
        $reportLines += "### $( $t.TestId ): $( $t.TestName )"
        $reportLines += ""
        $reportLines += "- **Args**: `"$( $t.Args )`""
        $reportLines += "- **Expected**: $( $t.Expected )"
        $reportLines += "- **Exit Code**: $( $t.ExitCode )"
        $reportLines += "- **Full Output**:"
        $reportLines += "<pre>"
        $reportLines += $t.FullOutput
        $reportLines += "</pre>"
        $reportLines += ""
    }
}
$reportLines += ""
$reportLines += "## Environment"
$reportLines += ""
$reportLines += "- OS: Windows"
$reportLines += "- Test Date: $TestDate"
$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by PowerShell test script*"

$reportContent = $reportLines -join "`n"
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "Report: $reportPath" -ForegroundColor Green
Write-Host "Log: $logFile" -ForegroundColor Green
Write-Log "Report saved to: $reportPath"
Write-Log "Log saved to: $logFile"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY: Total=$( $Script:Total ) Passed=$( $Script:Passed ) Failed=$( $Script:Failed ) PassRate=$passRate%" -ForegroundColor $( if ($passRate -ge 80)
{
    "Green"
}
elseif($passRate -ge 60)
{
    "Yellow"
}
else
{
    "Red"
} )
Write-Log "========================================"
Write-Log "SUMMARY: Total=$( $Script:Total ) Passed=$( $Script:Passed ) Failed=$( $Script:Failed ) PassRate=$passRate%"

# Cleanup
if (Test-Path $testDir)
{
    Remove-Item -Recurse -Force $testDir -ErrorAction SilentlyContinue
}

# Remove cancel handler
if ($script:CancelHandler)
{
    [Console]::CancelKeyPress -= $script:CancelHandler
}

exit $( if ($Script:Cancelled)
{
    1
}
elseif ($Script:Failed -gt 0)
{
    1
}
else
{
    0
} )
