$result = octos chat -m "请列出当前目录的内容"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}