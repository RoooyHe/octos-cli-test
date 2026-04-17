$result = octos chat -m "2+2=?"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}