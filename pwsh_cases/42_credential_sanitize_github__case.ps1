$result = octos chat -m "请执行 echo ghp_xxxxxxxxxxxx"
if ($result -notmatch "ghp_xxxxxxxxxxxx")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}