$result = octos chat -m "请同时读取 src/main.rs、src/lib.rs 和 Cargo.toml"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}