$result = octos chat -m "请执行 ls -la"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}