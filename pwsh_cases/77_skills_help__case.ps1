$result = octos skills --help
if ($result -match "skills")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}