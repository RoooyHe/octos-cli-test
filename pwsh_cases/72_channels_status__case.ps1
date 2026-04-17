$result = octos channels status
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}