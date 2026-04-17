$result = octos chat --provider gemini --model gemini-2.0-flash -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}