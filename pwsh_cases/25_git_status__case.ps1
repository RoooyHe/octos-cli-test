$result = octos chat -m "请执行 git status"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}