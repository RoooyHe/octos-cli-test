$result = octos chat --provider moonshot --model kimi-k2.5 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}