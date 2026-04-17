$result = octos chat --model claude-sonnet-4-20250514 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}