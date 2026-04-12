# Octos CLI 自动化测试脚本
# 用于 Windows PowerShell 环境

param(
    [string]$OctosBinary = "octos",
    [string]$OutputDir = "test-results"
)

$ErrorActionPreference = "Continue"
$TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ReportDate = Get-Date -Format "yyyy-MM-dd"
$Script:Passed = 0
$Script:Failed = 0
$Script:Skipped = 0
$Script:Total = 0
$Script:Results = @()

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Get-OctoOutput {
    param([string]$CmdArgs, [int]$Timeout = 60)
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "cmd"
        $fullCmd = "/c `"`"$OctosBinary`" $CmdArgs`""
        $psi.Arguments = $fullCmd
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit($Timeout * 1000)
        if (-not $proc.HasExited) {
            $proc.Kill()
        }
        return @{
            ExitCode = $proc.ExitCode
            Stdout = $stdout
            Stderr = $stderr
        }
    }
    catch {
        return @{
            ExitCode = -1
            Stdout = ""
            Stderr = $_.Exception.Message
        }
    }
}

function Test-CLI {
    param(
        [string]$TestId,
        [string]$Category,
        [string]$TestName,
        [string]$CmdArgs,
        [string]$Expected,
        [string]$Validation = "contains",
        [int]$Timeout = 60
    )
    
    $Script:Total++
    $result = Get-OctoOutput -CmdArgs $CmdArgs -Timeout $Timeout
    $actual = $result.Stdout + $result.Stderr
    $passed = $false
    
    switch ($Validation) {
        "contains" { $passed = $actual -like "*$Expected*" }
        "not_contains" { $passed = $actual -notlike "*$Expected*" }
        "exitcode" { $passed = $result.ExitCode -eq [int]$Expected }
    }
    
    if ($passed) { $Script:Passed++ } else { $Script:Failed++ }
    
    $Script:Results += [PSCustomObject]@{
        TestId = $TestId
        Category = $Category
        TestName = $TestName
        Args = $CmdArgs
        Expected = $Expected
        Actual = $actual.Substring(0, [Math]::Min(200, $actual.Length)).Replace("`n", " ").Replace("`r", "")
        Status = if ($passed) { "PASS" } else { "FAIL" }
        ExitCode = $result.ExitCode
    }
    
    $status = if ($passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "$status $TestId $TestName" -ForegroundColor $color
}

function Test-File {
    param(
        [string]$TestId,
        [string]$Category,
        [string]$TestName,
        [string]$Path,
        [bool]$ShouldExist = $true
    )
    
    $Script:Total++
    $exists = Test-Path $Path
    $passed = $exists -eq $ShouldExist
    
    if ($passed) { $Script:Passed++ } else { $Script:Failed++ }
    
    $Script:Results += [PSCustomObject]@{
        TestId = $TestId
        Category = $Category
        TestName = $TestName
        Args = "(file check)"
        Expected = if ($ShouldExist) { "exists" } else { "not exists" }
        Actual = if ($exists) { "Path exists: $Path" } else { "Path not found: $Path" }
        Status = if ($passed) { "PASS" } else { "FAIL" }
        ExitCode = 0
    }
    
    $status = if ($passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "$status $TestId $TestName" -ForegroundColor $color
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Octos CLI Automated Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Time: $TestDate" -ForegroundColor Gray
Write-Host "Binary: $OctosBinary" -ForegroundColor Gray
Write-Host ""

# Check if binary exists
$binaryPath = if (Test-Path $OctosBinary) { $OctosBinary } else { (Get-Command $OctosBinary -ErrorAction SilentlyContinue).Source }
if (-not $binaryPath) {
    Write-Host "[ERROR] Binary not found: $OctosBinary" -ForegroundColor Red
    Write-Host "Please run: cargo build --all-features" -ForegroundColor Yellow
    exit 1
}

# Setup test workspace
$testDir = "$env:TEMP\octos-cli-test"
if (Test-Path $testDir) { Remove-Item -Recurse -Force $testDir }
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Write-Host "Test workspace: $testDir" -ForegroundColor Gray
Write-Host ""

# ========================================
# 1. CLI 基础 (octos chat)
# ========================================
Write-Host "`n[1] CLI 基础 (octos chat)" -ForegroundColor Yellow

Test-CLI -TestId "1.1" -Category "CLI基础" -TestName "help信息" -CmdArgs "--help" -Expected "chat"
Test-CLI -TestId "1.2" -Category "CLI基础" -TestName "版本信息" -CmdArgs "--version" -Expected "octos"
Test-CLI -TestId "1.3" -Category "CLI基础" -TestName "单消息模式" -CmdArgs "chat --message `"hello`" --no-retry" -Expected "hello" -Timeout 30

# ========================================
# 2. 工具系统 (octos chat with tools)
# ========================================
Write-Host "`n[2] 工具系统" -ForegroundColor Yellow

Test-CLI -TestId "2.1" -Category "工具系统" -TestName "单消息模式运行" -CmdArgs "chat --message `"echo hello`" --no-retry" -Expected "hello" -Timeout 30

# ========================================
# 3. 安全测试
# ========================================
Write-Host "`n[3] 安全测试" -ForegroundColor Yellow

Test-CLI -TestId "3.1" -Category "安全" -TestName "危险命令拒绝" -CmdArgs "chat --message `"run rm -rf /`" --no-retry" -Expected "reject" -Timeout 30

# ========================================
# 4. init 命令
# ========================================
Write-Host "`n[4] init 命令" -ForegroundColor Yellow

Test-CLI -TestId "4.1" -Category "init" -TestName "help信息" -CmdArgs "init --help" -Expected "--defaults"
Test-CLI -TestId "4.2" -Category "init" -TestName "默认初始化" -CmdArgs "init --defaults --cwd `"$testDir`"" -Expected "Created"
Test-File -TestId "4.3" -Category "init" -TestName "config.json存在" -Path "$testDir\.octos\config.json"
Test-CLI -TestId "4.4" -Category "init" -TestName "重新初始化提示" -CmdArgs "init --cwd `"$testDir`"" -Expected "already exists"

# ========================================
# 5. clean 命令
# ========================================
Write-Host "`n[5] clean 命令" -ForegroundColor Yellow

Test-CLI -TestId "5.1" -Category "clean" -TestName "help信息" -CmdArgs "clean --help" -Expected "--all"
Test-CLI -TestId "5.2" -Category "clean" -TestName "无.octos目录" -CmdArgs "clean --cwd `"$env:TEMP\no-octos-dir`"" -Expected "No .octos"
Test-CLI -TestId "5.3" -Category "clean" -TestName "空目录" -CmdArgs "clean --cwd `"$testDir`"" -Expected "Nothing to clean"

# ========================================
# 6. status 命令
# ========================================
Write-Host "`n[6] status 命令" -ForegroundColor Yellow

Test-CLI -TestId "6.1" -Category "status" -TestName "help信息" -CmdArgs "status --help" -Expected "status"
Test-CLI -TestId "6.2" -Category "status" -TestName "显示状态" -CmdArgs "status --cwd `"$testDir`"" -Expected "provider"

# ========================================
# 7. completions 命令
# ========================================
Write-Host "`n[7] completions 命令" -ForegroundColor Yellow

Test-CLI -TestId "7.1" -Category "completions" -TestName "help信息" -CmdArgs "completions --help" -Expected "bash"
Test-CLI -TestId "7.2" -Category "completions" -TestName "bash补全" -CmdArgs "completions bash" -Expected "_octos"
Test-CLI -TestId "7.3" -Category "completions" -TestName "zsh补全" -CmdArgs "completions zsh" -Expected "compdef"
Test-CLI -TestId "7.4" -Category "completions" -TestName "fish补全" -CmdArgs "completions fish" -Expected "complete"
Test-CLI -TestId "7.5" -Category "completions" -TestName "powershell补全" -CmdArgs "completions powershell" -Expected "Register-ArgumentCompleter"
Test-CLI -TestId "7.6" -Category "completions" -TestName "无效shell" -CmdArgs "completions invalid-shell" -Expected "error"

# ========================================
# 8. skills 命令
# ========================================
Write-Host "`n[8] skills 命令" -ForegroundColor Yellow

Test-CLI -TestId "8.1" -Category "skills" -TestName "help信息" -CmdArgs "skills --help" -Expected "list"
Test-CLI -TestId "8.2" -Category "skills" -TestName "列出技能" -CmdArgs "skills list" -Expected "Installed Skills"
Test-CLI -TestId "8.3" -Category "skills" -TestName "搜索技能" -CmdArgs "skills search mofa" -Expected "mofa"
Test-CLI -TestId "8.4" -Category "skills" -TestName "搜索无结果" -CmdArgs "skills search xyznonexistent99" -Expected "No packages"
Test-CLI -TestId "8.5" -Category "skills" -TestName "移除不存在的技能" -CmdArgs "skills remove nonexistent-skill-xyz" -Expected "not found"

# ========================================
# 9. auth 命令
# ========================================
Write-Host "`n[9] auth 命令" -ForegroundColor Yellow

Test-CLI -TestId "9.1" -Category "auth" -TestName "help信息" -CmdArgs "auth --help" -Expected "login"
Test-CLI -TestId "9.2" -Category "auth" -TestName "auth状态" -CmdArgs "auth status" -Expected "Not logged in"

# ========================================
# 10. channels 命令
# ========================================
Write-Host "`n[10] channels 命令" -ForegroundColor Yellow

Test-CLI -TestId "10.1" -Category "channels" -TestName "help信息" -CmdArgs "channels --help" -Expected "channels"
Test-CLI -TestId "10.2" -Category "channels" -TestName "channels状态" -CmdArgs "channels status" -Expected "gateway"

# ========================================
# 11. cron 命令
# ========================================
Write-Host "`n[11] cron 命令" -ForegroundColor Yellow

Test-CLI -TestId "11.1" -Category "cron" -TestName "help信息" -CmdArgs "cron --help" -Expected "list"
Test-CLI -TestId "11.2" -Category "cron" -TestName "cron列表" -CmdArgs "cron list" -Expected "No scheduled"

# ========================================
# 12. chat 命令
# ========================================
Write-Host "`n[12] chat 命令" -ForegroundColor Yellow

Test-CLI -TestId "12.1" -Category "chat" -TestName "help信息" -CmdArgs "chat --help" -Expected "--model"

# ========================================
# 13. gateway 命令
# ========================================
Write-Host "`n[13] gateway 命令" -ForegroundColor Yellow

Test-CLI -TestId "13.1" -Category "gateway" -TestName "help信息" -CmdArgs "gateway --help" -Expected "gateway"

# ========================================
# 14. serve 命令 (需要 api feature)
# ========================================
Write-Host "`n[14] serve 命令" -ForegroundColor Yellow

Test-CLI -TestId "14.1" -Category "serve" -TestName "help信息" -CmdArgs "serve --help" -Expected "--port"

# ========================================
# 15. docs 命令
# ========================================
Write-Host "`n[15] docs 命令" -ForegroundColor Yellow

Test-CLI -TestId "15.1" -Category "docs" -TestName "help信息" -CmdArgs "docs --help" -Expected "docs"

# ========================================
# Generate Report
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Generating Report..." -ForegroundColor Cyan

$reportPath = "$OutputDir\CLI_TEST_REPORT_$ReportDate.md"
$passRate = if ($Script:Total -gt 0) { [math]::Round($Script:Passed / $Script:Total * 100, 1) } else { 0 }

$grouped = $Script:Results | Group-Object Category
$catStats = @()
foreach ($g in $grouped) {
    $cName = $g.Name
    $cTotal = $g.Count
    $cPassed = ($g.Group | Where-Object { $_.Status -eq "PASS" }).Count
    $cFailed = $cTotal - $cPassed
    $cRate = if ($cTotal -gt 0) { [math]::Round($cPassed / $cTotal * 100, 0) } else { 0 }
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
$reportLines += "| Total Tests | $($Script:Total) |"
$reportLines += "| Passed | $($Script:Passed) |"
$reportLines += "| Failed | $($Script:Failed) |"
$reportLines += "| Pass Rate | $passRate% |"
$reportLines += ""
$reportLines += "## Summary by Category"
$reportLines += ""
$reportLines += "| Category | Total | Passed | Failed | Pass Rate |"
$reportLines += "|----------|-------|--------|--------|-----------|"
foreach ($stat in $catStats) {
    $reportLines += "| $($stat.Category) | $($stat.Total) | $($stat.Passed) | $($stat.Failed) | $($stat.Rate)% |"
}
$reportLines += ""
$reportLines += "## Detailed Test Results"
$reportLines += ""
$reportLines += "| ID | Category | Test Name | Args | Expected | Actual | Status |"
$reportLines += "|----|----------|-----------|------|----------|--------|--------|"
foreach ($r in $Script:Results) {
    $actualEscaped = $r.Actual -replace '"', '\"'
    $reportLines += "| $($r.TestId) | $($r.Category) | $($r.TestName) | $($r.Args) | $($r.Expected) | $($actualEscaped) | $($r.Status) |"
}
$reportLines += ""
$reportLines += "## Failed Tests Detail"
$reportLines += ""
$failedTests = $Script:Results | Where-Object { $_.Status -eq "FAIL" }
if ($failedTests.Count -eq 0) {
    $reportLines += "All tests passed!"
} else {
    foreach ($t in $failedTests) {
        $reportLines += "### $($t.TestId): $($t.TestName)"
        $reportLines += ""
        $reportLines += "- **Args**: `"$($t.Args)`""
        $reportLines += "- **Expected**: $($t.Expected)"
        $reportLines += "- **Exit Code**: $($t.ExitCode)"
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
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY: Total=$($Script:Total) Passed=$($Script:Passed) Failed=$($Script:Failed) PassRate=$passRate%" -ForegroundColor $(if($passRate -ge 80){"Green"}elseif($passRate -ge 60){"Yellow"}else{"Red"})

# Cleanup
if (Test-Path $testDir) { Remove-Item -Recurse -Force $testDir -ErrorAction SilentlyContinue }

exit $(if($Script:Failed -gt 0) { 1 } else { 0 })
