$result = octos chat --provider minimax --model MiniMax-Text-01 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}