$result = "quit" | octos chat
if ($result -match "Goodbye")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}