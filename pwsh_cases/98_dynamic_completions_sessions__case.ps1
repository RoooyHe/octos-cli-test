$result = octos completions bash --dynamic Sessions
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}