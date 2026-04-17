$result = octos chat -m "请执行 :(){:|:&}:"
if ($result -match "blocked|denied")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}