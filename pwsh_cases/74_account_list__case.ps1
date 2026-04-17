$result = octos account list
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}