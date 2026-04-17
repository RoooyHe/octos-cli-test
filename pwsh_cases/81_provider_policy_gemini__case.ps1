$result = octos chat -m "请执行 diff 编辑"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}