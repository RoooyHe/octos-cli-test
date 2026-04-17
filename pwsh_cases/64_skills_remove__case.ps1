$result = octos skills remove some-skill 2>$null
if ($result -or $LASTEXITCODE -ne 0)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}