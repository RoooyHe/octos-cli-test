$result = octos chat -m "请读取 Cargo.toml 的内容"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}