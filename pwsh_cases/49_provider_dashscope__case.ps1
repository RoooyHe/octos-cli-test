$result = octos chat --provider dashscope --model qwen-max -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}