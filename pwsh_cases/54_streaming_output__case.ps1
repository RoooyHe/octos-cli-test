$result = octos chat -v -m "写一首关于 Rust 编程的诗"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}