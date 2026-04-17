$result = octos chat --provider anthropic --model claude-sonnet-4-20250514 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}