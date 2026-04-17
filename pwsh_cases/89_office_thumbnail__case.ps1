$result = octos office thumbnail C:\tmp\test.pptx 2>$null
if ($result -or $LASTEXITCODE -ne 0)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}