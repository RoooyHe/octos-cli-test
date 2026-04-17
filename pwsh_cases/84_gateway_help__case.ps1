$result = octos gateway --help
if ($result -match "gateway")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}