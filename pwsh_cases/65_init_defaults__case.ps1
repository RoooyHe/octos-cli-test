$result = octos init --defaults
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}