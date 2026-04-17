$result = octos chat -m "我之前说过我喜欢什么编程语言？"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}