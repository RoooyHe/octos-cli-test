$result = octos chat -m "请获取 https://example.com 的内容"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}