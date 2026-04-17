$result = octos chat -m "请将 src/main.rs 中的 foo 替换为 bar"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}