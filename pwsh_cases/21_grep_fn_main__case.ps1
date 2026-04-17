$result = octos chat -m "请在当前目录搜索 fn main"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}