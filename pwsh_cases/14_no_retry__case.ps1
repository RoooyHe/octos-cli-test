$result = octos chat --no-retry -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}