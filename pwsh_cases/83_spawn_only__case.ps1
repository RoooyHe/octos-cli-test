$result = octos chat -m "请在后台启动一个计算任务，不要等待结果"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}