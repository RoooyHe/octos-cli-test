$result = octos auth status
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}