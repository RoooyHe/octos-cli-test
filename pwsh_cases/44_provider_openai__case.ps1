$result = octos chat --provider openai --model gpt-4o -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}