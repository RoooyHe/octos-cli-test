$result = octos chat -m "请查找所有 *.rs 文件"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}