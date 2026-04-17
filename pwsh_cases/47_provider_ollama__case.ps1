$result = octos chat --provider ollama --model llama3.2 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}