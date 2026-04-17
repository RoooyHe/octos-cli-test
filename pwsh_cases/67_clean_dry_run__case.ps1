$result = octos clean --dry-run
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}