$result = octos chat -m "请获取 http://nonexistent.invalid 的内容"
if ($result -match "error|Error|dns|resolve")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}