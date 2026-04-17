$result = octos chat --provider openai --base-url http://localhost:8080/v1 -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}