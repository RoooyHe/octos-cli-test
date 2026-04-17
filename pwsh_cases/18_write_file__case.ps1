$result = octos chat -m "请创建一个 test.txt 文件，内容为 hello world"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}