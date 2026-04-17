$result = octos serve --help
if ($result -match "serve")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}