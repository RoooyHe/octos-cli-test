$result = octos chat -m "请列出所有 code 标签的工具"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}