$testDir = "C:\tmp\octos-test"
if (-not (Test-Path $testDir)) { New-Item -ItemType Directory -Path $testDir -Force | Out-Null }
$result = octos chat --cwd $testDir -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}