$result = octos chat -m "请执行 echo AKIAIOSFODNN7EXAMPLE"
if ($result -notmatch "AKIAIOSFODNN7EXAMPLE")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}