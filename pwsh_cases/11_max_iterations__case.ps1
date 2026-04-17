$result = octos chat --max-iterations 3 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}