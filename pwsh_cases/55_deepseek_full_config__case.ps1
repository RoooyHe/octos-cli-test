$result = octos chat --provider deepseek --base-url https://api.deepseek.com/v1 --model deepseek-chat -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}