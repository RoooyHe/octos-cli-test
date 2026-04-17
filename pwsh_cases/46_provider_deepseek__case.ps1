$result = octos chat --provider deepseek --model deepseek-chat -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}