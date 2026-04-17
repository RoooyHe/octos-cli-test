$result = octos chat --help
if ($result -match "chat")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}