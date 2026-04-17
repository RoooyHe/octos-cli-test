$result = octos office clean C:\tmp\unpacked 2>$null
if ($result -or $LASTEXITCODE -ne 0)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}