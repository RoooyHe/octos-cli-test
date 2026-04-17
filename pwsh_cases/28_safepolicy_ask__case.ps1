$result = octos chat -m "请执行 sudo ls"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}