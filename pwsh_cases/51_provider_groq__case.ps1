$result = octos chat --provider groq --model llama-3.3-70b-versatile -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}