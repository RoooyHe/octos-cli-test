$result = octos chat -m "总结一下你最近记得的关于我的信息"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}