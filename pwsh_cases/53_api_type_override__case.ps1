$result = octos chat --provider minimax --api-type anthropic --model minimax-text-01 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}