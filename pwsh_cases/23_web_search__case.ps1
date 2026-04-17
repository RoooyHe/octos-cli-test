$result = octos chat -m "请搜索 Rust 异步编程的最新进展"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}