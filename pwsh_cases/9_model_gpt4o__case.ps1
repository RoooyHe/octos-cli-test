$result = octos chat --model gpt-4o -m "hello"
if ($result -match "gpt|openai")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}