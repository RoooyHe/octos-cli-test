$result = octos --help
if ($result -match "octos")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}