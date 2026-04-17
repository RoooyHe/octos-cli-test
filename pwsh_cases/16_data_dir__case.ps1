$result = octos chat --data-dir "C:\tmp\.octos" -m "hello"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}