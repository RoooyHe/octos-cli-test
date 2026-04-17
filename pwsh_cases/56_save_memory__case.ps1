$result = octos chat -m "请记住我喜欢使用 Python 编程"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}