$result = octos chat -m "请执行 echo sk-proj-abcdefghijk123456"
if ($result -notmatch "sk-proj-abcdefghijk123456")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}